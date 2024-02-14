Class {
	#name : #RZRemoteReplica,
	#superclass : #Object,
	#instVars : [
		'address',
		'port'
	],
	#category : #Rhizome
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

{ #category : #accessing }
RZRemoteReplica >> address [
	^ address
]

{ #category : #accessing }
RZRemoteReplica >> address: aSocketAddress [
	address := aSocketAddress 
]

{ #category : #'as yet unclassified' }
RZRemoteReplica >> addressString [
	^ address printString 
]

{ #category : #'instance creation' }
RZRemoteReplica >> newClient [
	^ ZnClient new 
		url: (ZnUrl new host: address printString; port: port )
]

{ #category : #accessing }
RZRemoteReplica >> port [
	^ port
]

{ #category : #accessing }
RZRemoteReplica >> port: anInteger [ 
	port := anInteger 
]

{ #category : #printing }
RZRemoteReplica >> printOn: aStream [ 
	aStream << 'remote: ' << address printString << ':' << port printString
]

{ #category : #'as yet unclassified' }
RZRemoteReplica >> replicateTransactionJournal: aSoilTransactionJournal [ 
	| client |
	client := self newClient.
	client request url: (ZnUrl new scheme: #http; host: address printString; port: port ) / #cluster / #databases / '1111' / #journals.
	client request entity: (ZnByteArrayEntity bytes: aSoilTransactionJournal soilSerialize).
   client post 	
]
