Class {
	#name : 'RZHost',
	#superclass : 'Object',
	#instVars : [
		'name',
		'address',
		'virtualNodes',
		'cluster'
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
RZHost >> addVirtualNode: aRZImage [ 
	aRZImage node: self.
	virtualNodes add: aRZImage 
]

{ #category : 'adding' }
RZHost >> addVirtualNodeWithPort: anInteger [ 
	self addVirtualNode: (self virtualNodeClass port: anInteger)
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
	virtualNodes := OrderedCollection new
]

{ #category : 'testing' }
RZHost >> isLocalNode [
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

{ #category : 'accessing' }
RZHost >> portAt: aNumber [
	^ virtualNodes detect: [ :each | each port = aNumber  ]
]

{ #category : 'printing' }
RZHost >> printOn: aStream [ 
	aStream <<  name asString << '['.
	address printOn: aStream.
	aStream << ']'
]

{ #category : 'as yet unclassified' }
RZHost >> resolveNodeForKey: aString [ 
	^ cluster nodeNameForKey: aString 
]

{ #category : 'as yet unclassified' }
RZHost >> resolveVirtualNodeForKey: aString [ 
	| hashes |
	virtualNodes ifEmpty: [ Error signal: 'node ', name , ' has no virtual nodes' ].
	hashes := virtualNodes collect: [ :each | 
		(NCHMurmur3 withSeed: 0) hash: (each port asString, aString) asByteArray ].
	^ virtualNodes at: (hashes indexOf: hashes sorted last)
]

{ #category : 'adding' }
RZHost >> virtualNodeClass [
	^ RZImage
]

{ #category : 'as yet unclassified' }
RZHost >> virtualNodeWithPort: anInteger [ 
	^ virtualNodes detect: [ :vnode | vnode port = anInteger ]
]

{ #category : 'accessing' }
RZHost >> virtualNodes [
	^ virtualNodes
]
