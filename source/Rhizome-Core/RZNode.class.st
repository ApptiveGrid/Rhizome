Class {
	#name : 'RZNode',
	#superclass : 'Object',
	#instVars : [
		'port',
		'host'
	],
	#category : 'Rhizome-Core-Objects',
	#package : 'Rhizome-Core',
	#tag : 'Objects'
}

{ #category : 'accessing' }
RZNode class >> port: anInteger [ 
	^ self new 
		port: anInteger 
]

{ #category : 'accessing' }
RZNode >> address [
	^ host address
]

{ #category : 'public - layout' }
RZNode >> cluster [
	^ host cluster 
]

{ #category : 'as yet unclassified' }
RZNode >> handlesKey: aString [ 
	^ (host resolveHostForKey: aString) == host
		and: [ (host resolveNodeForKey: aString) == self ]
]

{ #category : 'accessing' }
RZNode >> host [
	^ host
]

{ #category : 'accessing' }
RZNode >> host: aRZHost [ 
	host := aRZHost 
]

{ #category : 'testing' }
RZNode >> isLocalHost [
	^ host isLocal
]

{ #category : 'testing' }
RZNode >> isLocalNode [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RZNode >> port [
	^ port
]

{ #category : 'accessing' }
RZNode >> port: anInteger [ 
	port := anInteger
]

{ #category : 'printing' }
RZNode >> printOn: aStream [ 
	aStream << 'port: ' << port asString.
	aStream << ', '.
	host printOn: aStream
]

{ #category : 'as yet unclassified' }
RZNode >> targetNodeFor: aString [ 
	^ (self handlesKey: aString)
		ifTrue: [ self ]
		ifFalse: [ (host resolveHostForKey: aString) resolveNodeForKey: aString  ] 
]
