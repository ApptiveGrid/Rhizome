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
RhizomeTest >> localAddress [
	^ '127.0.0.1'
]

{ #category : 'accessing' }
RhizomeTest >> nodeList [ 
	^ { 
		#node1 -> '127.0.0.1'. 
		#node2 -> '127.0.0.2'. 
		#node3 -> '127.0.0.3'.
		#node4 -> '127.0.0.4'. 
		#node5 -> '127.0.0.5' 
		}
]

{ #category : 'running' }
RhizomeTest >> setUp [ 
	super setUp.
	cluster := RZCluster new 
		localAddress: self localAddress;
		buildNodesFromList: self nodeList 
]

{ #category : 'tests' }
RhizomeTest >> testAddVirtualNode [ 
	cluster localNode addVirtualNodeWithPort: 10000.
	self assert: cluster localNode virtualNodes size equals: 1
]

{ #category : 'tests' }
RhizomeTest >> testDispatchToVirtualNode [ 
	| virtualNode targetNode |
	cluster nodes do: [ :node | node addVirtualNodeWithPort: 10000 ].
	virtualNode := cluster localNode virtualNodeWithPort: 10000.
	targetNode := virtualNode targetVirtualNodeFor: '012345'.
	self assert: virtualNode equals: targetNode
]

{ #category : 'as yet unclassified' }
RhizomeTest >> testHandlesKeyDistinguishesImagesOnSameAndOtherHosts [
	| winnerHost winnerImage otherImageSameHost otherHost otherHostImage |
	cluster nodes do: [ :node | node addVirtualNodeWithPort: 10000; addVirtualNodeWithPort: 20000 ].
	winnerHost := cluster nodeNameForKey: 'db-1'.
	winnerImage := winnerHost resolveVirtualNodeForKey: 'db-1'.
	otherImageSameHost := winnerHost virtualNodes detect: [ :each | each ~~ winnerImage ].
	otherHost := cluster nodes detect: [ :each | each ~~ winnerHost ].
	otherHostImage := otherHost virtualNodes first.
	self assert: (winnerImage handlesKey: 'db-1').
	self deny: (otherImageSameHost handlesKey: 'db-1').
	self deny: (otherHostImage handlesKey: 'db-1')
]

{ #category : 'as yet unclassified' }
RhizomeTest >> testLocalImageStartsAndStopsItsPeriodicWork [
	"Builds the RZLocalImage directly: RZHost>>virtualNodeClass answers the
	abstract RZImage for local and remote hosts alike, so addVirtualNodeWithPort:
	would not give us a local one."
	| image |
	image := RZLocalImage port: 10000.
	cluster localNode addVirtualNode: image.
	self deny: image isRunning.
	image start.
	self assert: image isRunning.
	image stop.
	self deny: image isRunning
]

{ #category : 'tests' }
RhizomeTest >> testResolveReplicaSet [
	| set |
	cluster nodes do: [ :node | node addVirtualNodeWithPort: 10000 ].
	set := cluster replicaSetForKey: '012345'.
	self assert: set size equals: 3.
	self assert: cluster nodes first equals: cluster localNode
]

{ #category : 'as yet unclassified' }
RhizomeTest >> testResolveVirtualNodeForKeyIsDeterministicAndUsesBothImages [
	| host imageCounts keys |
	cluster nodes do: [ :node | node addVirtualNodeWithPort: 10000; addVirtualNodeWithPort: 20000 ].
	host := cluster localNode.
	keys := (1 to: 30) collect: [ :i | 'db-', i printString ].
	self assert: (keys allSatisfy: [ :k | (host resolveVirtualNodeForKey: k) == (host resolveVirtualNodeForKey: k) ]).
	imageCounts := (keys collect: [ :k | (host resolveVirtualNodeForKey: k) port ]) asSet.
	self assert: imageCounts size equals: 2
]
