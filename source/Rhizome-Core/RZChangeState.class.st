Class {
	#name : 'RZChangeState',
	#superclass : 'RZStringCommand',
	#instVars : [
		'state'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing - structure variables' }
RZChangeState class >> state: aState [
	^ self new 
		state: aState
]

{ #category : 'accessing - structure variables' }
RZChangeState >> state: aState [ 
	state := aState 
]
