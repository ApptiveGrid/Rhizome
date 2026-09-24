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
	"Out and gone. The answer was assigned to a local variable and never read, which
	is the honest shape of this call: a journal is pushed to a replica, and nothing
	here depends on what comes back.

	Saying so rather than implying it is what lets the journal travel in simulated
	time - a call that waits cannot, and this one never had a reason to."

	node cluster network
		post: (ZnByteArrayEntity bytes: aSoilTransactionJournal soilSerialize)
		to: self baseUrl / #cluster / #databases / replicaSet key / #journals
]
