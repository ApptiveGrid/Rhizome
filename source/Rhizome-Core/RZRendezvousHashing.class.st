Class {
	#name : #RZRendezvousHashing,
	#superclass : #Object,
	#instVars : [
		'nodes',
		'prefix'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZRendezvousHashing >> first: anInteger [ 
	| hash weights |
	hash := NCHMurmur3 withSeed: 0.
	weights := (nodes collect: [ :node |
		(hash hash: (prefix, node name) asByteArray) -> node ])asDictionary .
	^ (weights keys sorted reverse first: (3 min: nodes size)) collect: [ :key | weights at: key ] 
]

{ #category : #accessing }
RZRendezvousHashing >> nodes: aCollection [ 
	nodes := aCollection 
]

{ #category : #accessing }
RZRendezvousHashing >> prefix: aString [ 
	prefix := aString 
]
