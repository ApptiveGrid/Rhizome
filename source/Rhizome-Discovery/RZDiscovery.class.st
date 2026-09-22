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
RZDiscovery class >> seedsFrom: aString [
	"Read a configured seed list into gossip endpoints. The form is what a
	deployment can hand over on one line: addresses separated by commas, each
	optionally with a port - '10.10.1.2, 10.10.1.3:1999'. Without a port the
	gossip default is used, so the common case stays short.

	This replaces APPTIVE_PROXIES, which named the proxies every component had to
	go through; a seed is only where gossip starts asking, and the list stops
	being the membership as soon as more than the seeds are known."
	| default |
	default := GossipServer new defaultPort.
	^ (($, split: aString) collect: [ :each | each trimBoth ])
		reject: [ :each | each isEmpty ]
		thenCollect: [ :each | | parts |
			parts := $: split: each.
			GossipEndpoint
				address: (NetNameResolver addressForName: parts first trimBoth)
				port: (parts size > 1
					ifTrue: [ parts second trimBoth asInteger ]
					ifFalse: [ default ]) ]
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
RZDiscovery >> localMember [
	^ gossiper localEndpoint
]

{ #category : 'accessing' }
RZDiscovery >> members [
	"Every endpoint this image has heard of, its own included."
	^ gossiper endpoints keys
]

{ #category : 'accessing' }
RZDiscovery >> size [
	^ self members size
]
