Class {
	#name : #RZLocalNode,
	#superclass : #RZNode,
	#instVars : [
		'server',
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
	^ virtualNodes detect: [ :each | each port = server port ]
]

{ #category : #accessing }
RZLocalNode >> port: anInteger [ 
	self server port: anInteger 
]

{ #category : #'as yet unclassified' }
RZLocalNode >> registerOnPort: anInteger [ 
	"create a REST server with the port and add a virtual node
	with the same setting so we can know which virtual node we are"
	self server port: anInteger.
	self addVirtualNode: (RZLocalVirtualNode port: anInteger)
]

{ #category : #accessing }
RZLocalNode >> server [
	^ server ifNil: [ 
		server := cluster network newRestServer
			node: self;
			yourself ]
]

{ #category : #accessing }
RZLocalNode >> start [
	self server start
]

{ #category : #accessing }
RZLocalNode >> stop [ 
	self server stop
]
