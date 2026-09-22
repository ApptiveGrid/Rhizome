Extension { #name : 'RZRemoteReplica' }

{ #category : '*Rhizome-Endpoints' }
RZRemoteReplica >> baseUrl [
	^ ZnUrl new 
		scheme: #http; 
		host: self address; 
		port: self port
]

{ #category : '*Rhizome-Endpoints' }
RZRemoteReplica >> replicateTransactionJournal: aSoilTransactionJournal [ 
	| response |
	response := node cluster network newHttpClient
		url: self baseUrl / #cluster / #databases / replicaSet key / #journals;
		entity: (ZnByteArrayEntity bytes: aSoilTransactionJournal soilSerialize);
		post 	
]
