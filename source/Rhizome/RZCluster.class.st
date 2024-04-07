Class {
	#name : #RZCluster,
	#superclass : #Object,
	#instVars : [
		'localAddress',
		'nodes',
		'placementStrategy'
	],
	#category : #Rhizome
}

{ #category : #adding }
RZCluster >> addNode: aRZNode [ 
	aRZNode cluster: self.
	nodes add: aRZNode 
]

{ #category : #'as yet unclassified' }
RZCluster >> buildNodesFromList: aCollection [ 
	aCollection do: [ :assoc | 
		self addNode: ((assoc value = localAddress)
			ifTrue: [  RZLocalNode name: assoc key address: assoc value ]
			ifFalse: [ RZNode name: assoc key address: assoc value ]) ]
]

{ #category : #'as yet unclassified' }
RZCluster >> defaultPlacementStrategy [
	^ RZRendezvousHashingStrategy new 
]

{ #category : #initialization }
RZCluster >> initialize [ 
	super initialize.
	nodes := OrderedCollection new
]

{ #category : #accessing }
RZCluster >> localAddress: aString [ 
	localAddress := aString
]

{ #category : #'as yet unclassified' }
RZCluster >> localNode [
	^ self nodeWithAddress: localAddress 
]

{ #category : #'as yet unclassified' }
RZCluster >> nodeNameForKey: aString [ 
	^ self nodeWithName: (self placementStrategy nodeNameForKey: aString)  
]

{ #category : #'private - tree building' }
RZCluster >> nodeNamed: aString [ 
	^ nodes detect: [ :each | each hasName: aString ]
]

{ #category : #'as yet unclassified' }
RZCluster >> nodeNames [
	^ nodes collect: #name
]

{ #category : #'as yet unclassified' }
RZCluster >> nodeWithAddress: anAddress [ 
	^ nodes 
		detect: [ :each | each address = anAddress ]
		ifNone: [ nil ]
]

{ #category : #'as yet unclassified' }
RZCluster >> nodeWithAddress: anAddress andPort: aPort [ 
	^ nodes 
		detect: [ :each | each address = anAddress and: [ each port = aPort ] ]
		ifNone: [ nil ]
]

{ #category : #'flow interface' }
RZCluster >> nodeWithName: aString [ 
	^ nodes detect: [ :node | node name = aString  ]
]

{ #category : #accessing }
RZCluster >> nodes [
	^ nodes
]

{ #category : #accessing }
RZCluster >> nodes: aCollection [ 
	nodes := aCollection 
]

{ #category : #'as yet unclassified' }
RZCluster >> partitioner [
	self shouldBeImplemented.
]

{ #category : #'as yet unclassified' }
RZCluster >> placementStrategy [
	^ placementStrategy ifNil: [ 
		placementStrategy := self defaultPlacementStrategy
			cluster: self;
			yourself ]
]

{ #category : #'as yet unclassified' }
RZCluster >> replicaSetForKey: aString [ 
	| replicaSet |
	replicaSet := RZReplicaSet new.
	(self placementStrategy nodeNamesForKey: aString) do: [ :name |
		replicaSet addReplica: (RZReplica new 
			virtualNode: ((self nodeWithName: name) resolveVirtualNodeForKey: aString) ) ].
	^ replicaSet 
]
