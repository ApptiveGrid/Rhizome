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
	node offers: 'apptive-base' at: '10.10.0.6:3601'.
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
RZNodeDiscoveryTest >> testAnnouncesWhereItsServiceIs [
	"The value is the endpoint the service answers at, not the gossip endpoint. The
	two coincide only where a deployment makes them."

	node announceServices.
	self
		assert: (gossiper stateAt: (RZNode serviceKeyFor: 'apptive-base'))
		equals: '10.10.0.6:3601'
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testAnnouncesNothingBesidesItsServices [
	"One key per service and nothing else - no stage, no version, no capability."

	node announceServices.
	self
		assert: gossiper localEndpointState allStates applicationStates keys asArray
		equals: (Array with: (RZNode serviceKeyFor: 'apptive-base'))
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
RZNodeDiscoveryTest >> testReadsTheServicesAnotherNodeAnnounced [
	"Never heard of, heard of but silent, and heard of with a service - three
	answers, and the first two are the same empty one."

	| other state |
	other := GossipEndpoint address: (NetNameResolver addressForName: '127.0.0.2') port: 9001.
	self assertEmpty: (node servicesOfMember: other).
	state := gossiper endpoints newEndpointStateFor: other.
	self assertEmpty: (node servicesOfMember: other).
	state
		applicationStateAt: (RZNode serviceKeyFor: 'apptive-metabase')
		put: '10.10.0.7:3800'.
	self
		assert: ((node servicesOfMember: other) at: 'apptive-metabase')
		equals: '10.10.0.7:3800'
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

{ #category : 'tests' }
RZNodeDiscoveryTest >> testSayingWhatIsOpenReplacesWhatWasSaidBefore [
	"State and not events: every call publishes the whole answer, so a database that
	closed is simply not in it any more. Nobody has to send a retraction, and a
	member that missed a round has missed nothing."

	node hasOpenDatabases: (Dictionary newFrom: {
			 ('aaa' -> #primary).
			 ('bbb' -> #primary) }).
	node hasOpenDatabases: (Dictionary newFrom: { 'bbb' -> #primary }).
	self
		assert: (gossiper stateAt: RZNode openDatabasesKey) keys asArray
		equals: #( 'bbb' )
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testTheDiscoveryReadsItBack [
	"The two halves meet: what the node published is what the discovery answers for
	this member."

	node announceServices.
	node hasOpenDatabases: (Dictionary newFrom: { 'aaa' -> #primary }).
	self
		assert: (node discovery openDatabasesOf: node gossipEndpoint)
		equals: (Dictionary newFrom: { 'aaa' -> #primary }).
	self
		assert: (node discovery membersWithDatabaseOpen: 'aaa') asArray
		equals: (Array with: node gossipEndpoint)
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testWithNothingOpenItSaysSo [
	"An empty answer is an answer. It has to be published rather than left out, or
	an image that closed its last database would keep looking as it did before."

	node hasOpenDatabases: (Dictionary newFrom: { 'aaa' -> #primary }).
	node hasOpenDatabases: Dictionary new.
	self assertEmpty: (gossiper stateAt: RZNode openDatabasesKey)
]
{ #category : 'tests' }
RZNodeDiscoveryTest >> testAPromotionIsOneChange [
	"Why one key with a map and not one key per role: the entry changes its role in
	a single value with a single version. Across three keys gossip promises nothing,
	so there would be a window in which the database is in two roles or in none -
	and two primaries is exactly the state one reads this to find."

	| version |
	node hasOpenDatabases: (Dictionary newFrom: { 'aaa' -> #secondary }).
	version := (gossiper localEndpointState applicationStateAt:
		            RZNode openDatabasesKey) version.
	node hasOpenDatabases: (Dictionary newFrom: { 'aaa' -> #primary }).
	self
		assert: (gossiper localEndpointState applicationStateAt:
				 RZNode openDatabasesKey) version
		equals: version + 1.
	self
		assert: (node discovery roleOf: 'aaa' on: node gossipEndpoint)
		equals: #primary
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testSayingTheSameThingTwiceMovesNothing [
	"The registry asks on every request and mostly nothing has changed. A version
	that moves for nothing would put this key into every partial delta for nothing,
	so the second call has to be silent."

	| version |
	node hasOpenDatabases: (Dictionary newFrom: { 'aaa' -> #primary }).
	version := (gossiper localEndpointState applicationStateAt:
		            RZNode openDatabasesKey) version.
	node hasOpenDatabases: (Dictionary newFrom: { 'aaa' -> #primary }).
	self
		assert: (gossiper localEndpointState applicationStateAt:
				 RZNode openDatabasesKey) version
		equals: version
]

{ #category : 'tests' }
RZNodeDiscoveryTest >> testSaysWhichDatabasesItHasOpenAndAsWhat [

	node hasOpenDatabases: (Dictionary newFrom: {
			 ('aaa' -> #primary).
			 ('bbb' -> #secondary) }).
	self
		assert: (gossiper stateAt: RZNode openDatabasesKey)
		equals: (Dictionary newFrom: {
					 ('aaa' -> #primary).
					 ('bbb' -> #secondary) })
]

