Class {
	#name : 'RZRequestRouter',
	#superclass : 'Object',
	#instVars : [
		'cluster'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZRequestRouter >> candidateHostNamesFor: dbId [
	^ cluster placementStrategy nodeNamesForKey: dbId
]

{ #category : 'as yet unclassified' }
RZRequestRouter >> cluster: aCluster [
	cluster := aCluster
]

{ #category : 'as yet unclassified' }
RZRequestRouter >> forward: aZnRequest to: anImage [
	"HTTP-level forward of an incoming request to the resolved target image.
	Not covered by automated tests (needs a real socket/HTTP server, same as
	RZReplicaSet's endpointStatusAt:/replicateTransactionJournal:) - verify
	manually against a running cluster."
	| client targetUrl |
	targetUrl := aZnRequest url copy
		scheme: #http;
		host: anImage address;
		port: anImage port;
		yourself.
	client := ZnClient new.
	client url: targetUrl; method: aZnRequest method.
	aZnRequest hasEntity ifTrue: [ client entity: aZnRequest entity ].
	client request headerAddAll: aZnRequest headers.
	client execute.
	^ client response
]

{ #category : 'as yet unclassified' }
RZRequestRouter >> imageForHostNamed: hostName key: dbId [
	"Which specific Pharo image on that host holds dbId - deferred gap, see
	Rhizome spec.md Cluster/Node/Hashing: resolveVirtualNodeForKey: still
	assumes one image per host (anyOne). Fine for the current test setup,
	needs the Local File Lock read once multiple images per host are real."
	^ (cluster nodeWithName: hostName) resolveVirtualNodeForKey: dbId
]

{ #category : 'as yet unclassified' }
RZRequestRouter >> isEligibleCandidateFor: dbId [
	^ (self candidateHostNamesFor: dbId) includes: cluster hostLeaseManager selfHost
]

{ #category : 'as yet unclassified' }
RZRequestRouter >> resolveFor: dbId [
	"Core routing decision - see Rhizome spec.md Request Routing & Primary-Findung.
	No probing of remote candidates needed anymore: the ownership store is the
	single shared source of truth, so we can just read it directly instead of
	asking candidates in Rendezvous order whether they think they are primary."
	| record promoted winner |
	(cluster hostLeaseManager isWritableFor: dbId) ifTrue: [ ^ RZRoutingDecision local ].

	record := cluster ownershipStore read: dbId.
	(record notNil and: [ record leaseUntil > DateAndTime now ])
		ifTrue: [ ^ RZRoutingDecision forward: (self imageForHostNamed: record primaryHost key: dbId) ].

	(self isEligibleCandidateFor: dbId)
		ifFalse: [ ^ RZRoutingDecision forward: (self imageForHostNamed: (self candidateHostNamesFor: dbId) first key: dbId) ].

	promoted := cluster hostLeaseManager tryPromoteFor: dbId.
	promoted ifNotNil: [ ^ RZRoutingDecision local ].

	winner := cluster ownershipStore read: dbId.
	^ winner
		ifNil: [ RZRoutingDecision retry ]
		ifNotNil: [ RZRoutingDecision forward: (self imageForHostNamed: winner primaryHost key: dbId) ]
]

{ #category : 'as yet unclassified' }
RZRequestRouter >> route: aZnRequest dbId: dbId localHandler: aBlock [
	"Main entry point: resolve who should handle dbId, then either run the
	local handler block or forward the raw HTTP request to the right image."
	| decision |
	decision := self resolveFor: dbId.
	decision isLocal ifTrue: [ ^ aBlock value: aZnRequest ].
	decision isForward ifTrue: [ ^ self forward: aZnRequest to: decision targetImage ].
	^ ZnResponse serviceUnavailable: 'primary not yet determined, retry'
]
