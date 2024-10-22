Class {
	#name : #RZSimulatedZincClient,
	#superclass : #Object,
	#instVars : [
		'url',
		'network',
		'response',
		'entity'
	],
	#category : #'Rhizome-Simulator'
}

{ #category : #accessing }
RZSimulatedZincClient >> entity: aZnByteArrayEntity [ 
	entity := aZnByteArrayEntity  
]

{ #category : #public }
RZSimulatedZincClient >> get [
	| targetVirtualNode |
	targetVirtualNode := (network virtualNodeWithAddress: url host port: url port).
	response := targetVirtualNode handleRequest: (self request method: #GET) 
]

{ #category : #accessing }
RZSimulatedZincClient >> network: aRZSimulatedNetwork [ 
	network := aRZSimulatedNetwork 
]

{ #category : #public }
RZSimulatedZincClient >> post [
	| targetVirtualNode |
	targetVirtualNode := (network virtualNodeWithAddress: url host port: url port).
	response := targetVirtualNode handleRequest: (self request method: #POST ) 
]

{ #category : #accessing }
RZSimulatedZincClient >> request [
	| request |
	request := ZnRequest empty 
		url: url;
		yourself.
	entity ifNotNil: [ 
		request entity: entity ].
	^ request 
]

{ #category : #accessing }
RZSimulatedZincClient >> response [
	^ response
]

{ #category : #accessing }
RZSimulatedZincClient >> url: aZnUrl [ 
	url := aZnUrl 
]
