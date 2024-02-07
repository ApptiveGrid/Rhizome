Class {
	#name : #RZTuber,
	#superclass : #Object,
	#instVars : [
		'port',
		'server',
		'path',
		'soil',
		'databaseLocator'
	],
	#category : #Rhizome
}

{ #category : #running }
RZTuber >> apiHandler [ 
	^ RZRestServerDelegate new 
		rhizome: self;
		uriSpace: (ZnCallHierarchyRestUriSpace new
			rootClass: RZTuberRestCall)
]

{ #category : #running }
RZTuber >> apiPrefix [
	^ #cluster
]

{ #category : #running }
RZTuber >> buildServer [
	^ (ZnServer on: self port)
	   delegate: self handler;
	   logLevel: 1;
		yourself
]

{ #category : #accessing }
RZTuber >> buildSoil [
	soil := (Soil path: path) 
		destroy;
		initializeFilesystem.
	
]

{ #category : #'as yet unclassified' }
RZTuber >> databaseLocator [
	^ databaseLocator ifNil: [ 
		databaseLocator := self defaultDatabaseLocator ]
]

{ #category : #'as yet unclassified' }
RZTuber >> databaseWithId: aString [ 
	path := self databaseLocator pathForId: aString.
	self halt.
]

{ #category : #'as yet unclassified' }
RZTuber >> databaseWithId: aString ifAbsent: aBlock [ 
	path := self databaseLocator pathForId: aString.
	^ path exists 
		ifTrue: [ Soil path: path ]
		ifFalse: aBlock 
]

{ #category : #'as yet unclassified' }
RZTuber >> defaultDatabaseLocator [
	^ RZSimpleDatabaseLocator new 
]

{ #category : #accessing }
RZTuber >> defaultPort [
	^ 4850
]

{ #category : #running }
RZTuber >> handler [ 
	| handler |
	handler := ZnPrefixMappingDelegate new
 	   map: self apiPrefix to: self apiHandler;
	   map: #ws to: self websocketHandler.
	"self metricsHandler ifNotNil: [ :metricsHandler |
		 handler map: 'metrics' to: metricsHandler ].
	
	self healthHandler ifNotNil: [ :healthHandler |
		 handler map: 'health' to: healthHandler ].
	
	self replHandler ifNotNil: [ :replHandler |
		handler map: 'repl' to: replHandler ]."
	
	^ handler
	
]

{ #category : #accessing }
RZTuber >> path: aString [ 
	path := aString
]

{ #category : #accessing }
RZTuber >> port [
	^ port ifNil: [ 
		port := self defaultPort ]
]

{ #category : #accessing }
RZTuber >> port: aNumber [ 
	port := aNumber 
]

{ #category : #accessing }
RZTuber >> soil [
	^ soil
]

{ #category : #accessing }
RZTuber >> start [
	self buildSoil.
	server := self buildServer.
	server debugMode: true.
	server start
]

{ #category : #accessing }
RZTuber >> stop [
	server ifNotNil: [ 
		server stop ]
]

{ #category : #running }
RZTuber >> websocketHandler [
	^ ZnWebSocketDelegate handler: (RZWebsocketHandler new continent: self)
]
