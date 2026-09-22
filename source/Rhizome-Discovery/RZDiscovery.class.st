"
What this image knows about the other images: their gossip endpoints, and nothing more.

It carries its own notion of membership, over Gossip's endpoints, instead of reaching into RZCluster. That is deliberate and it has a price: there are two notions of membership in this repository for the time being - RZCluster holds RZHosts built from a static list, this holds GossipEndpoints learned from the network. They have to be brought together when the cluster itself moves onto discovery. Until then, do not make one refer to the other; the whole point of this package is that it can be loaded into an Apptive image without dragging Soil and murmur3 along.

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
	"Every endpoint this image has heard of, its own included. These are
	GossipEndpoints, not cluster objects - see the class comment on why."
	^ gossiper endpoints keys
]

{ #category : 'accessing' }
RZDiscovery >> size [
	^ self members size
]
