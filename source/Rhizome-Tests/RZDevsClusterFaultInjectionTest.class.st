Class {
	#name : 'RZDevsClusterFaultInjectionTest',
	#superclass : 'TestCase',
	#instVars : [
		'router',
		'sharedAddresses',
		'clusters',
		'clock'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> clusterAt: anAddress [
	^ clusters detect: [ :each | each localHost address = anAddress ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> hostList [
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
	winningNames := clusters first placementStrategy hostNamesForKey: aKey.
	winningName := winningNames first.
	winningAddress := (self hostList detect: [ :assoc | assoc key = winningName ]) value.
	^ self clusterAt: winningAddress
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> setUp [
	super setUp.
	router := DEVSFaultInjectingNetworkRouter new.
	sharedAddresses := Dictionary new.
	clusters := self hostList collect: [ :assoc | | cluster network |
		network := RZDevsSimulatedNetwork
			forAddress: assoc value
			addresses: sharedAddresses
			router: router.
		cluster := RZCluster new
			localAddress: assoc value;
			buildHostsFromList: self hostList.
		cluster network: network.
		cluster localHost
			basePath: ('rhizome-devs/', assoc value asString);
			registerHost;
			registerOnPort: 5555.
		cluster ].
	clusters do: [ :cluster | cluster announceAll ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> commitTo: replicaSet times: aNumber [
	"Move a replica's database version forward, so that one side can be ahead of
	the other without either being told."

	aNumber timesRepeat: [
		| txn |
		txn := replicaSet localReplica soil newTransaction.
		txn root at: #writes put: replicaSet localReplica databaseVersion.
		txn commit ]
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> rivalClusterForKey: aKey [
	"Whoever placement puts second for that key - the one that takes over when the
	first is gone."

	| names name address |
	names := clusters first placementStrategy hostNamesForKey: aKey.
	name := names second.
	address := (self hostList detect: [ :assoc | assoc key = name ]) value.
	^ self clusterAt: address
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> shareOwnershipStoreWithShortLease [
	"Wire every cluster to one store and one clock. The clock is shared here
	because these tests are about expiry, not about skew - the seam allows a
	separate clock per reader, and that is what a later skew test will use."
	| store |
	store := RZInMemoryOwnershipStore new.
	clock := RZManualClock new.
	store clock: clock.
	clusters do: [ :cluster |
		cluster ownershipStore: store.
		cluster hostLeaseManager
			clock: clock;
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
RZDevsClusterFaultInjectionTest >> testAOneWayPartitionLeavesThePrimaryFineInItsOwnEyes [
	"The case a symmetric cut cannot show, and the reason the directed lever exists.
	Nothing the primary sends arrives; everything sent to it does. From where it
	stands the cluster is healthy - it renews its lease, because the ownership store
	is a shared authority and not a peer, and it considers itself writable. Its
	replication simply stops arriving, silently.

	Nothing here is asserted about detection, because nothing detects it. That is
	the point of writing the case down before there is a failure detector to show it
	to."

	| key primary set remote fromTheOtherSide back |
	self shareOwnershipStoreWithShortLease.
	key := 'db-7'.
	primary := self primaryClusterForKey: key.
	primary hostLeaseManager tryPromoteFor: key.
	set := primary replicaSetForKey: key.
	self writeInitialCommitFor: set.
	remote := set remoteReplicas first.
	router
		simulateNetworkPartitionFrom: primary localHost address
		to: remote address.
	"A sync round does not raise - it notices the replica is unreachable and goes on."
	set start.
	self assert: (primary hostLeaseManager renewFor: key) notNil.
	self assert: (primary hostLeaseManager isWritableFor: key).
	"and the other side is not cut off at all"
	fromTheOtherSide := (self clusterAt: remote address) replicaSetForKey: key.
	back := fromTheOtherSide remoteReplicas detect: [ :each |
		        each address = primary localHost address ].
	self assert: (fromTheOtherSide endpointStatusAt: back) notNil
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testAReturningOldPrimaryIsFencedByWhatItFinds [
	"The third of the scenarios this epic is measured by, and the one that was
	missing: crash and partition were played, the return of an old primary was not.

	It runs the whole way through rather than asserting a mechanism: the primary
	takes the lease and writes; it is cut off and stops renewing, which is what a
	crash looks like from outside; the rival takes over with a higher epoch and
	moves the database on; then the old primary comes back, still believing what it
	believed. What fences it is not a message anyone sends - it is what it finds:
	the replica it syncs with is ahead, it is no longer primary, so it marks itself
	stale rather than writing over what happened without it.

	The two halves of that have been tested apart until now - the lease side in this
	class, the staleness side in RZReplicaSetFencingTest with a cluster built by hand
	and an ownership record edited in place. Here they meet."

	| key primary rival set rivalSet remote |
	self shareOwnershipStoreWithShortLease.
	key := 'db-6'.
	primary := self primaryClusterForKey: key.
	rival := self rivalClusterForKey: key.
	self assert: (primary hostLeaseManager tryPromoteFor: key) notNil.
	set := primary replicaSetForKey: key.
	self writeInitialCommitFor: set.
	router
		simulateNetworkPartition: primary localHost address
		and: rival localHost address.
	"It never renews again - that is the crash, seen from the others."
	clock advanceBy: 150 milliSeconds.
	self assert: (rival hostLeaseManager tryPromoteFor: key) epoch > 1.
	rivalSet := rival replicaSetForKey: key.
	self writeInitialCommitFor: rivalSet.
	self commitTo: rivalSet times: 2.
	self
		assert: rivalSet localReplica databaseVersion
		> set localReplica databaseVersion.
	"and back it comes"
	router
		healPartition: primary localHost address
		and: rival localHost address.
	remote := set remoteReplicas detect: [ :each |
		          each address = rival localHost address ].
	self deny: set localReplica isStale.
	set syncWith: remote.
	self assert: set localReplica isStale.
	self deny: (primary hostLeaseManager isWritableFor: key)
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testCrashedPrimaryLeaseExpiresAndRivalCanPromote [
	| hostA hostB |
	self shareOwnershipStoreWithShortLease.
	hostA := clusters first.
	hostB := clusters second.
	self assert: (hostA hostLeaseManager tryPromoteFor: #lease1) notNil.
	self assert: (hostA hostLeaseManager isWritableFor: #lease1).
	clock advanceBy: 150 milliSeconds. "hostA never renews again - simulates a crash"
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
	router simulateNetworkPartition: primary localHost address and: remote address.
	set start.
	router healPartition: primary localHost address and: remote address.
	self assert: (set endpointStatusAt: remote) isNil
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> testInitialSyncSucceedsAfterHealingPartition [
	| primary set remote |
	primary := self primaryClusterForKey: 'db-3'.
	set := primary replicaSetForKey: 'db-3'.
	self writeInitialCommitFor: set.
	remote := set remoteReplicas first.
	router simulateNetworkPartition: primary localHost address and: remote address.
	router healPartition: primary localHost address and: remote address.
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
	router simulateNetworkPartition: hostA localHost address and: hostB localHost address.
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
	clock advanceBy: 150 milliSeconds.
	hostB hostLeaseManager tryPromoteFor: #lease3.
	requestRouter := RZRequestRouter new cluster: hostA.
	decision := requestRouter resolveFor: #lease3.
	self assert: decision isForward.
	self assert: decision targetNode host address equals: hostB localHost address
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
	router simulateNetworkPartition: primary localHost address and: unreachable address.
	set start.
	self assert: (set endpointStatusAt: reachable) databaseVersion equals: set localReplica databaseVersion.
	router healPartition: primary localHost address and: unreachable address.
	self assert: (set endpointStatusAt: unreachable) isNil
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> writeInitialCommitFor: replicaSet [
	| db txn |
	replicaSet cluster localHost createDatabaseWithId: replicaSet key.
	db := replicaSet localReplica soil.
	txn := db newTransaction.
	txn root: Dictionary new.
	txn commit
]

{ #category : 'as yet unclassified' }
RZDevsClusterFaultInjectionTest >> writeInitialCommitFor: node key: dbId [
	| db txn |
	node host createDatabaseWithId: dbId.
	db := (node cluster replicaSetForKey: dbId) replicas first soil.
	txn := db newTransaction.
	txn root: Dictionary new.
	txn commit
]
