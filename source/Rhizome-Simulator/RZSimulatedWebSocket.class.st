Class {
	#name : 'RZSimulatedWebSocket',
	#superclass : 'Object',
	#instVars : [
		'handler',
		'lastResponse'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZSimulatedWebSocket >> handler: aRZWebsocketHandler [
	handler := aRZWebsocketHandler
]

{ #category : 'as yet unclassified' }
RZSimulatedWebSocket >> readMessage [
	^ lastResponse
]

{ #category : 'as yet unclassified' }
RZSimulatedWebSocket >> sendMessage: aString [
	"Mirrors ZnWebSocket>>sendMessage: - synchronous in-process dispatch
	instead of a real frame write, matching how RZSimulatedZincClient
	handles the HTTP side."
	lastResponse := handler handleMessage: aString
]
