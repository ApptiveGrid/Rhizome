Class {
	#name : 'RZReplicateVisitorFakeSocketDouble',
	#superclass : 'Object',
	#instVars : [
		'sentCommands',
		'lastCommand'
	],
	#category : 'Rhizome-Tests-Visitor',
	#package : 'Rhizome-Tests',
	#tag : 'Visitor'
}

{ #category : 'initialization' }
RZReplicateVisitorFakeSocketDouble >> initialize [
	super initialize.
	sentCommands := OrderedCollection new
]

{ #category : 'api' }
RZReplicateVisitorFakeSocketDouble >> readMessage [
	^ STON toString: RZSuccess new
]

{ #category : 'api' }
RZReplicateVisitorFakeSocketDouble >> sendMessage: aString [
	lastCommand := aString.
	sentCommands add: aString
]

{ #category : 'accessing' }
RZReplicateVisitorFakeSocketDouble >> sentCommands [
	^ sentCommands
]
