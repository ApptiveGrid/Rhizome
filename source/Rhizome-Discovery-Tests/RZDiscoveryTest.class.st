"
Covers what RZDiscovery answers about membership.
"
Class {
	#name : 'RZDiscoveryTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossiper',
		'discovery'
	],
	#category : 'Rhizome-Discovery-Tests',
	#package : 'Rhizome-Discovery-Tests'
}

{ #category : 'running' }
RZDiscoveryTest >> setUp [
	super setUp.
	gossiper := Gossiper new
		address: #[127 0 0 1];
		port: 9001;
		seedNodes: { GossipEndpoint address: #[127 0 0 1] port: 9002 };
		yourself.
	"A gossiper registers its own endpoint state the first time it does anything -
	gossip, stateAt:put: and friends all go through localEndpointState. Without
	that first touch it knows nobody at all, not even itself."
	gossiper localEndpointState.
	discovery := RZDiscovery on: gossiper
]

{ #category : 'tests' }
RZDiscoveryTest >> testKnowsItsOwnEndpointAsAMember [
	self assert: (discovery includesMember: discovery localMember).
	self assert: discovery size equals: 1
]

{ #category : 'tests' }
RZDiscoveryTest >> testLearnedEndpointBecomesAMember [
	| other |
	other := GossipEndpoint address: #[127 0 0 1] port: 9002.
	self deny: (discovery includesMember: other).
	gossiper endpoints newEndpointStateFor: other.
	self assert: (discovery includesMember: other).
	self assert: discovery size equals: 2
]

{ #category : 'tests' }
RZDiscoveryTest >> testMembersAreGossipEndpoints [
	self assert: (discovery members allSatisfy: [ :each | each isKindOf: GossipEndpoint ])
]
