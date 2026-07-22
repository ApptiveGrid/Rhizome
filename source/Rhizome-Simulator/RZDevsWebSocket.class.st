Class {
	#name : 'RZDevsWebSocket',
	#superclass : 'Object',
	#instVars : [
		'handler',
		'lastResponse',
		'network',
		'remoteAddress'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZDevsWebSocket >> handler: aRZWebsocketHandler [
	handler := aRZWebsocketHandler
]

{ #category : 'as yet unclassified' }
RZDevsWebSocket >> network: aRZDevsSimulatedNetwork [
	network := aRZDevsSimulatedNetwork
]

{ #category : 'as yet unclassified' }
RZDevsWebSocket >> readMessage [
	^ lastResponse
]

{ #category : 'as yet unclassified' }
RZDevsWebSocket >> remoteAddress: aString [
	remoteAddress := aString
]

{ #category : 'as yet unclassified' }
RZDevsWebSocket >> sendMessage: aString [
	network checkDeliverableTo: remoteAddress.
	lastResponse := handler handleMessage: aString
]
