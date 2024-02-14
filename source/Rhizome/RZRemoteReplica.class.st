Class {
	#name : #RZRemoteReplica,
	#superclass : #Object,
	#instVars : [
		'address',
		'port',
		'primary'
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

{ #category : #'as yet unclassified' }
RZRemoteReplica >> baseUrl [
	^ ZnUrl new 
		scheme: #http; 
		host: address printString; 
		port: port
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

{ #category : #'as yet unclassified' }
RZRemoteReplica >> primary: aRZSoilReplica [ 
	primary := aRZSoilReplica 
]

{ #category : #printing }
RZRemoteReplica >> printOn: aStream [ 
	aStream << 'remote: ' << address printString << ':' << port printString
]

{ #category : #'as yet unclassified' }
RZRemoteReplica >> replicateTransactionJournal: aSoilTransactionJournal [ 
	| response |
	response := self newClient
		url: self baseUrl / #cluster / #databases / primary id / #journals;
		entity: (ZnByteArrayEntity bytes: aSoilTransactionJournal soilSerialize);
		post 	
]
