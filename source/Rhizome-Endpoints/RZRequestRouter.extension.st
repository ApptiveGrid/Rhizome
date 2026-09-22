Extension { #name : 'RZRequestRouter' }

{ #category : '*Rhizome-Endpoints' }
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

{ #category : '*Rhizome-Endpoints' }
RZRequestRouter >> route: aZnRequest dbId: dbId localHandler: aBlock [
	"Main entry point: resolve who should handle dbId, then either run the
	local handler block or forward the raw HTTP request to the right image."
	| decision |
	decision := self resolveFor: dbId.
	decision isLocal ifTrue: [ ^ aBlock value: aZnRequest ].
	decision isForward ifTrue: [ ^ self forward: aZnRequest to: decision targetNode ].
	^ ZnResponse serviceUnavailable: 'primary not yet determined, retry'
]
