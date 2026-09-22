Class {
	#name : 'RZDevsZincClient',
	#superclass : 'Object',
	#instVars : [
		'url',
		'network',
		'response',
		'entity'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZDevsZincClient >> entity: aZnByteArrayEntity [
	entity := aZnByteArrayEntity
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> get [
	| targetNode |
	network checkDeliverableTo: url host.
	targetNode := (network nodeWithAddress: url host port: url port).
	response := targetNode handleRequest: (self request method: #GET)
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> network: aRZDevsSimulatedNetwork [
	network := aRZDevsSimulatedNetwork
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> post [
	| targetNode |
	network checkDeliverableTo: url host.
	targetNode := (network nodeWithAddress: url host port: url port).
	response := targetNode handleRequest: (self request method: #POST)
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> request [
	| request |
	request := ZnRequest empty
		url: url;
		yourself.
	entity ifNotNil: [
		request entity: entity ].
	^ request
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> response [
	^ response
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> url: aZnUrl [
	url := aZnUrl
]
