Class {
	#name : 'RZDevsClusterFaultInjectionTest',
	#superclass : 'TestCase',
	#instVars : [
		'router',
		'sharedAddresses',
		'clusters'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> clusterAt: anAddress [
	^ clusters detect: [ :each | each localNode address = anAddress ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> nodeList [
	^ {
		#node1 -> '127.0.0.1'.
		#node2 -> '127.0.0.2'.
		#node3 -> '127.0.0.3'.
		#node4 -> '127.0.0.4'.
		#node5 -> '127.0.0.5'
		}
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> primaryClusterForKey: aKey [
	| winningNames winningName winningAddress |
	winningNames := clusters first placementStrategy nodeNamesForKey: aKey.
	winningName := winningNames first.
	winningAddress := (self nodeList detect: [ :assoc | assoc key = winningName ]) value.
	^ self clusterAt: winningAddress
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> setUp [
	super setUp.
	router := RZDevsNetworkRouter new.
	sharedAddresses := Dictionary new.
	clusters := self nodeList collect: [ :assoc | | cluster network |
		network := RZDevsSimulatedNetwork
			forAddress: assoc value
			addresses: sharedAddresses
			router: router.
		cluster := RZCluster new
			localAddress: assoc value;
			buildNodesFromList: self nodeList.
		cluster network: network.
		cluster localNode
			basePath: ('rhizome-devs/', assoc value asString);
			registerNode;
			registerOnPort: 5555.
		cluster ].
	clusters do: [ :cluster | cluster announceAll ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> shareOwnershipStoreWithShortLease [
	| store |
	store := RZInMemoryOwnershipStore new.
	clusters do: [ :cluster |
		cluster ownershipStore: store.
		cluster hostLeaseManager
			leaseDuration: 100 milliSeconds;
			renewInterval: 20 milliSeconds;
			safetyMargin: 10 milliSeconds ].
	^ store
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> tearDown [
	super tearDown.
	'rhizome-devs' asFileReference ensureDeleteAll
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testCrashedPrimaryLeaseExpiresAndRivalCanPromote [
	| hostA hostB |
	self shareOwnershipStoreWithShortLease.
	hostA := clusters first.
	hostB := clusters second.
	self assert: (hostA hostLeaseManager tryPromoteFor: #lease1) notNil.
	self assert: (hostA hostLeaseManager isWritableFor: #lease1).
	(Delay forMilliseconds: 150) wait. "hostA never renews again - simulates a crash"
	self assert: (hostB hostLeaseManager tryPromoteFor: #lease1) notNil.
	self assert: (hostB hostLeaseManager isWritableFor: #lease1).
	self deny: (hostA hostLeaseManager renewFor: #lease1) notNil.
	self deny: (hostA hostLeaseManager isWritableFor: #lease1)
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testInitialSyncSkipsUnreachableReplicaWithoutRaising [
	| primary set remote |
	primary := self primaryClusterForKey: 'db-4'.
	set := primary replicaSetForKey: 'db-4'.
	self writeInitialCommitFor: set.
	remote := set remoteReplicas first.
	router simulateNetworkPartition: primary localNode address and: remote address.
	set start.
	router healPartition: primary localNode address and: remote address.
	self assert: (set endpointStatusAt: remote) isNil
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testInitialSyncSucceedsAfterHealingPartition [
	| primary set remote |
	primary := self primaryClusterForKey: 'db-3'.
	set := primary replicaSetForKey: 'db-3'.
	self writeInitialCommitFor: set.
	remote := set remoteReplicas first.
	router simulateNetworkPartition: primary localNode address and: remote address.
	router healPartition: primary localNode address and: remote address.
	set start.
	set remoteReplicas do: [ :r |
		self assert: (set endpointStatusAt: r) databaseVersion equals: set localReplica databaseVersion ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testInitialSyncSucceedsWithoutPartition [
	| primary set |
	primary := self primaryClusterForKey: 'db-1'.
	set := primary replicaSetForKey: 'db-1'.
	self writeInitialCommitFor: set.
	set start.
	set remoteReplicas do: [ :remote |
		| status |
		status := set endpointStatusAt: remote.
		self assert: status notNil.
		self assert: status databaseVersion equals: set localReplica databaseVersion ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testPartitionDoesNotAffectLeaseRenewal [
	"The ownership store models a shared, always-reachable authority (NFS in
	production), not a peer reachable only through the replicated data plane -
	so a primary partitioned from its replica peers keeps renewing its lease
	just fine. Only replication/initial-sync (see the other tests in this
	class) is affected by a network partition, not lease renewal itself."
	| hostA hostB |
	self shareOwnershipStoreWithShortLease.
	hostA := clusters first.
	hostB := clusters second.
	hostA hostLeaseManager tryPromoteFor: #lease2.
	router simulateNetworkPartition: hostA localNode address and: hostB localNode address.
	self assert: (hostA hostLeaseManager renewFor: #lease2) notNil.
	self assert: (hostA hostLeaseManager isWritableFor: #lease2)
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testRequestRouterForwardsToNewPrimaryAfterPromotion [
	| hostA hostB requestRouter decision |
	self shareOwnershipStoreWithShortLease.
	hostA := clusters first.
	hostB := clusters second.
	hostA hostLeaseManager tryPromoteFor: #lease3.
	(Delay forMilliseconds: 150) wait.
	hostB hostLeaseManager tryPromoteFor: #lease3.
	requestRouter := RZRequestRouter new cluster: hostA.
	decision := requestRouter resolveFor: #lease3.
	self assert: decision isForward.
	self assert: decision targetImage node address equals: hostB localNode address
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testSetUpBuildsFiveClusters [
	self assert: clusters size equals: 5.
	self assert: ((self clusterAt: '127.0.0.1') isKindOf: RZCluster)
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testUnreachableReplicaDoesNotBlockOtherReplicas [
	| primary set unreachable reachable |
	primary := self primaryClusterForKey: 'db-5'.
	set := primary replicaSetForKey: 'db-5'.
	self writeInitialCommitFor: set.
	unreachable := set remoteReplicas first.
	reachable := set remoteReplicas second.
	router simulateNetworkPartition: primary localNode address and: unreachable address.
	set start.
	self assert: (set endpointStatusAt: reachable) databaseVersion equals: set localReplica databaseVersion.
	router healPartition: primary localNode address and: unreachable address.
	self assert: (set endpointStatusAt: unreachable) isNil
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> writeInitialCommitFor: replicaSet [
	| db txn |
	replicaSet cluster localNode createDatabaseWithId: replicaSet key.
	db := replicaSet localReplica soil.
	txn := db newTransaction.
	txn root: Dictionary new.
	txn commit
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> writeInitialCommitFor: virtualNode key: dbId [
	| db txn |
	virtualNode node createDatabaseWithId: dbId.
	db := (virtualNode cluster replicaSetForKey: dbId) replicas first soil.
	txn := db newTransaction.
	txn root: Dictionary new.
	txn commit
]
