Class {
	#name : #RZRestServer,
	#superclass : #Object,
	#instVars : [
		'port',
		'server',
		'address',
		'endpoint'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZRestServer >> address: aString [ 
	address := aString
]

{ #category : #running }
RZRestServer >> apiHandler [ 
	^ RZRestServerDelegate new 
		endpoint: self endpoint;
		uriSpace: (ZnCallHierarchyRestUriSpace new
			rootClass: RZRestCall)
]

{ #category : #running }
RZRestServer >> apiPrefix [
	^ #cluster
]

{ #category : #running }
RZRestServer >> buildServer [
	^ (ZnServer on: self port)
	   delegate: self handler;
	   logLevel: 1;
		yourself
]

{ #category : #accessing }
RZRestServer >> defaultPort [
	^ 4850
]

{ #category : #accessing }
RZRestServer >> endpoint [
	^ endpoint  
]

{ #category : #accessing }
RZRestServer >> endpoint: anObject [

	endpoint := anObject
]

{ #category : #running }
RZRestServer >> handler [ 
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
RZRestServer >> port [
	^ port ifNil: [ 
		port := self defaultPort ]
]

{ #category : #accessing }
RZRestServer >> port: aNumber [ 
	port := aNumber 
]

{ #category : #accessing }
RZRestServer >> start [
	server := self buildServer.
	server debugMode: true.
	server start
]

{ #category : #accessing }
RZRestServer >> stop [
	server ifNotNil: [ 
		server stop ].

]

{ #category : #running }
RZRestServer >> websocketHandler [
	^ ZnWebSocketDelegate handler: (RZWebsocketHandler new endpoint: self endpoint)
]
