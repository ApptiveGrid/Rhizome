Class {
	#name : #RZCluster,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #Rhizome
}

{ #category : #adding }
RZCluster >> addAddresses: aCollection [ 
	self shouldBeImplemented.
]

{ #category : #adding }
RZCluster >> addNode: aRZNode [ 
	nodes add: aRZNode 
]

{ #category : #initialization }
RZCluster >> initialize [ 
	super initialize.
	nodes := OrderedCollection new
]

{ #category : #'private - tree building' }
RZCluster >> nodeNamed: aString [ 
	^ nodes detect: [ :each | each hasName: aString ]
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

{ #category : #accessing }
RZCluster >> nodes [
	^ nodes
]

{ #category : #accessing }
RZCluster >> nodes: aCollection [ 
	nodes := aCollection 
]
