Class {
	#name : 'RZDevsSimulatedNetwork',
	#superclass : 'RZNetwork',
	#instVars : [
		'localAddress',
		'addresses',
		'router',
		'clusterSimulation'
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
RZDevsSimulatedNetwork >> announce: aRZLocalNode to: aString [
	(addresses at: aString) values do: [ :each |
		(each cluster hostWithAddress: aRZLocalNode host address)
			addNodeWithPort: aRZLocalNode port ]
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
	targetServer := self nodeWithAddress: aHost port: aPort.
	handler := RZWebsocketHandler new endpoint: targetServer node host.
	^ RZDevsWebSocket new
		handler: handler;
		network: self;
		remoteAddress: aHost;
		yourself
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> nodeWithAddress: aString port: aNumber [
	^ (addresses at: aString) at: aNumber
]

{ #category : 'accessing' }
RZDevsSimulatedNetwork >> clusterSimulation [
	^ clusterSimulation
]

{ #category : 'accessing' }
RZDevsSimulatedNetwork >> clusterSimulation: anRZDevsClusterSimulation [
	"The one DEVS model the whole cluster runs in. With it, what is sent travels
	through the router in the time of the model; without it, this network behaves as
	it always did and the router is only asked whether it would have dropped the
	message."

	clusterSimulation := anRZDevsClusterSimulation.
	router := anRZDevsClusterSimulation router
]

{ #category : 'sending' }
RZDevsSimulatedNetwork >> deliver: aMessage [
	"A message that came out of the router, on the far side. The request carries
	host and port, so the node it is meant for is found the same way a direct call
	found it."

	| request |
	request := aMessage payload.
	^ (self nodeWithAddress: request url host port: request url port)
		  handleRequest: request
]

{ #category : 'sending' }
RZDevsSimulatedNetwork >> post: anEntity to: aUrl [
	"Hand it to the router and go on. Whether it arrives - and when - is the
	router's business now, which is why this no longer asks #checkDeliverableTo:
	first: a partitioned send is a message that is dropped on the way, not a call
	that refuses to be made.

	Without a cluster simulation this is the old direct call, so a network built the
	old way keeps working."

	clusterSimulation ifNil: [ ^ super post: anEntity to: aUrl ].
	clusterSimulation
		sendFrom: localAddress
		payload: (ZnRequest empty
				 url: aUrl;
				 method: #POST;
				 entity: anEntity;
				 yourself)
		to: aUrl host
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> registerCluster: cluster [
	cluster hosts do: [ :host |
		host isLocalHost ifTrue: [
			self registerHost: host ] ]
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> registerHost: aRZHost [
	addresses at: aRZHost address ifAbsentPut: [ Dictionary new ].
	"and as a host in the model, so that something sent to it has somewhere to
	arrive. Only once per address - several clusters share one model."
	clusterSimulation ifNotNil: [
		clusterSimulation
			hostAt: aRZHost address
			deliverWith: [ :message | self deliver: message ] ]
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> router [
	^ router
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> router: aDEVSFaultInjectingNetworkRouter [
	router := aDEVSFaultInjectingNetworkRouter
]

{ #category : 'as yet unclassified' }
RZDevsSimulatedNetwork >> simulateNetworkPartition: addr1 and: addr2 [
	router simulateNetworkPartition: addr1 and: addr2
]
