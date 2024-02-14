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
