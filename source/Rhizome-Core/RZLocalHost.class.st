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

{ #category : 'accessing' }
RZLocalHost >> databaseLocator [
	^ databaseLocator ifNil: [ 
		databaseLocator := self defaultDatabaseLocator ]
]

{ #category : 'as yet unclassified' }
RZLocalHost >> defaultDatabaseLocator [
	^ RZSimpleDatabaseLocator new
		host: self;
		yourself 
]

{ #category : 'testing' }
RZLocalHost >> isLocalHost [
	^ true
]

{ #category : 'as yet unclassified' }
RZLocalHost >> localNode [
	^ nodes detect: [ :each | each isKindOf: RZLocalNode ]
]

{ #category : 'accessing' }
RZLocalHost >> network [
	^ cluster network
]

{ #category : 'as yet unclassified' }
RZLocalHost >> registerHost [
	self network registerHost: self
]

{ #category : 'as yet unclassified' }
RZLocalHost >> registerOnPort: anInteger [ 
	"create a REST server with the port and add a node
	with the same setting so we can know which node we are"
	| node |
	node := RZLocalNode port: anInteger.
	self addNode: node.
	(self network addressAt: address) at: anInteger put: node server 
]

{ #category : 'accessing' }
RZLocalHost >> start [
	self server start
]

{ #category : 'accessing' }
RZLocalHost >> stop [ 
	self server stop
]
