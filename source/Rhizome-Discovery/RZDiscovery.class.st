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
RZDiscovery class >> hostAndPortFrom: aString [
	"A published service endpoint, split the way a caller needs it: 'host' -> port.
	The same shape #seedFrom: parses, and for the same reason - a deployment writes
	an address and a port on one line, and exactly one place here knows that."

	| parts |
	parts := $: split: aString trimBoth.
	^ parts first trimBoth -> parts second trimBoth asInteger
]

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
RZDiscovery >> endpointOfService: aServiceName on: aGossipEndpoint [
	"Where that member serves that service - 'address:port' as it published it - or
	nil when it does not, or when nothing has been heard from it at all.

	This is not the gossip endpoint and must not be confused with it. What gossip
	publishes is where gossip is reachable; where a service answers is a value like
	any other, and the two coincide only if a deployment makes them."

	^ (self servicesOf: aGossipEndpoint) at: aServiceName ifAbsent: [ nil ]
]

{ #category : 'accessing' }
RZDiscovery >> membersWithDatabaseOpen: anId [
	"Every member that says it holds that database open, the local one included, in
	whatever role. Which role each of them plays is #roleOf:on:.

	A hint, and deliberately not more. Where a database *belongs* is not answered
	here - rendezvous hashing gives the candidates and the ownership record gives
	the truth, and that stays the only authority.

	*Several answers are normal, and they do not say who may write.* In replication
	mode a database is open on several images and full - primary - on exactly one;
	the others hold a replica. Two of them calling themselves primary is the thing
	worth seeing, and seeing it means asking #roleOf:on: for each, not counting the
	members here."

	^ self members select: [ :each |
		  (self openDatabasesOf: each) includesKey: anId ]
]

{ #category : 'accessing' }
RZDiscovery >> openDatabasesOf: aGossipEndpoint [
	"Which databases that member holds open and in which role, as id -> role. Empty
	while nothing has been heard from it - and empty is also the honest answer for a
	member that holds none.

	An older image publishes a plain list of ids, because the role came later. It is
	read as ids with no role rather than being refused: during a rollout both are on
	the air at once, and a reader that breaks on the older form would break on
	exactly the members that have not been restarted yet."

	| state published |
	state := gossiper endpoints
		         endpointStateAt: aGossipEndpoint
		         ifAbsent: [ ^ Dictionary new ].
	published := (state allStates applicationStates
		              at: RZNode openDatabasesKey
		              ifAbsent: [ ^ Dictionary new ]) value.
	published isDictionary ifTrue: [ ^ published ].
	^ (published collect: [ :each | each -> nil ]) asDictionary
]

{ #category : 'accessing' }
RZDiscovery >> roleOf: anId on: aGossipEndpoint [
	"The role that member says it is playing for that database, or nil when it does
	not hold it open - and also nil when it holds it but published no role, which is
	what an image from before the role looks like.

	Read against RZRendezvousHashingStrategy>>hostNamesForKey: this is the
	interesting answer: a member acting as primary for a database it is only ranked
	second for has taken over, and that is not something any rank can tell you."

	^ (self openDatabasesOf: aGossipEndpoint) at: anId ifAbsent: [ nil ]
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

	A heartbeat relayed through a neighbour counts as well. Until Gossip 59eb796 it
	did not: a copy's version stood still, so a third party's heartbeat was relayed
	once, on first contact, and for a member this image did not talk to directly the
	timestamp stopped there. That limit was measured on 2026-09-22 and found again
	by the observer on 2026-09-25, which talks to one node only.

	So liveness travels, and the timestamp says 'somebody in this cluster heard from
	it, and I have been told' rather than 'I heard from it'.

	*What follows for a failure detector,* and it is the difference between two
	questions: 'can I reach it' is not answered here and never was. While a member
	is cut off from this image alone, its timestamp keeps moving, because the others
	still hear it - which is right, and is why a detector must not read this as
	reachability. And while a member is cut off from everyone, the timestamp may
	still move once more, when a third party delivers a heartbeat this image had not
	caught up on yet; after that it stands still."
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
RZDiscovery >> membersOffering: aServiceName [
	"Every member that says it serves that, the local one included. Empty while
	nothing offering it has been heard of - an answer a caller has to be able to live
	with, because it is also the answer during the first seconds of an image's life.

	Says nothing about liveness, like everything here: a member listed has been heard
	from, not that it is up. Whoever needs that asks #lastSeen:.

	The order is whatever the endpoint table happens to hand out. Choosing among
	several is the caller's business, and no answer here is a load balancer."

	^ self members select: [ :each |
		  (self endpointOfService: aServiceName on: each) notNil ]
]

{ #category : 'accessing' }
RZDiscovery >> servicesOf: aGossipEndpoint [
	"What that member says it offers, as name -> endpoint. Empty when nothing has
	been heard from it, and empty when it serves nothing - a node may take part and
	offer none.

	Read by the namespace rather than by a fixed set of keys: which services exist is
	not something this has to know, and a name nobody here recognises still arrives."

	| state services |
	services := Dictionary new.
	state := gossiper endpoints
		         endpointStateAt: aGossipEndpoint
		         ifAbsent: [ ^ services ].
	state allStates applicationStates keysAndValuesDo: [ :key :each |
		(RZNode isServiceKey: key) ifTrue: [
			services at: (RZNode serviceNameFrom: key) put: each value ] ].
	^ services
]

{ #category : 'accessing' }
RZDiscovery >> size [
	^ self members size
]
