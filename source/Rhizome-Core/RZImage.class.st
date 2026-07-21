Class {
	#name : 'RZImage',
	#superclass : 'Object',
	#instVars : [
		'port',
		'node'
	],
	#category : 'Rhizome-Core-Objects',
	#package : 'Rhizome-Core',
	#tag : 'Objects'
}

{ #category : 'accessing' }
RZImage class >> port: anInteger [ 
	^ self new 
		port: anInteger 
]

{ #category : 'accessing' }
RZImage >> address [
	^ node address
]

{ #category : 'public - layout' }
RZImage >> cluster [
	^ node cluster 
]

{ #category : 'as yet unclassified' }
RZImage >> handlesKey: aString [ 
	^ (node resolveNodeForKey: aString) == node
		and: [ (node resolveVirtualNodeForKey: aString) == self ]
]

{ #category : 'testing' }
RZImage >> isLocalNode [
	^ node isLocal
]

{ #category : 'testing' }
RZImage >> isLocalVirtualNode [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RZImage >> node [
	^ node
]

{ #category : 'accessing' }
RZImage >> node: aRZNode [ 
	node := aRZNode 
]

{ #category : 'accessing' }
RZImage >> port [
	^ port
]

{ #category : 'accessing' }
RZImage >> port: anInteger [ 
	port := anInteger
]

{ #category : 'printing' }
RZImage >> printOn: aStream [ 
	aStream << 'port: ' << port asString.
	aStream << ', '.
	node printOn: aStream
]

{ #category : 'as yet unclassified' }
RZImage >> targetVirtualNodeFor: aString [ 
	^ (self handlesKey: aString)
		ifTrue: [ self ]
		ifFalse: [ (node resolveNodeForKey: aString) resolveVirtualNodeForKey: aString  ] 
]
