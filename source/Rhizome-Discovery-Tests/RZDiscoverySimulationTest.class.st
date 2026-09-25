"
Discovery with the messages actually flying: several nodes in one simulated network, each with a gossiper of its own, and the question whether every node ends up knowing what kind of node every other one is.

Every image in this simulation is three objects: a DEVSNetworkHost standing for the machine, an RZLocalHost with its RZLocalNode standing for the Rhizome side, and a DevsGossiper speaking for it. The DEVS network addresses its hosts by name, and DevsGossiper hands it the gossip port as that name - so inside the simulation a node is addressed by its gossip port, while the address it publishes to the others stays a real one.

The rounds happen one after another in simulated time, because each server has a heartbeat that gossips. That is what makes the difference: everything stirred up before a run happens at time zero, in lock step, and then no round can pass on what an earlier one learned - which is exactly how gossip reaches a node it cannot talk to directly.

Nothing is started here and no socket is opened; time passes only because the solver runs.
"
Class {
	#name : 'RZDiscoverySimulationTest',
	#superclass : 'TestCase',
	#instVars : [
		'network',
		'router',
		'nodes',
		'clocks'
	],
	#category : 'Rhizome-Discovery-Tests',
	#package : 'Rhizome-Discovery-Tests'
}

{ #category : 'running' }
RZDiscoverySimulationTest >> addNodeNamed: aSymbol port: anInteger gossipPort: gossipPort type: aType every: aPeriod [
	"Put one more image into the simulation: a DEVSNetworkHost standing for the
	machine, an RZLocalHost with its RZLocalNode standing for the Rhizome side, and
	a DevsGossiper speaking for it, gossiping every aPeriod ticks of its own accord.
	The two ports are two different things and deliberately not the same number:
	anInteger is the port the node serves requests on, gossipPort the one the
	gossiper speaks on. The three periods differ so the rounds interleave instead
	of marching in step."
	| server host node gossiper |
	server := DEVSPluggableServer new
		name: (aSymbol , 'Server') asSymbol;
		port: 1;
		yourself.
	network addHost: (DEVSNetworkHost new
		name: aSymbol;
		address: gossipPort printString;
		addServer: server;
		yourself).
	host := RZLocalHost name: aSymbol address: '127.0.0.1'.
	node := RZLocalNode port: anInteger.
	host addNode: node.
	node offers: aType at: '10.10.0.' , anInteger printString , ':' , anInteger printString.
	gossiper := DevsGossiper new
		port: gossipPort;
		devsServer: server;
		yourself.
	"Its own clock, driven by the model rather than by the wall clock."
	clocks at: aSymbol put: (gossiper clock: GossipManualClock new; clock).
	node gossiper: gossiper.
	"A node says what it is as it comes up; a gossiper knows nobody, not even
	itself, until it first touches its own state, and announcing does that."
	node announceServices.
	server onIncomingDo: [ :message :srv |
		gossiper
			received: message payload
			from: (GossipEndpoint address: #[127 0 0 1] port: message sourceAddress asInteger).
		nil ].
	server every: aPeriod do: [ :srv | gossiper gossip ].
	nodes at: aSymbol put: node.
	^ node
]

{ #category : 'running' }
RZDiscoverySimulationTest >> at: aTime do: aBlock [
	"Have something happen once, while the run is going. A trigger repeats, so the
	block guards itself."
	| done |
	done := false.
	network addComponent: (DEVSPluggableTrigger new
		name: ('once' , aTime printString) asSymbol;
		period: aTime;
		onTickDo: [ :time | done ifFalse: [ done := true. aBlock value ] ];
		yourself)
]

{ #category : 'accessing' }
RZDiscoverySimulationTest >> clockOf: aSymbol [
	^ clocks at: aSymbol
]

{ #category : 'accessing' }
RZDiscoverySimulationTest >> lastSeenAt: observerName of: memberName [
	^ (self node: observerName) discovery lastSeen: (self node: memberName) gossipEndpoint
]

{ #category : 'running' }
RZDiscoverySimulationTest >> letTheClocksFollowTheSimulation [
	"Each gossiper reads the time from a clock of its own, and here they all follow
	the model's clock: one tick is one second. Without this the timestamps would
	come from the wall clock, which has nothing to do with what the run is doing."
	| start |
	start := DateAndTime year: 2026 month: 9 day: 22.
	network addComponent: (DEVSPluggableTrigger new
		name: #clocks;
		period: 1;
		onTickDo: [ :time |
			clocks valuesDo: [ :each | each now: start + time seconds ] ];
		yourself)
]

{ #category : 'accessing' }
RZDiscoverySimulationTest >> node: aSymbol [
	^ nodes at: aSymbol
]

{ #category : 'accessing' }
RZDiscoverySimulationTest >> router [
	^ router
]

{ #category : 'running' }
RZDiscoverySimulationTest >> runSimulationFor: ticks [
	| simulation |
	simulation := DEVSSimulation new.
	simulation model: network.
	simulation coordinator: DEVSRootSolver new.
	simulation runTo: ticks
]

{ #category : 'running' }
RZDiscoverySimulationTest >> seedEveryNodeWithEveryOther [
	"The same one line for every node, as a deployment would hand it over: gossip
	leaves itself out when it picks whom to talk to."
	nodes valuesDo: [ :each |
		each seedsFromConfiguration: '127.0.0.1:9001, 127.0.0.1:9002, 127.0.0.1:9003' ]
]

{ #category : 'running' }
RZDiscoverySimulationTest >> setUp [
	super setUp.
	network := DEVSNetwork new name: #net; yourself.
	"The router goes in before the hosts: addHost: couples every host to whatever
	router is in place at that moment."
	router := network router: DEVSFaultInjectingNetworkRouter new.
	nodes := Dictionary new.
	clocks := Dictionary new.
	self addNodeNamed: #node1 port: 4851 gossipPort: 9001 type: #base every: 20.
	self addNodeNamed: #node2 port: 4852 gossipPort: 9002 type: #account every: 25.
	self addNodeNamed: #node3 port: 4853 gossipPort: 9003 type: #metabase every: 30.
	self seedEveryNodeWithEveryOther.
	self letTheClocksFollowTheSimulation
]

{ #category : 'tests' }
RZDiscoverySimulationTest >> testAMemberNeverHeardOfHasNoTimestamp [
	"nil is the answer to 'never heard of', and it has to stay distinguishable
	from 'heard of long ago' - otherwise the first consumer cannot tell a member
	that is starting up from one that has stopped."
	router simulateNetworkPartition: '9002' and: '9001'.
	router simulateNetworkPartition: '9002' and: '9003'.
	self runSimulationFor: 400.
	self assert: (self lastSeenAt: #node1 of: #node2) isNil.
	self assert: (self lastSeenAt: #node1 of: #node3) notNil
]

{ #category : 'tests' }
RZDiscoverySimulationTest >> testANodeIsReachedThroughAThirdOne [
	"Two nodes that cannot exchange a single message still learn what the other is,
	because the third one passes on what it knows. This is the property that makes
	the difference between gossip and everyone asking everyone - and it only shows
	when the rounds happen one after another in simulated time: a node can only
	pass on what it has already learned."
	router simulateNetworkPartition: '9001' and: '9002'.
	self runSimulationFor: 400.
	self assert: ((self node: #node1) servicesOfMember:
			 (self node: #node2) gossipEndpoint) keys asArray equals: #( 'account' ).
	self assert: ((self node: #node2) servicesOfMember:
			 (self node: #node1) gossipEndpoint) keys asArray equals: #( 'base' )
]

{ #category : 'tests' }
RZDiscoverySimulationTest >> testEveryNodeLearnsTheServicesOfEveryOther [
	"The point of stage one, now with the messages actually travelling: what a
	node says about itself arrives at the others unchanged."
	self runSimulationFor: 200.
	nodes valuesDo: [ :each |
		nodes valuesDo: [ :other |
			self
				assert: (each servicesOfMember: other gossipEndpoint)
				equals: other services ] ]
]

{ #category : 'tests' }
RZDiscoverySimulationTest >> testEveryNodeSeesEveryMember [
	"Membership first, before anything is said about the members."
	self runSimulationFor: 200.
	nodes valuesDo: [ :each |
		self assert: each discovery size equals: 3 ]
]

{ #category : 'tests' }
RZDiscoverySimulationTest >> testLastSeenStandsStillWhileAMemberIsCutOffAndMovesAgainAfterwards [
	"The timestamp does what it says: it stops moving while nothing is heard from
	that member, and picks up again once it is. It does not jump, and it does not
	freeze for good - and nowhere does anything conclude from it that the member
	is gone.

	The two readings during the partition are taken from inside the run; without
	them the test would only show the happy end and would stay green even if the
	timestamp had never stood still.

	Both of them are taken well after the cut, and that is not slack. Since a relayed
	heartbeat keeps counting (Gossip, 2026-09-25), a third party can still deliver a
	heartbeat this image had not caught up on, so the timestamp may move once more
	after the member has gone quiet. Reading at 200 caught that moment roughly one
	run in two hundred. What stands still is the steady state, not the first instant."
	| whileCutOff stillCutOff |
	self at: 150 do: [
		router simulateNetworkPartition: '9002' and: '9001'.
		router simulateNetworkPartition: '9002' and: '9003' ].
	self at: 240 do: [ whileCutOff := self lastSeenAt: #node1 of: #node2 ].
	self at: 290 do: [ stillCutOff := self lastSeenAt: #node1 of: #node2 ].
	self at: 300 do: [
		router healPartition: '9002' and: '9001'.
		router healPartition: '9002' and: '9003' ].
	self runSimulationFor: 400.
	self assert: whileCutOff notNil.
	self assert: stillCutOff equals: whileCutOff.
	self assert: (self lastSeenAt: #node1 of: #node2) > stillCutOff
]

{ #category : 'tests' }
RZDiscoverySimulationTest >> testTypesConvergeAfterAPartitionHeals [
	"One node cut off from both others, and the partition taken back while the run
	is still going: nobody restarts anything, and the cluster closes over it again.
	The check at t=150 is there so the test says both halves - cut off while the
	partition lasts, converged once it is over - rather than only the happy end."
	| duringThePartition |
	router simulateNetworkPartition: '9002' and: '9001'.
	router simulateNetworkPartition: '9002' and: '9003'.
	self at: 150 do: [
		duringThePartition := (self node: #node1) servicesOfMember:
			                      (self node: #node2) gossipEndpoint ].
	self at: 200 do: [
		router healPartition: '9002' and: '9001'.
		router healPartition: '9002' and: '9003' ].
	self runSimulationFor: 400.
	self assertEmpty: duringThePartition.
	nodes valuesDo: [ :each |
		nodes valuesDo: [ :other |
			self
				assert: (each servicesOfMember: other gossipEndpoint)
				equals: other services ] ]
]
