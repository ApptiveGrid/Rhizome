Extension { #name : 'RZReplicaSet' }

{ #category : '*Rhizome-Endpoints' }
RZReplicaSet >> endpointStatusAt: aReplica [ 
	| response |
	
	response := cluster network newHttpClient
		url: (ZnUrl new host: aReplica address; port: aReplica port) / #cluster / #databases / key;
		get;
		response.
	^ response isSuccess 
		ifTrue: [ STON fromString: response contents ]
		ifFalse: [ nil ]
]
