Class {
	#name : #RZLocalNode,
	#superclass : #RZNode,
	#instVars : [
		'basePath',
		'databaseLocator'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZLocalNode >> basePath [
	^ basePath
]

{ #category : #accessing }
RZLocalNode >> basePath: aString [ 
	basePath := aString asFileReference 
]

{ #category : #'as yet unclassified' }
RZLocalNode >> cluster: aRZCluster [ 
	cluster := aRZCluster 
]

{ #category : #'as yet unclassified' }
RZLocalNode >> createDatabaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifTrue: [ Error signal: 'database already exists' ].
	^ (Soil path: path)
		initializeFilesystem;
		yourself
]

{ #category : #accessing }
RZLocalNode >> databaseLocator [
	^ databaseLocator ifNil: [ 
		databaseLocator := self defaultDatabaseLocator ]
]

{ #category : #accessing }
RZLocalNode >> databaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifFalse: [ Error signal: 'database not found at ', path printString ].
	^ Soil path: path
]

{ #category : #accessing }
RZLocalNode >> databaseWithId: aString ifAbsent: aBlock [ 
	| path |
	path := self databaseLocator pathForId: aString.
	^ path exists 
		ifTrue: [ Soil path: path ]
		ifFalse: aBlock 
]

{ #category : #'as yet unclassified' }
RZLocalNode >> defaultDatabaseLocator [
	^ RZSimpleDatabaseLocator new
		node: self;
		yourself 
]

{ #category : #testing }
RZLocalNode >> isLocalNode [
	^ true
]

{ #category : #'as yet unclassified' }
RZLocalNode >> localVirtualNode [
	^ virtualNodes detect: [ :each | each isKindOf: RZLocalVirtualNode ]
]

{ #category : #accessing }
RZLocalNode >> network [
	^ cluster network
]

{ #category : #'as yet unclassified' }
RZLocalNode >> registerNode [
	self network registerNode: self
]

{ #category : #'as yet unclassified' }
RZLocalNode >> registerOnPort: anInteger [ 
	"create a REST server with the port and add a virtual node
	with the same setting so we can know which virtual node we are"
	| virtualNode |
	virtualNode := RZLocalVirtualNode port: anInteger.
	self addVirtualNode: virtualNode.
	(self network addressAt: address) at: anInteger put: virtualNode server 
]

{ #category : #accessing }
RZLocalNode >> start [
	self server start
]

{ #category : #accessing }
RZLocalNode >> stop [ 
	self server stop
]
