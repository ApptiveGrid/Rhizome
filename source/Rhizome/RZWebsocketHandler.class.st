Class {
	#name : #RZWebsocketHandler,
	#superclass : #Object,
	#instVars : [
		'continent'
	],
	#category : #Rhizome
}

{ #category : #'as yet unclassified' }
RZWebsocketHandler >> continent: aContinent [ 
	continent := aContinent 
]

{ #category : #accessing }
RZWebsocketHandler >> handleMessage: message [
	| record stream objectId |
	Transcript show: 'handleMessage: '; cr.
	stream := message readStream.
	objectId := SoilObjectId readFrom: stream.
	"record := SoilPersistentClusterVersion readFrom: stream."
	Transcript show: 'storing bytes for ', objectId printString; cr.
	self soil objectRepository at: objectId put: stream upToEnd.
	^ 'OK'
]

{ #category : #public }
RZWebsocketHandler >> handleRequest: aZnRequest [ 
	Transcript show: 'got request: ', aZnRequest printString; cr.
	^ self value: aZnRequest 
]

{ #category : #accessing }
RZWebsocketHandler >> soil [
	^ continent soil
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
