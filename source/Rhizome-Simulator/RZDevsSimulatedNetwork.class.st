Class {
	#name : 'RZDevsSimulatedNetwork',
	#superclass : 'RZNetwork',
	#instVars : [
		'localAddress',
		'addresses',
		'router'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork class >> forAddress: aString addresses: aDictionary router: aRouter [
	^ self new
		localAddress: aString;
		addresses: aDictionary;
		router: aRouter;
		yourself
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> addressAt: aString [
	^ addresses at: aString
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> addresses [
	^ addresses
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> addresses: aDictionary [
	addresses := aDictionary
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> announce: aRZLocalVirtualNode to: aString [
	(addresses at: aString) values do: [ :each |
		(each cluster nodeWithAddress: aRZLocalVirtualNode node address)
			addVirtualNodeWithPort: aRZLocalVirtualNode port ]
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> checkDeliverableTo: aRemoteAddress [
	| probe |
	probe := DEVSNetworkMessage new
		sourceAddress: localAddress;
		destinationAddress: aRemoteAddress;
		yourself.
	(router shouldDropMessage: probe) ifTrue: [
		^ ConnectionClosed new
			signal: 'simulated network failure from ', localAddress asString, ' to ', aRemoteAddress asString ]
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> dropNextNMessagesBetween: addr1 and: addr2 count: n [
	router dropNextNMessagesBetween: addr1 and: addr2 count: n
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> healPartition: addr1 and: addr2 [
	router healPartition: addr1 and: addr2
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> hosts [
	^ addresses values
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> initialize [
	super initialize.
	addresses := Dictionary new
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> localAddress [
	^ localAddress
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> localAddress: aString [
	localAddress := aString
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> newHttpClient [
	^ RZDevsZincClient new
		network: self;
		yourself
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> newRestServer [
	^ RZSimulatedRestServer new
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> newWebSocketTo: aHost port: aPort [
	| targetServer handler |
	self checkDeliverableTo: aHost.
	targetServer := self virtualNodeWithAddress: aHost port: aPort.
	handler := RZWebsocketHandler new endpoint: targetServer virtualNode node.
	^ RZDevsWebSocket new
		handler: handler;
		network: self;
		remoteAddress: aHost;
		yourself
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> registerCluster: cluster [
	cluster nodes do: [ :node |
		node isLocalNode ifTrue: [
			self registerNode: node ] ]
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> registerNode: aRZHost [
	addresses at: aRZHost address ifAbsentPut: [ Dictionary new ]
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> router [
	^ router
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> router: aRZDevsNetworkRouter [
	router := aRZDevsNetworkRouter
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> simulateNetworkPartition: addr1 and: addr2 [
	router simulateNetworkPartition: addr1 and: addr2
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> virtualNodeWithAddress: aString port: aNumber [
	^ (addresses at: aString) at: aNumber
]
