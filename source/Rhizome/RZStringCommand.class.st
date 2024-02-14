Class {
	#name : #RZStringCommand,
	#superclass : #RZCommand,
	#category : #Rhizome
}

{ #category : #serializing }
RZStringCommand >> serialize [
	^ STON toString: self
]
