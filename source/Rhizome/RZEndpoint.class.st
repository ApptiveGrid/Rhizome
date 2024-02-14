Class {
	#name : #RZEndpoint,
	#superclass : #Object,
	#instVars : [
		'server',
		'basePath',
		'cluster',
		'databaseLocator'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZEndpoint >> address: aString [ 
	self server address: aString
]

{ #category : #accessing }
RZEndpoint >> basePath [
	^ basePath
]

{ #category : #accessing }
RZEndpoint >> basePath: aString [ 
	basePath := aString asFileReference 
]

{ #category : #'as yet unclassified' }
RZEndpoint >> cluster: aRZCluster [ 
	cluster := aRZCluster 
]

{ #category : #'as yet unclassified' }
RZEndpoint >> createDatabaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifTrue: [ Error signal: 'database already exists' ].
	^ (Soil path: path)
		initializeFilesystem;
		yourself
]

{ #category : #accessing }
RZEndpoint >> databaseLocator [
	^ databaseLocator ifNil: [ 
		databaseLocator := self defaultDatabaseLocator ]
]

{ #category : #accessing }
RZEndpoint >> databaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifFalse: [ Error signal: 'database not found at ', path printString ].
	^ Soil path: path
]

{ #category : #accessing }
RZEndpoint >> databaseWithId: aString ifAbsent: aBlock [ 
	| path |
	path := self databaseLocator pathForId: aString.
	^ path exists 
		ifTrue: [ Soil path: path ]
		ifFalse: aBlock 
]

{ #category : #'as yet unclassified' }
RZEndpoint >> defaultDatabaseLocator [
	^ RZSimpleDatabaseLocator new
		endpoint: self;
		yourself 
]

{ #category : #'instance creation' }
RZEndpoint >> newRendezvousHashing [
	^ RZRendezvousHashing new 
		nodes: cluster nodes.
]

{ #category : #accessing }
RZEndpoint >> port: anInteger [ 
	self server port: anInteger 
]

{ #category : #accessing }
RZEndpoint >> server [
	^ server ifNil: [ 
		server := RZRestServer new
			endpoint: self;
			yourself ]
]

{ #category : #accessing }
RZEndpoint >> start [
	self server start
]

{ #category : #accessing }
RZEndpoint >> stop [ 
	self server stop
]
