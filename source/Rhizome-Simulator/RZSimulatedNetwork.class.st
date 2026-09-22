Class {
	#name : 'RZSimulatedNetwork',
	#superclass : 'RZNetwork',
	#instVars : [
		'addresses'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> addressAt: aString [ 
	^ addresses at: aString 
]

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> announce: aRZLocalNode to: aString [ 
	(addresses at: aString) values do: [ :each | 
		(each cluster hostWithAddress: aRZLocalNode host address)
				addNodeWithPort: aRZLocalNode port ]
]

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> hosts [
	^ addresses values
]

{ #category : 'initialization' }
RZSimulatedNetwork >> initialize [ 
	super initialize.
	addresses := Dictionary new
]

{ #category : 'instance creation' }
RZSimulatedNetwork >> newHttpClient [
	^ RZSimulatedZincClient new
		network: self;
		yourself
]

{ #category : 'instance creation' }
RZSimulatedNetwork >> newRestServer [
	^ RZSimulatedRestServer new
]

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> newWebSocketTo: aHost port: aPort [
	| targetServer handler |
	targetServer := self nodeWithAddress: aHost port: aPort.
	handler := RZWebsocketHandler new endpoint: targetServer node host.
	^ RZSimulatedWebSocket new handler: handler; yourself
]

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> nodeWithAddress: aString port: aNumber [ 
	^ (addresses at: aString) at: aNumber  
]

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> registerCluster: cluster [ 
	cluster hosts do: [ :host |
		host isLocalHost ifTrue: [  
			self registerHost: host ] ].
]

{ #category : 'as yet unclassified' }
RZSimulatedNetwork >> registerHost: aRZHost [ 
	| host |
	host := addresses at: aRZHost address ifAbsentPut: [ Dictionary new ].
	"host at: aRZHost server port put: aRZHost server"
]
