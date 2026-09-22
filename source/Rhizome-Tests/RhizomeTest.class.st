Class {
	#name : 'RhizomeTest',
	#superclass : 'TestCase',
	#instVars : [
		'cluster'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'accessing' }
RhizomeTest >> hostList [ 
	^ { 
		#node1 -> '127.0.0.1'. 
		#node2 -> '127.0.0.2'. 
		#node3 -> '127.0.0.3'.
		#node4 -> '127.0.0.4'. 
		#node5 -> '127.0.0.5' 
		}
]

{ #category : 'accessing' }
RhizomeTest >> localAddress [
	^ '127.0.0.1'
]

{ #category : 'running' }
RhizomeTest >> setUp [ 
	super setUp.
	cluster := RZCluster new 
		localAddress: self localAddress;
		buildHostsFromList: self hostList 
]

{ #category : 'tests' }
RhizomeTest >> testAddNode [ 
	cluster localHost addNodeWithPort: 10000.
	self assert: cluster localHost nodes size equals: 1
]

{ #category : 'tests' }
RhizomeTest >> testDispatchToNode [ 
	| node targetNode |
	cluster hosts do: [ :host | host addNodeWithPort: 10000 ].
	node := cluster localHost nodeWithPort: 10000.
	targetNode := node targetNodeFor: '012345'.
	self assert: node equals: targetNode
]

{ #category : 'as yet unclassified' }
RhizomeTest >> testHandlesKeyDistinguishesNodesOnSameAndOtherHosts [
	| winnerHost winnerImage otherImageSameHost otherHost otherHostImage |
	cluster hosts do: [ :host | host addNodeWithPort: 10000; addNodeWithPort: 20000 ].
	winnerHost := cluster hostNameForKey: 'db-1'.
	winnerImage := winnerHost resolveNodeForKey: 'db-1'.
	otherImageSameHost := winnerHost nodes detect: [ :each | each ~~ winnerImage ].
	otherHost := cluster hosts detect: [ :each | each ~~ winnerHost ].
	otherHostImage := otherHost nodes first.
	self assert: (winnerImage handlesKey: 'db-1').
	self deny: (otherImageSameHost handlesKey: 'db-1').
	self deny: (otherHostImage handlesKey: 'db-1')
]

{ #category : 'as yet unclassified' }
RhizomeTest >> testLocalNodeStartsAndStopsItsPeriodicWork [
	"Builds the RZLocalNode directly: RZHost>>nodeClass answers the
	abstract RZNode for local and remote hosts alike, so addNodeWithPort:
	would not give us a local one."
	| image |
	image := RZLocalNode port: 10000.
	cluster localHost addNode: image.
	self deny: image isRunning.
	image start.
	self assert: image isRunning.
	image stop.
	self deny: image isRunning
]

{ #category : 'as yet unclassified' }
RhizomeTest >> testResolveNodeForKeyIsDeterministicAndUsesBothNodes [
	| host imageCounts keys |
	cluster hosts do: [ :host | host addNodeWithPort: 10000; addNodeWithPort: 20000 ].
	host := cluster localHost.
	keys := (1 to: 30) collect: [ :i | 'db-', i printString ].
	self assert: (keys allSatisfy: [ :k | (host resolveNodeForKey: k) == (host resolveNodeForKey: k) ]).
	imageCounts := (keys collect: [ :k | (host resolveNodeForKey: k) port ]) asSet.
	self assert: imageCounts size equals: 2
]

{ #category : 'tests' }
RhizomeTest >> testResolveReplicaSet [
	| set |
	cluster hosts do: [ :host | host addNodeWithPort: 10000 ].
	set := cluster replicaSetForKey: '012345'.
	self assert: set size equals: 3.
	self assert: cluster hosts first equals: cluster localHost
]
