Class {
	#name : #RZRemoteReplica,
	#superclass : #RZReplica,
	#category : #'Rhizome-Core'
}

{ #category : #'instance creationb' }
RZRemoteReplica class >> address: byteArray port: anInteger [ 
	^ self new 
		address: byteArray asSocketAddress;
		port: anInteger 
]

{ #category : #'instance creationb' }
RZRemoteReplica class >> addressString: aString port: anInteger [ 
	^ self
		address: (($. split: aString) collect: #asInteger) asByteArray  
		port: anInteger 
]

{ #category : #'as yet unclassified' }
RZRemoteReplica >> baseUrl [
	^ ZnUrl new 
		scheme: #http; 
		host: self address; 
		port: self port
]

{ #category : #printing }
RZRemoteReplica >> printOn: aStream [ 
	aStream << 'remote: ' << self address printString << ':' << self port printString
]

{ #category : #'as yet unclassified' }
RZRemoteReplica >> replicateTransactionJournal: aSoilTransactionJournal [ 
	| response |
	response := virtualNode cluster network newHttpClient
		url: self baseUrl / #cluster / #databases / replicaSet key / #journals;
		entity: (ZnByteArrayEntity bytes: aSoilTransactionJournal soilSerialize);
		post 	
]
