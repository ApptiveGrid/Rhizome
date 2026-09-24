"
What a cluster answers about the network it talks through.

There is no real network yet - the simulator is the only thing that answers what Rhizome-Core sends - and a cluster that was given none used to fail with a doesNotUnderstand on #realNetwork, a method nobody ever wrote. A missing piece that reports itself as a missing method is the kind of thing that makes a codebase look broken where it is merely unfinished.
"
Class {
	#name : 'RZClusterTest',
	#superclass : 'TestCase',
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'tests' }
RZClusterTest >> testAClusterAnswersTheNetworkItWasGiven [
	"Which is how every simulation gets one, and why nothing in the tests ever met
	the error above."

	| cluster network |
	network := RZNetwork new.
	cluster := RZCluster new
		           network: network;
		           yourself.
	self assert: cluster network identicalTo: network
]

{ #category : 'tests' }
RZClusterTest >> testAClusterWithoutANetworkSaysSo [
	"By name, and with a sentence that says what is missing - not by failing on a
	method that was never written."

	self should: [ RZCluster new network ] raise: RZNoNetwork
]

{ #category : 'tests' }
RZClusterTest >> testTheErrorSaysWhatToDoAboutIt [
	| error |
	error := [ RZCluster new network ] on: RZNoNetwork do: [ :each | each ].
	self assert: (error messageText includesSubstring: 'network:')
]
