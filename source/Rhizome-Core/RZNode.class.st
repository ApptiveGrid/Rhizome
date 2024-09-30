Class {
	#name : #RZNode,
	#superclass : #Object,
	#instVars : [
		'name',
		'address',
		'virtualNodes',
		'cluster'
	],
	#category : #'Rhizome-Core'
}

{ #category : #accessing }
RZNode class >> name: aString [ 
	^ self new 
		name: aString 
]

{ #category : #'as yet unclassified' }
RZNode class >> name: aString address: addressString [ 
	^ self new 
		name: aString;
		address: addressString
]

{ #category : #adding }
RZNode >> addVirtualNode: aRZImage [ 
	aRZImage node: self.
	virtualNodes add: aRZImage 
]

{ #category : #adding }
RZNode >> addVirtualNodeWithPort: anInteger [ 
	self addVirtualNode: (self virtualNodeClass port: anInteger)
]

{ #category : #accessing }
RZNode >> address [
	^ address
]

{ #category : #accessing }
RZNode >> address: aString [ 
	address := aString
]

{ #category : #accessing }
RZNode >> cluster [
	^ cluster
]

{ #category : #accessing }
RZNode >> cluster: aRZCluster [ 
	cluster := aRZCluster
]

{ #category : #testing }
RZNode >> hasName: aString [ 
	^ name = aString 
]

{ #category : #initialization }
RZNode >> initialize [ 
	super initialize.
	virtualNodes := OrderedCollection new
]

{ #category : #testing }
RZNode >> isLocalNode [
	self subclassResponsibility 
]

{ #category : #accessing }
RZNode >> name [
	^ name
]

{ #category : #accessing }
RZNode >> name: aString [ 
	name := aString 
]

{ #category : #accessing }
RZNode >> portAt: aNumber [ 
self halt.
	^ virtualNodes detect: [ :each | each port = aNumber  ]
]

{ #category : #printing }
RZNode >> printOn: aStream [ 
	aStream <<  name asString << '['.
	address printOn: aStream.
	aStream << ']'
]

{ #category : #'as yet unclassified' }
RZNode >> resolveNodeForKey: aString [ 
	^ cluster nodeNameForKey: aString 
]

{ #category : #'as yet unclassified' }
RZNode >> resolveVirtualNodeForKey: aString [ 
	virtualNodes ifEmpty: [ Error signal: 'node ', name , ' has no virtual nodes' ].
	^ virtualNodes anyOne
]

{ #category : #adding }
RZNode >> virtualNodeClass [
	^ RZVirtualNode
]

{ #category : #'as yet unclassified' }
RZNode >> virtualNodeWithPort: anInteger [ 
	^ virtualNodes detect: [ :vnode | vnode port = anInteger ]
]

{ #category : #accessing }
RZNode >> virtualNodes [
	^ virtualNodes
]
