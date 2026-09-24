"
That a journal pushed to a replica travels through the router in the time of the model, instead of arriving before it was sent.

This is the first call in Rhizome that does. Until now RZDevsSimulatedNetwork asked the fault-injecting router a question - would you drop this? - and then called the target directly, so no model time passed between sending and arriving and latency could not be expressed at all. Here the message is handed to the router, which carries it, delays it or drops it, and the far side sees it in a later step.

The call was chosen because it is the one that never wanted an answer: RZRemoteReplica>>replicateTransactionJournal: assigned the response to a local variable and never read it. The two calls that do want an answer are still direct.

The addresses are written as numbers because ZnUrl lowercases a host: an address with capitals in it arrives at the router under a different key than it was registered with.

Only one run per scenario: DEVSBasicSolver>>simulate: re-initialises the model at the current clock, which is Stufe A of the roadmap and not this step.
"
Class {
	#name : 'RZJournalInModelTimeTest',
	#superclass : 'TestCase',
	#instVars : [
		'clusterSimulation',
		'sharedAddresses',
		'networks',
		'arrived'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'running' }
RZJournalInModelTimeTest >> networkFor: anAddress [
	| network |
	network := RZDevsSimulatedNetwork
		           forAddress: anAddress
		           addresses: sharedAddresses
		           router: clusterSimulation router.
	network clusterSimulation: clusterSimulation.
	networks at: anAddress put: network.
	^ network
]

{ #category : 'running' }
RZJournalInModelTimeTest >> postFrom: anAddress to: aRemoteAddress [
	(networks at: anAddress)
		post: (ZnByteArrayEntity bytes: #[ 1 2 3 ])
		to: (ZnUrl new
				 host: aRemoteAddress;
				 port: 5555;
				 yourself) / #cluster / #databases / 'db' / #journals
]

{ #category : 'running' }
RZJournalInModelTimeTest >> setUp [
	"Two hosts in one model. The delivery block records what arrived and when
	instead of reaching into a Rhizome node - what is under test is the way, not
	what is at the end of it."

	super setUp.
	clusterSimulation := RZDevsClusterSimulation new.
	sharedAddresses := Dictionary new.
	networks := Dictionary new.
	arrived := OrderedCollection new.
	#( '10.0.0.1' '10.0.0.2' ) do: [ :address |
		self networkFor: address.
		sharedAddresses at: address ifAbsentPut: [ Dictionary new ].
		clusterSimulation
			hostAt: address
			deliverWith: [ :message |
				arrived add: address -> clusterSimulation time ] ]
]

{ #category : 'tests' }
RZJournalInModelTimeTest >> testAJournalArrivesAfterItWasSent [
	"The thing that could not happen before: time passes between the two."

	self postFrom: '10.0.0.1' to: '10.0.0.2'.
	clusterSimulation runTo: 20.
	self assert: arrived size equals: 1.
	self assert: arrived first key equals: '10.0.0.2'.
	self assert: arrived first value > 0
]

{ #category : 'tests' }
RZJournalInModelTimeTest >> testAPartitionedJournalNeverArrives [
	"A dropped message is dropped on the way now, rather than refused before it is
	sent. Nobody is told, which is what sending without waiting means."

	clusterSimulation router simulateNetworkPartition: '10.0.0.1' and: '10.0.0.2'.
	self postFrom: '10.0.0.1' to: '10.0.0.2'.
	clusterSimulation runTo: 20.
	self assertEmpty: arrived
]

{ #category : 'tests' }
RZJournalInModelTimeTest >> testLatencyIsAThingThatCanBeSaid [
	"The reason for doing any of this. A pair can be given a delay, and the message
	arrives later than one without - which was not expressible while the call went
	straight to its target."

	| withoutDelay withDelay |
	self postFrom: '10.0.0.1' to: '10.0.0.2'.
	clusterSimulation runTo: 20.
	withoutDelay := arrived first value.
	self setUp.
	clusterSimulation router
		setLatencyBetween: '10.0.0.1'
		and: '10.0.0.2'
		delay: 5.
	self postFrom: '10.0.0.1' to: '10.0.0.2'.
	clusterSimulation runTo: 20.
	withDelay := arrived first value.
	self assert: withDelay > withoutDelay
]
