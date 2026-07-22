Class {
	#name : 'RZDevsNetworkRouterTest',
	#superclass : 'TestCase',
	#instVars : [
		'network',
		'serverA',
		'serverB',
		'serverC',
		'hostA',
		'hostB',
		'hostC',
		'receivedAtA',
		'receivedAtB',
		'receivedAtC',
		'router'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> runFor: ticks [
	| sim |
	sim := DEVSSimulation new.
	sim model: network.
	sim coordinator: DEVSRootSolver new.
	sim runTo: ticks
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> setUp [
	super setUp.
	serverA := DEVSPluggableServer new name: #serverA; port: 1; yourself.
	serverB := DEVSPluggableServer new name: #serverB; port: 1; yourself.
	serverC := DEVSPluggableServer new name: #serverC; port: 1; yourself.
	receivedAtA := OrderedCollection new.
	receivedAtB := OrderedCollection new.
	receivedAtC := OrderedCollection new.
	serverA onIncomingDo: [ :message :srv | receivedAtA add: message payload. nil ].
	serverB onIncomingDo: [ :message :srv | receivedAtB add: message payload. nil ].
	serverC onIncomingDo: [ :message :srv | receivedAtC add: message payload. nil ].
	network := RZDevsNetwork new name: #net.
	hostA := DEVSNetworkHost new name: #hostA; address: 'A'; addServer: serverA; yourself.
	hostB := DEVSNetworkHost new name: #hostB; address: 'B'; addServer: serverB; yourself.
	hostC := DEVSNetworkHost new name: #hostC; address: 'C'; addServer: serverC; yourself.
	network addHost: hostA.
	network addHost: hostB.
	network addHost: hostC.
	router := network router
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testDropNextNMessagesStopsAfterCount [
	router dropNextNMessagesBetween: 'A' and: 'B' count: 2.
	serverA send: 'msg1' to: 'B' port: 1.
	serverA send: 'msg2' to: 'B' port: 1.
	serverA send: 'msg3' to: 'B' port: 1.
	self runFor: 10.
	self assert: receivedAtB asArray equals: #('msg3')
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testDropOnlyAffectsConfiguredDirection [
	router dropNextNMessagesBetween: 'A' and: 'B' count: 5.
	serverA send: 'toB' to: 'B' port: 1.
	serverA send: 'toC' to: 'C' port: 1.
	self runFor: 10.
	self assert: receivedAtB isEmpty.
	self assert: receivedAtC asArray equals: #('toC')
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testHealPartitionRestoresFlow [
	router simulateNetworkPartition: 'A' and: 'B'.
	router healPartition: 'A' and: 'B'.
	serverA send: 'shouldArrive' to: 'B' port: 1.
	self runFor: 10.
	self assert: receivedAtB asArray equals: #('shouldArrive')
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testLatencyDelaysExactlyConfiguredTicks [
	| times |
	times := OrderedCollection new.
	serverB onIncomingDo: [ :message :srv | times add: srv rootSolver time. nil ].
	router setLatencyBetween: 'A' and: 'B' delay: 5.
	serverA send: 'delayed' to: 'B' port: 1.
	self runFor: 20.
	self assert: times asArray equals: #(9)
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testLatencyDoesNotHeadOfLineBlockOtherTraffic [
	| timesB timesC |
	timesB := OrderedCollection new.
	timesC := OrderedCollection new.
	serverB onIncomingDo: [ :message :srv | timesB add: srv rootSolver time. nil ].
	serverC onIncomingDo: [ :message :srv | timesC add: srv rootSolver time. nil ].
	router setLatencyBetween: 'A' and: 'B' delay: 10.
	serverA send: 'toBDelayed' to: 'B' port: 1.
	serverA send: 'toCFast' to: 'C' port: 1.
	self runFor: 20.
	self assert: timesC first < timesB first
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testMessagesFlowWithoutFaultInjection [
	serverA send: 'hello' to: 'B' port: 1.
	self runFor: 10.
	self assert: receivedAtB asArray equals: #('hello')
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testNoLatencyMessageArrivesAtBaselineTick [
	| times |
	times := OrderedCollection new.
	serverB onIncomingDo: [ :message :srv | times add: srv rootSolver time. nil ].
	serverA send: 'noDelay' to: 'B' port: 1.
	self runFor: 20.
	self assert: times asArray equals: #(4)
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testPartitionDropsMessages [
	router simulateNetworkPartition: 'A' and: 'B'.
	serverA send: 'shouldBeDropped' to: 'B' port: 1.
	self runFor: 10.
	self assert: receivedAtB isEmpty
]

{ #category : 'as yet unclassified' }
RZDevsNetworkRouterTest >> testPartitionIsSymmetric [
	router simulateNetworkPartition: 'A' and: 'B'.
	serverB send: 'shouldAlsoBeDropped' to: 'A' port: 1.
	self runFor: 10.
	self assert: receivedAtA isEmpty
]
