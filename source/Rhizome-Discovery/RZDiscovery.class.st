"
What this image knows about the other images: their gossip endpoints, and nothing more.

It sits on top of Rhizome-Core, the model, and adds the one outside dependency it needs: Gossip. That is the whole point of the package cut - an Apptive image can take the model and discovery without taking Soil, Zinc or murmur3 along, because those live in packages of their own.

It makes no statement about liveness. A member appearing here means it has been heard from, not that it is up - deciding ""gone"" stays with the lease manager until a failure detector of its own exists.
"
Class {
	#name : 'RZDiscovery',
	#superclass : 'Object',
	#instVars : [
		'gossiper'
	],
	#category : 'Rhizome-Discovery',
	#package : 'Rhizome-Discovery'
}

{ #category : 'instance creation' }
RZDiscovery class >> on: aGossiper [
	^ self new
		gossiper: aGossiper;
		yourself
]

{ #category : 'instance creation' }
RZDiscovery class >> seedFrom: aString [
	"One seed, written the way a deployment writes it: an address, optionally with a
	port - '10.10.1.2' or '10.10.1.2:1999'. Without a port the gossip default is
	used, so the common case stays short."

	| parts |
	parts := $: split: aString trimBoth.
	^ GossipEndpoint
		  address: (NetNameResolver addressForName: parts first trimBoth)
		  port: (parts size > 1
			   ifTrue: [ parts second trimBoth asInteger ]
			   ifFalse: [ GossipServer new defaultPort ])
]

{ #category : 'instance creation' }
RZDiscovery class >> seedsFrom: aString [
	"A whole seed list on one line, addresses separated by commas -
	'10.10.1.2, 10.10.1.3:1999'. One entry is #seedFrom:.

	A deployment that can hand over a list hands over a list and uses that one per
	entry; this is for the places where there is only a line to write in.

	It replaces APPTIVE_PROXIES, which named the proxies every component had to go
	through; a seed is only where gossip starts asking, and the list stops being the
	membership as soon as more than the seeds are known."

	^ (($, split: aString) collect: [ :each | each trimBoth ])
		  reject: [ :each | each isEmpty ]
		  thenCollect: [ :each | self seedFrom: each ]
]

{ #category : 'accessing' }
RZDiscovery >> gossiper [
	^ gossiper
]

{ #category : 'accessing' }
RZDiscovery >> gossiper: aGossiper [
	gossiper := aGossiper
]

{ #category : 'testing' }
RZDiscovery >> includesMember: aGossipEndpoint [
	^ gossiper endpoints includesKey: aGossipEndpoint
]

{ #category : 'accessing' }
RZDiscovery >> lastSeen: aGossipEndpoint [
	"When this image last saw that member's own heartbeat move forward, or nil
	while nothing has ever been heard from it. That difference is the point: it
	separates 'never heard of' from 'heard of long ago'.

	Handed out without judgement. Whether a member is gone is not decided here -
	that stays with the lease manager until there is a failure detector of its own
	(Entscheidung 4, Rhizome decisions of 2026-09-22).

	One limit of the layer below, measured on 2026-09-22: a heartbeat only ever
	arrives from the member itself. Gossip relays what it knows about a third
	party once, on first contact, and never again, so for a member this image does
	not talk to directly the timestamp stops at the moment it was first heard of.
	With every image seeding every other - the deployment that is planned - all
	members are talked to directly and the question does not arise."
	^ (gossiper endpoints endpointStateAt: aGossipEndpoint ifAbsent: [ ^ nil ]) lastSeen
]

{ #category : 'accessing' }
RZDiscovery >> localMember [
	^ gossiper localEndpoint
]

{ #category : 'accessing' }
RZDiscovery >> members [
	"Every endpoint this image has heard of, its own included."
	^ gossiper endpoints keys
]

{ #category : 'accessing' }
RZDiscovery >> membersOfType: aSymbol [
	"Every member that says it is of this kind, the local one included. Empty while
	nothing of the kind has been heard of - an answer a caller has to be able to live
	with, because it is also the answer during the first seconds of an image's life.

	Says nothing about liveness, like everything here: a member listed has been heard
	from, not that it is up. Whoever needs that asks #lastSeen:.

	The order is whatever the endpoint table happens to hand out. Choosing among
	several is the caller's business, and no answer here is a load balancer."

	^ self members select: [ :each | (self typeOf: each) = aSymbol ]
]

{ #category : 'accessing' }
RZDiscovery >> size [
	^ self members size
]

{ #category : 'accessing' }
RZDiscovery >> typeOf: aGossipEndpoint [
	"What that member says it is - #base, #account, #metabase or #lurker - or nil
	when nothing has been heard from it, or when it has been heard from but has said
	nothing about its kind.

	Not checked against RZNode class>>knownTypes: a wrong value travels rather than
	being refused, and answering nil for it would hide it."

	| state |
	state := gossiper endpoints endpointStateAt: aGossipEndpoint ifAbsent: [ ^ nil ].
	^ [ (state applicationStateAt: RZNode typeKey) value ]
		  on: KeyNotFound
		  do: [ nil ]
]
