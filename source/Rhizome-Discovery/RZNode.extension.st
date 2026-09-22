Extension { #name : 'RZNode' }

{ #category : '*Rhizome-Discovery' }
RZNode >> announceType [
	"Publish what kind of node this is - and nothing else. The first stage of
	discovery carries no stage, no version and no capability; see Rhizome decisions."
	^ gossiper stateAt: self class typeKey put: self type
]

{ #category : '*Rhizome-Discovery' }
RZNode >> discovery [
	^ RZDiscovery on: gossiper
]

{ #category : '*Rhizome-Discovery' }
RZNode >> gossipEndpoint [
	"This node's identity in the discovery: address plus the gossiper's port."
	^ gossiper localEndpoint
]

{ #category : '*Rhizome-Discovery' }
RZNode >> gossiper [
	^ gossiper
]

{ #category : '*Rhizome-Discovery' }
RZNode >> gossiper: aGossiper [
	"Take the gossiper and tell it which address to publish. Left to itself a
	GossipServer resolves its own address through NetNameResolver, which answers
	whatever the machine calls itself - not necessarily the address the others can
	reach. The host knows the address this node is published under; which port the
	server binds stays the gossiper's own business."
	gossiper := aGossiper.
	gossiper address: self publishedAddress.
	^ gossiper
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> knownTypes [
	"The four a node can be, per Rhizome decisions of 2026-09-22. Not enforced:
	a wrong value would be published rather than refused, and nothing resolves
	on it yet."
	^ #( #base #account #metabase #lurker )
]

{ #category : '*Rhizome-Discovery' }
RZNode >> publishedAddress [
	"The address the others are told about, taken from the host rather than from
	the machine's own idea of its name."
	^ NetNameResolver addressForName: self host address
]

{ #category : '*Rhizome-Discovery' }
RZNode >> seeds [
	"Where this node starts asking. Answers gossip endpoints."
	^ gossiper seedNodes
]

{ #category : '*Rhizome-Discovery' }
RZNode >> seeds: aCollectionOfEndpoints [
	"Configured, not discovered: these are only the endpoints gossip turns to
	first. A node may be in its own seed list; gossip leaves itself out when it
	picks whom to talk to."
	gossiper seedNodes: aCollectionOfEndpoints
]

{ #category : '*Rhizome-Discovery' }
RZNode >> seedsFromConfiguration: aString [
	self seeds: (RZDiscovery seedsFrom: aString)
]

{ #category : '*Rhizome-Discovery' }
RZNode >> startGossiping [
	gossiper start
]

{ #category : '*Rhizome-Discovery' }
RZNode >> stopGossiping [
	gossiper ifNotNil: [ gossiper stop ]
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> typeKey [
	^ 'type'
]

{ #category : '*Rhizome-Discovery' }
RZNode >> typeOfMember: aGossipEndpoint [
	"What another node says it is, or nil while nothing has been heard from it."
	| state |
	state := gossiper endpoints endpointStateAt: aGossipEndpoint ifAbsent: [ ^ nil ].
	^ [ (state applicationStateAt: self class typeKey) value ]
		on: KeyNotFound
		do: [ nil ]
]
