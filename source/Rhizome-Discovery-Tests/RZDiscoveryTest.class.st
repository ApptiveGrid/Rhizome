"
Covers what RZDiscovery answers about membership, and - in testDependsOnNothingFromTheRhizomeCore - guards the package cut itself.
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
RZDiscoveryTest >> testDependsOnNothingFromTheRhizomeCore [
	"The cut this package exists for: it must be loadable into an Apptive image
	with Gossip alone, without dragging Soil and murmur3 along through Rhizome-Core.
	A reference to any other Rhizome package would do exactly that, so it fails here
	rather than in someone else's build."
	| offenders |
	offenders := OrderedCollection new.
	#('Rhizome-Discovery' 'Rhizome-Discovery-Tests') do: [ :packageName |
		(self class environment at: #PackageOrganizer) default
			packageNamed: packageName
			ifAbsent: [ nil ].
		((self class environment at: #PackageOrganizer) default packageNamed: packageName) definedClasses do: [ :each |
			{ each . each class } do: [ :side |
				side methodDict valuesDo: [ :method |
					method literals do: [ :literal |
						(literal isVariableBinding and: [ literal value isBehavior ]) ifTrue: [ | pkg |
							pkg := [ literal value package name ] on: Error do: [ nil ].
							(pkg notNil
								and: [ (pkg beginsWith: 'Rhizome-')
								and: [ (pkg beginsWith: 'Rhizome-Discovery') not ] ])
								ifTrue: [ offenders add: side name , '>>' , method selector , ' -> ' , literal value name ] ] ] ] ] ] ].
	self assert: offenders asArray equals: #()
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
RZDiscoveryTest >> testMembersAreGossipEndpointsAndNotClusterObjects [
	"The second notion of membership is intentional - see RZDiscovery's class
	comment. This pins it down so nobody quietly swaps in cluster objects."
	self assert: (discovery members allSatisfy: [ :each | each isKindOf: GossipEndpoint ])
]
