Class {
	#name : #RZBinaryCommand,
	#superclass : #RZCommand,
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #'instance creation' }
RZBinaryCommand class >> readFrom: stream [ 
	^ self new 
		readFrom: stream 
]

{ #category : #accessing }
RZBinaryCommand class >> withType: anInteger [ 
	^ (self allSubclasses reject: #isAbstract)	
		detect: [ :each | each typeCode = anInteger ]
		ifNone: [ Error signal: 'cannot find command for type code ', anInteger printString ]
]

{ #category : #serializing }
RZBinaryCommand >> serialize [
	^ ByteArray streamContents: [ :stream |
		stream nextPut: self class typeCode.
		self writeOn: stream ]
]
