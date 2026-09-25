"
Covers what RZDiscovery answers about membership, about which services each member says it offers and where, and about which databases each member holds open.

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
RZDiscoveryTest >> member: anEndpoint offers: aServiceName [
	"An endpoint this image has heard from, having announced a service - which is
	what a delta leaves behind. The endpoint it serves it at is written as the
	deployment would write it, and is deliberately not the gossip endpoint."

	(gossiper endpoints newEndpointStateFor: anEndpoint)
		applicationStateAt: (RZNode serviceKeyFor: aServiceName)
		put: '10.10.0.1:3601'.
	^ anEndpoint
]

{ #category : 'running' }
RZDiscoveryTest >> member: anEndpoint hasOpen: aCollectionOfIds [

	(gossiper endpoints
		 endpointStateAt: anEndpoint
		 ifAbsent: [ gossiper endpoints newEndpointStateFor: anEndpoint ])
		applicationStateAt: RZNode openDatabasesKey
		put: aCollectionOfIds asArray.
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
RZDiscoveryTest >> testAMemberThatSaidNothingOffersNothing [
	"Heard from, but silent about its kind. Different from never heard of, and both
	answer nil - the distinction that matters is #includesMember:."

	| other |
	other := self otherOn: 9002.
	gossiper endpoints newEndpointStateFor: other.
	self assert: (discovery includesMember: other).
	self assertEmpty: (discovery servicesOf: other)
]

{ #category : 'tests' }
RZDiscoveryTest >> testAnUnknownMemberOffersNothing [
	self assertEmpty: (discovery servicesOf: (self otherOn: 9999))
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
RZDiscoveryTest >> testAServiceNobodyOffersHasNoMembers [
	"The answer during the first seconds of an image's life, and the one a caller
	has to be able to live with - it is why the gossip discovery falls back."

	self member: (self otherOn: 9002) offers: 'apptive-base'.
	self assertEmpty: (discovery membersOffering: 'apptive-metabase')
]

{ #category : 'tests' }
RZDiscoveryTest >> testMembersOfferingFindsEveryOneThatDoes [
	| base1 base2 |
	base1 := self member: (self otherOn: 9002) offers: 'apptive-base'.
	base2 := self member: (self otherOn: 9003) offers: 'apptive-base'.
	self member: (self otherOn: 9004) offers: 'apptive-metabase'.
	self
		assertCollection: (discovery membersOffering: 'apptive-base')
		hasSameElements: { base1. base2 }
]

{ #category : 'tests' }
RZDiscoveryTest >> testMembersOfferingIncludesTheLocalOne [
	"An image is a member of its own cluster, and of its own kind. Whether asking
	for a kind you are yourself is sensible is the caller's question, not this one's."

	gossiper stateAt: (RZNode serviceKeyFor: 'apptive-base') put: '10.10.0.1:3601'.
	self assert: ((discovery membersOffering: 'apptive-base') includes:
			 discovery localMember)
]

{ #category : 'tests' }
RZDiscoveryTest >> testTheEndpointOfAServiceIsWhereItSaidItIs [
	| other |
	other := self member: (self otherOn: 9002) offers: 'apptive-metabase'.
	self
		assert: (discovery endpointOfService: 'apptive-metabase' on: other)
		equals: '10.10.0.1:3601'
]

{ #category : 'tests' }
RZDiscoveryTest >> testAMemberThatSaidNothingHasNothingOpen [
	"Heard from, and silent about databases. Empty, not nil - a member that holds
	none says exactly the same thing, and neither is an error."

	| other |
	other := self otherOn: 9002.
	gossiper endpoints newEndpointStateFor: other.
	self assertEmpty: (discovery openDatabasesOf: other)
]

{ #category : 'tests' }
RZDiscoveryTest >> testAnUnknownMemberHasNothingOpen [

	self assertEmpty: (discovery openDatabasesOf: (self otherOn: 9009))
]

{ #category : 'tests' }
RZDiscoveryTest >> testNobodyHoldsADatabaseThatIsNotOpenAnywhere [

	self member: (self otherOn: 9002) hasOpen: #( 'aaa' ).
	self assertEmpty: (discovery membersWithDatabaseOpen: 'zzz')
]

{ #category : 'tests' }
RZDiscoveryTest >> testTheDatabasesOfAMemberAreWhatItSaid [

	| other |
	other := self member: (self otherOn: 9002) hasOpen: #( 'aaa' 'bbb' ).
	self
		assert: (discovery openDatabasesOf: other) asArray
		equals: #( 'aaa' 'bbb' )
]

{ #category : 'tests' }
RZDiscoveryTest >> testTwoMembersCanHoldTheSameDatabaseOpen [
	"Which is a real state and not a fault: a replica is open on more than one image
	by design. Who may write to it is the ownership record's answer, not this one -
	see RZDiscovery>>membersWithDatabaseOpen:."

	self member: (self otherOn: 9002) hasOpen: #( 'aaa' 'bbb' ).
	self member: (self otherOn: 9003) hasOpen: #( 'bbb' ).
	self
		assert: (discovery membersWithDatabaseOpen: 'bbb') size
		equals: 2.
	self
		assert: (discovery membersWithDatabaseOpen: 'aaa') size
		equals: 1
]
