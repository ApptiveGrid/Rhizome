Class {
	#name : #RZSimulatedTest,
	#superclass : #TestCase,
	#instVars : [
		'network',
		'clusters'
	],
	#category : #'Rhizome-Tests'
}

{ #category : #accessing }
RZSimulatedTest >> buildCluster [
	^ RZCluster new 
		localAddress: self localAddress;
		buildNodesFromList: self nodeList
		 
]

{ #category : #accessing }
RZSimulatedTest >> buildClusters [
	^ RZCluster new 
		localAddress: self localAddress;
		buildNodesFromList: self nodeList
		 
]

{ #category : #'as yet unclassified' }
RZSimulatedTest >> buildNetwork [ 
	^ RZClusterSimulationBuilder new 
		build: self cluster
]

{ #category : #accessing }
RZSimulatedTest >> localAddress [
	^ '127.0.0.1'
]

{ #category : #accessing }
RZSimulatedTest >> network [
	^ network ifNil: [ 
		network := self buildNetwork  ]
]

{ #category : #accessing }
RZSimulatedTest >> nodeList [ 
	^ { 
		#node1 -> '127.0.0.1'. 
		#node2 -> '127.0.0.2'. 
		#node3 -> '127.0.0.3'.
		#node4 -> '127.0.0.4'. 
		#node5 -> '127.0.0.5' 
		}
]

{ #category : #running }
RZSimulatedTest >> setUp [ 
	super setUp.
	network := RZSimulatedNetwork new. 
	clusters := Dictionary new.
	self nodeList do: [ :assoc | | cluster |
		cluster := RZCluster new 
			localAddress: assoc value;
			buildNodesFromList: self nodeList.
		cluster network: network.
		cluster localNode 
			basePath: ('rhizome/', assoc value asString);
			createDatabaseWithId: '012345';
			registerOnPort: 5555.
		network registerNode: cluster localNode.
		clusters at: assoc value put: cluster ]. 
	clusters do: #announceAll.

]

{ #category : #accessing }
RZSimulatedTest >> tearDown [ 
	super tearDown.
	'rhizome' asFileReference ensureDeleteAll 
]

{ #category : #tests }
RZSimulatedTest >> testDummy [ 
	self halt.
]

{ #category : #tests }
RZSimulatedTest >> testResolveReplicaSet [
	| set db txn |
	set := (clusters at: '127.0.0.1') replicaSetForKey: '012345'.
	db := set replicas first soil.
	txn := db newTransaction.
	txn root: Dictionary new.
	txn commit.
	set start.
	
]
