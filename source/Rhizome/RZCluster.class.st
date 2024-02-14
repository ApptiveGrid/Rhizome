Class {
	#name : #RZCluster,
	#superclass : #Object,
	#instVars : [
		'nodes'
	],
	#category : #Rhizome
}

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
