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
	| targetVirtualNode |
	network checkDeliverableTo: url host.
	targetVirtualNode := (network virtualNodeWithAddress: url host port: url port).
	response := targetVirtualNode handleRequest: (self request method: #GET)
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> network: aRZDevsSimulatedNetwork [
	network := aRZDevsSimulatedNetwork
]

{ #category : 'as yet unclassified' }
RZDevsZincClient >> post [
	| targetVirtualNode |
	network checkDeliverableTo: url host.
	targetVirtualNode := (network virtualNodeWithAddress: url host port: url port).
	response := targetVirtualNode handleRequest: (self request method: #POST)
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
