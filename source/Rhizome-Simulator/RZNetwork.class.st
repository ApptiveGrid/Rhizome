Class {
	#name : 'RZNetwork',
	#superclass : 'Object',
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZNetwork >> newWebSocketTo: aHost port: aPort [
	^ self subclassResponsibility
]
