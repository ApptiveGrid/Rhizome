"
The first stage of discovery seen from the node: it holds a gossiper, publishes the address it is reachable under rather than the one the machine calls itself, and says what kind of node it is - nothing else.

No sockets here. The gossiper is configured but never started; what is checked is what lands in the gossip state, not that it travels. That it travels is the simulator's job, one stage further on.
"
Class {
	#name : 'RZNodeDiscoveryTest',
	#superclass : 'TestCase',
	#instVars : [
		'host',
		'node',
		'gossiper'
	],
	#category : 'Rhizome-Discovery-Tests',
	#package : 'Rhizome-Discovery-Tests'
}

{ #category : 'running' }
RZNodeDiscoveryTest >> setUp [
	super setUp.
	host := RZLocalHost name: #node1 address: '127.0.0.1'.
	node := RZLocalNode port: 4850.
	host addNode: node.
	node type: #base.
	gossiper := Gossiper new port: 9001; yourself.
	node gossiper: gossiper.
	"A gossiper knows nobody, not even itself, until it first touches its own state."
	gossiper localEndpointState
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testASeedListMayContainTheNodeItself [
	"Gossip leaves itself out when it picks whom to talk to, so a deployment can
	hand every node the same list."
	node seedsFromConfiguration: '127.0.0.1:9001, 10.10.1.3'.
	self assert: (node seeds includes: node gossipEndpoint).
	self deny: (node gossiper randomNodes includes: node gossipEndpoint)
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testAnnouncesItsType [
	node announceType.
	self assert: (gossiper stateAt: RZNode typeKey) equals: #base
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testAnnouncesNothingBesidesItsType [
	"Stage one carries the type and nothing else - no stage, no version, no capability."
	node announceType.
	self
		assert: gossiper localEndpointState allStates applicationStates keys asArray
		equals: (Array with: RZNode typeKey)
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testDiscoverySeesTheSameMembers [
	self assert: (node discovery includesMember: node gossipEndpoint)
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testGossipEndpointIsAddressAndGossipPort [
	self assert: node gossipEndpoint address equals: node publishedAddress.
	self assert: node gossipEndpoint port equals: 9001.
	self deny: node gossipEndpoint port equals: node port
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testPublishesTheAddressOfItsHostAndNotTheMachineName [
	"GossipServer would otherwise answer NetNameResolver localHostName, which is
	whatever this machine calls itself - see the comment on RZNode>>gossiper:."
	self assert: node publishedAddress equals: (NetNameResolver addressForName: '127.0.0.1').
	self assert: gossiper address equals: node publishedAddress
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testReadsOneSeedFromConfiguration [
	"What a deployment that can hand over a list uses, one entry at a time."

	| seed |
	seed := RZDiscovery seedFrom: '10.10.1.2:1998'.
	self
		assert: seed address
		equals: (NetNameResolver addressForName: '10.10.1.2').
	self assert: seed port equals: 1998
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testOneSeedWithoutAPortTakesTheGossipDefault [

	self
		assert: (RZDiscovery seedFrom: ' 10.10.1.2 ') port
		equals: GossipServer new defaultPort
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testReadsASeedListFromConfiguration [
	| seeds |
	seeds := RZDiscovery seedsFrom: '10.10.1.2, 10.10.1.3:1998'.
	self assert: seeds size equals: 2.
	self assert: seeds first address equals: (NetNameResolver addressForName: '10.10.1.2').
	self assert: seeds first port equals: GossipServer new defaultPort.
	self assert: seeds second port equals: 1998
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testReadsTheTypeAnotherNodeAnnounced [
	| other state |
	other := GossipEndpoint address: (NetNameResolver addressForName: '127.0.0.2') port: 9001.
	self assert: (node typeOfMember: other) isNil.
	state := gossiper endpoints newEndpointStateFor: other.
	self assert: (node typeOfMember: other) isNil.
	state applicationStateAt: RZNode typeKey put: #metabase.
	self assert: (node typeOfMember: other) equals: #metabase
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testSeedListToleratesSpacingAndTrailingSeparators [
	self assert: (RZDiscovery seedsFrom: '  10.10.1.2 ,, 10.10.1.3 , ') size equals: 2.
	self assert: (RZDiscovery seedsFrom: '') isEmpty
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testTakesItsSeedsFromConfiguration [
	node seedsFromConfiguration: '10.10.1.2, 10.10.1.3:1998'.
	self assert: node seeds size equals: 2.
	self assert: node gossiper seedNodes equals: node seeds
]
