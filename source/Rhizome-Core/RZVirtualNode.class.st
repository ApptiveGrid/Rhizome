Class {
	#name : #RZVirtualNode,
	#superclass : #Object,
	#instVars : [
		'port',
		'node'
	],
	#category : #'Rhizome-Core-Objects'
}

{ #category : #accessing }
RZVirtualNode class >> port: anInteger [ 
	^ self new 
		port: anInteger 
]

{ #category : #accessing }
RZVirtualNode >> address [
	^ node address
]

{ #category : #'public - layout' }
RZVirtualNode >> cluster [
	^ node cluster 
]

{ #category : #'as yet unclassified' }
RZVirtualNode >> handlesKey: aString [ 
	^ false
]

{ #category : #testing }
RZVirtualNode >> isLocalNode [
	^ node isLocal
]

{ #category : #testing }
RZVirtualNode >> isLocalVirtualNode [
	self subclassResponsibility 
]

{ #category : #accessing }
RZVirtualNode >> node [
	^ node
]

{ #category : #accessing }
RZVirtualNode >> node: aRZNode [ 
	node := aRZNode 
]

{ #category : #accessing }
RZVirtualNode >> port [
	^ port
]

{ #category : #accessing }
RZVirtualNode >> port: anInteger [ 
	port := anInteger
]

{ #category : #printing }
RZVirtualNode >> printOn: aStream [ 
	aStream << 'port: ' << port asString.
	aStream << ', '.
	node printOn: aStream
]

{ #category : #'as yet unclassified' }
RZVirtualNode >> targetVirtualNodeFor: aString [ 
	^ (self handlesKey: aString)
		ifTrue: [ self ]
		ifFalse: [ (node resolveNodeForKey: aString) resolveVirtualNodeForKey: aString  ] 
]
