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
RZDevsClusterFaultInjectionTest >> tearDown [
	super tearDown.
	'rhizome-devs' asFileReference ensureDeleteAll
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
