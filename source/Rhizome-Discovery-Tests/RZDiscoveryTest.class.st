"
Covers what RZDiscovery answers about membership, and about what kind of node each member says it is.

No sockets: endpoints are put into the gossiper by hand, exactly as an arriving delta would leave them. What is checked is the answer, not that it travelled.
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
RZDiscoveryTest >> member: anEndpoint saysItIs: aSymbol [
	"An endpoint this image has heard from, having announced its kind - which is
	what a delta leaves behind."

	(gossiper endpoints newEndpointStateFor: anEndpoint)
		applicationStateAt: RZNode typeKey put: aSymbol.
	^ anEndpoint
]

{ #category : 'running' }
RZDiscoveryTest >> otherOn: aPort [
	^ GossipEndpoint address: #[ 127 0 0 1 ] port: aPort
]

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
RZDiscoveryTest >> testAMemberThatSaidNothingHasNoType [
	"Heard from, but silent about its kind. Different from never heard of, and both
	answer nil - the distinction that matters is #includesMember:."

	| other |
	other := self otherOn: 9002.
	gossiper endpoints newEndpointStateFor: other.
	self assert: (discovery includesMember: other).
	self assert: (discovery typeOf: other) isNil
]

{ #category : 'tests' }
RZDiscoveryTest >> testAnUnknownMemberHasNoType [
	self assert: (discovery typeOf: (self otherOn: 9999)) isNil
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

{ #category : 'tests' }
RZDiscoveryTest >> testMembersOfATypeNobodyAnnouncedAreEmpty [
	"The answer during the first seconds of an image's life, and the one a caller
	has to be able to live with - it is why the gossip discovery falls back."

	self member: (self otherOn: 9002) saysItIs: #base.
	self assertEmpty: (discovery membersOfType: #metabase)
]

{ #category : 'tests' }
RZDiscoveryTest >> testMembersOfTypeFindsEveryOneOfThatKind [
	| base1 base2 |
	base1 := self member: (self otherOn: 9002) saysItIs: #base.
	base2 := self member: (self otherOn: 9003) saysItIs: #base.
	self member: (self otherOn: 9004) saysItIs: #metabase.
	self
		assertCollection: (discovery membersOfType: #base)
		hasSameElements: { base1. base2 }
]

{ #category : 'tests' }
RZDiscoveryTest >> testMembersOfTypeIncludesTheLocalOne [
	"An image is a member of its own cluster, and of its own kind. Whether asking
	for a kind you are yourself is sensible is the caller's question, not this one's."

	gossiper stateAt: RZNode typeKey put: #base.
	self assert:
		((discovery membersOfType: #base) includes: discovery localMember)
]

{ #category : 'tests' }
RZDiscoveryTest >> testTypeOfAMemberThatAnnouncedOne [
	| other |
	other := self member: (self otherOn: 9002) saysItIs: #metabase.
	self assert: (discovery typeOf: other) equals: #metabase
]
