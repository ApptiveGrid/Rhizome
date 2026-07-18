Class {
	#name : 'RZRequestRouterTest',
	#superclass : 'TestCase',
	#instVars : [
		'cluster',
		'router'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZRequestRouterTest >> setUp [
	| hosts |
	super setUp.
	cluster := RZCluster new.
	cluster localAddress: '10.0.0.1'.
	cluster buildNodesFromList: { #hostA -> '10.0.0.1'. #hostB -> '10.0.0.2'. #hostC -> '10.0.0.3'. #hostD -> '10.0.0.4' }.
	cluster ownershipStore: RZInMemoryOwnershipStore new.
	hosts := cluster nodes.
	hosts do: [ :host | host addVirtualNode: (RZLocalImage port: 9001) ].
	router := RZRequestRouter new cluster: cluster; yourself
]

{ #category : 'as yet unclassified' }
RZRequestRouterTest >> testForwardsToFirstCandidateWhenNotEligible [
	| decision |
	self deny: (router isEligibleCandidateFor: #keyA).
	decision := router resolveFor: #keyA.
	self assert: decision isForward.
	self assert: (router candidateHostNamesFor: #keyA) first equals: #hostB
]

{ #category : 'as yet unclassified' }
RZRequestRouterTest >> testForwardsToKnownValidPrimary [
	| decision |
	cluster ownershipStore tryPromote: (RZOwnershipRecord
		dbId: #keyB primaryHost: #hostB epoch: 0
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: #tokB
		lastCommittedJournalPosition: 0) to: 1.
	decision := router resolveFor: #keyB.
	self assert: decision isForward.
	self assert: decision targetImage notNil
]

{ #category : 'as yet unclassified' }
RZRequestRouterTest >> testLocalWhenAlreadyWritable [
	cluster hostLeaseManager tryPromoteFor: #keyB.
	self assert: (router resolveFor: #keyB) isLocal
]

{ #category : 'as yet unclassified' }
RZRequestRouterTest >> testPromotesWhenEligibleAndNoValidPrimary [
	self assert: (router isEligibleCandidateFor: #keyB).
	self assert: (router resolveFor: #keyB) isLocal.
	self assert: (cluster hostLeaseManager isWritableFor: #keyB)
]

{ #category : 'as yet unclassified' }
RZRequestRouterTest >> testRouteRunsLocalHandlerWhenWritable [
	| handled request result |
	cluster hostLeaseManager tryPromoteFor: #keyB.
	handled := false.
	request := ZnRequest get: 'http://example.com/api/users/keyB'.
	result := router route: request dbId: #keyB localHandler: [ :req | handled := true. #handledLocally ].
	self assert: handled.
	self assert: result equals: #handledLocally
]
