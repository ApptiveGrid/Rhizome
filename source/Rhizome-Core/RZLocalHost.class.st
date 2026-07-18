Class {
	#name : 'RZLocalHost',
	#superclass : 'RZHost',
	#instVars : [
		'basePath',
		'databaseLocator'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZLocalHost >> basePath [
	^ basePath
]

{ #category : 'accessing' }
RZLocalHost >> basePath: aString [ 
	basePath := aString asFileReference 
]

{ #category : 'as yet unclassified' }
RZLocalHost >> cluster: aRZCluster [ 
	cluster := aRZCluster 
]

{ #category : 'as yet unclassified' }
RZLocalHost >> createDatabaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifTrue: [ Error signal: 'database already exists' ].
	^ (Soil path: path)
		initializeFilesystem;
		yourself
]

{ #category : 'accessing' }
RZLocalHost >> databaseLocator [
	^ databaseLocator ifNil: [ 
		databaseLocator := self defaultDatabaseLocator ]
]

{ #category : 'accessing' }
RZLocalHost >> databaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifFalse: [ Error signal: 'database not found at ', path printString ].
	^ Soil path: path
]

{ #category : 'accessing' }
RZLocalHost >> databaseWithId: aString ifAbsent: aBlock [ 
	| path |
	path := self databaseLocator pathForId: aString.
	^ path exists 
		ifTrue: [ Soil path: path ]
		ifFalse: aBlock 
]

{ #category : 'as yet unclassified' }
RZLocalHost >> defaultDatabaseLocator [
	^ RZSimpleDatabaseLocator new
		node: self;
		yourself 
]

{ #category : 'testing' }
RZLocalHost >> isLocalNode [
	^ true
]

{ #category : 'as yet unclassified' }
RZLocalHost >> localVirtualNode [
	^ virtualNodes detect: [ :each | each isKindOf: RZLocalImage ]
]

{ #category : 'accessing' }
RZLocalHost >> network [
	^ cluster network
]

{ #category : 'as yet unclassified' }
RZLocalHost >> registerNode [
	self network registerNode: self
]

{ #category : 'as yet unclassified' }
RZLocalHost >> registerOnPort: anInteger [ 
	"create a REST server with the port and add a virtual node
	with the same setting so we can know which virtual node we are"
	| virtualNode |
	virtualNode := RZLocalImage port: anInteger.
	self addVirtualNode: virtualNode.
	(self network addressAt: address) at: anInteger put: virtualNode server 
]

{ #category : 'accessing' }
RZLocalHost >> start [
	self server start
]

{ #category : 'accessing' }
RZLocalHost >> stop [ 
	self server stop
]
