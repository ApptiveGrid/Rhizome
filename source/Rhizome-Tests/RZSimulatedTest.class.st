Class {
	#name : 'RZSimulatedTest',
	#superclass : 'TestCase',
	#instVars : [
		'network',
		'clusters'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'accessing' }
RZSimulatedTest >> hostList [ 
	^ { 
		#node1 -> '127.0.0.1'. 
		#node2 -> '127.0.0.2'. 
		#node3 -> '127.0.0.3'.
		#node4 -> '127.0.0.4'. 
		#node5 -> '127.0.0.5' 
		}
]

{ #category : 'accessing' }
RZSimulatedTest >> localAddress [
	^ '127.0.0.1'
]

{ #category : 'running' }
RZSimulatedTest >> setUp [ 
	super setUp.
	network := RZSimulatedNetwork new. 
	self hostList do: [ :assoc | | cluster |
		cluster := RZCluster new 
			localAddress: assoc value;
			buildHostsFromList: self hostList.
		cluster network: network.
		cluster localHost 
			basePath: ('rhizome/', assoc value asString);
			registerHost;
			registerOnPort: 5555 ]. 
	"clusters do: #announceAll."
	network hosts do: [ :host | 
		host keysAndValuesDo: [ :port :server | 
			server cluster announceAll ] ] 

]

{ #category : 'accessing' }
RZSimulatedTest >> tearDown [ 
	super tearDown.
	'rhizome' asFileReference ensureDeleteAll 
]

{ #category : 'tests' }
RZSimulatedTest >> testResolveReplicaSet [
	| set db txn node |
	node := ((network addressAt: '127.0.0.1') at: 5555) node.
	node host createDatabaseWithId: '012345'.
	set := node cluster replicaSetForKey: '012345'.
	db := set replicas first soil.
	txn := db newTransaction.
	txn root: Dictionary new.
	txn commit.
	set start.
	set remoteReplicas do: [ :remote |
		| status |
		status := set endpointStatusAt: remote.
		self assert: status notNil.
		self assert: status databaseVersion equals: set localReplica databaseVersion ]
]
