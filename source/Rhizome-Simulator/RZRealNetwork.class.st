Class {
	#name : 'RZRealNetwork',
	#superclass : 'RZNetwork',
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZRealNetwork >> newWebSocketTo: aHost port: aPort [
	^ ZnWebSocket to: 'ws://', aHost, ':', aPort asString, '/ws'
]
