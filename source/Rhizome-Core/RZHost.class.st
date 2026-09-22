Class {
	#name : 'RZHost',
	#superclass : 'Object',
	#instVars : [
		'name',
		'address',
		'cluster',
		'nodes'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZHost class >> name: aString [ 
	^ self new 
		name: aString 
]

{ #category : 'as yet unclassified' }
RZHost class >> name: aString address: addressString [ 
	^ self new 
		name: aString;
		address: addressString
]

{ #category : 'adding' }
RZHost >> addNode: aRZNode [ 
	aRZNode host: self.
	nodes add: aRZNode 
]

{ #category : 'adding' }
RZHost >> addNodeWithPort: anInteger [ 
	self addNode: (self nodeClass port: anInteger)
]

{ #category : 'accessing' }
RZHost >> address [
	^ address
]

{ #category : 'accessing' }
RZHost >> address: aString [ 
	address := aString
]

{ #category : 'accessing' }
RZHost >> cluster [
	^ cluster
]

{ #category : 'accessing' }
RZHost >> cluster: aRZCluster [ 
	cluster := aRZCluster
]

{ #category : 'testing' }
RZHost >> hasName: aString [ 
	^ name = aString 
]

{ #category : 'initialization' }
RZHost >> initialize [ 
	super initialize.
	nodes := OrderedCollection new
]

{ #category : 'testing' }
RZHost >> isLocalHost [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RZHost >> name [
	^ name
]

{ #category : 'accessing' }
RZHost >> name: aString [ 
	name := aString 
]

{ #category : 'adding' }
RZHost >> nodeClass [
	^ RZNode
]

{ #category : 'as yet unclassified' }
RZHost >> nodeWithPort: anInteger [ 
	^ nodes detect: [ :each | each port = anInteger ]
]

{ #category : 'accessing' }
RZHost >> nodes [
	^ nodes
]

{ #category : 'accessing' }
RZHost >> portAt: aNumber [
	^ nodes detect: [ :each | each port = aNumber  ]
]

{ #category : 'printing' }
RZHost >> printOn: aStream [ 
	aStream <<  name asString << '['.
	address printOn: aStream.
	aStream << ']'
]

{ #category : 'as yet unclassified' }
RZHost >> resolveHostForKey: aString [ 
	^ cluster hostNameForKey: aString 
]

{ #category : 'as yet unclassified' }
RZHost >> resolveNodeForKey: aString [ 
	| hashes |
	nodes ifEmpty: [ Error signal: 'host ', name , ' has no nodes' ].
	hashes := nodes collect: [ :each | 
		(NCHMurmur3 withSeed: 0) hash: (each port asString, aString) asByteArray ].
	^ nodes at: (hashes indexOf: hashes sorted last)
]
