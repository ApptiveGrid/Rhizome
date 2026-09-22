Class {
	#name : 'RZRemoteReplica',
	#superclass : 'RZReplica',
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'instance creationb' }
RZRemoteReplica class >> address: byteArray port: anInteger [ 
	^ self new 
		address: byteArray asSocketAddress;
		port: anInteger 
]

{ #category : 'instance creationb' }
RZRemoteReplica class >> addressString: aString port: anInteger [ 
	^ self
		address: (($. split: aString) collect: #asInteger) asByteArray  
		port: anInteger 
]

{ #category : 'printing' }
RZRemoteReplica >> printOn: aStream [ 
	aStream << 'remote: ' << self address printString << ':' << self port printString
]
