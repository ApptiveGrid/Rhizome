Class {
	#name : #RZStringCommand,
	#superclass : #RZCommand,
	#category : #'Rhizome-Core'
}

{ #category : #serializing }
RZStringCommand >> serialize [
	^ STON toString: self
]
