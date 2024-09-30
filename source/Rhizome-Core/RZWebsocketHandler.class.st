Class {
	#name : #RZWebsocketHandler,
	#superclass : #Object,
	#instVars : [
		'endpoint',
		'database'
	],
	#category : #'Rhizome-Core'
}

{ #category : #accessing }
RZWebsocketHandler >> database [
	^ database
]

{ #category : #accessing }
RZWebsocketHandler >> database: aSoil [ 
	database := aSoil
]

{ #category : #accessing }
RZWebsocketHandler >> databaseId: aString [ 
	database := endpoint databaseWithId: aString ifAbsent: [ Error signal: 'nope' ] 
]

{ #category : #accessing }
RZWebsocketHandler >> endpoint [
	^ endpoint
]

{ #category : #'as yet unclassified' }
RZWebsocketHandler >> endpoint: anEndpoint [
	endpoint := anEndpoint 
]

{ #category : #accessing }
RZWebsocketHandler >> handleMessage: message [
	| command |
	command := message materialize.
	command executeIn: self.
	^ STON toString: RZSuccess new
]

{ #category : #public }
RZWebsocketHandler >> handleRequest: aZnRequest [ 
	Transcript show: 'got request: ', aZnRequest printString; cr.
	^ self value: aZnRequest 
]

{ #category : #accessing }
RZWebsocketHandler >> soil [
	^ endpoint soil
]

{ #category : #accessing }
RZWebsocketHandler >> value: webSocket [
	"I implement an echo service conversation as a server:
	reading messages and echoing them back until ConnectionClosed"
	
	[
		webSocket runWith: [ :message |
			webSocket logGeneric: 'Received message: ', message printString, ', echoing'.
			webSocket sendMessage: (self handleMessage: message) ] ] 
		on: ConnectionClosed 
		do: [ webSocket logGeneric: 'Ignoring connection close, done' ]
]
