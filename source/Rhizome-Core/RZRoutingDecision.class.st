Class {
	#name : 'RZRoutingDecision',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'targetImage'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZRoutingDecision class >> forward: anImage [
	^ self new kind: #forward; targetImage: anImage; yourself
]

{ #category : 'as yet unclassified' }
RZRoutingDecision class >> local [
	^ self new kind: #local; yourself
]

{ #category : 'as yet unclassified' }
RZRoutingDecision class >> retry [
	^ self new kind: #retry; yourself
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> isForward [
	^ kind = #forward
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> isLocal [
	^ kind = #local
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> isRetry [
	^ kind = #retry
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> kind: aSymbol [
	kind := aSymbol
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> printOn: aStream [
	aStream << 'RZRoutingDecision(' << kind printString.
	targetImage ifNotNil: [ aStream << ' -> ' << targetImage printString ].
	aStream << ')'
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> targetImage [
	^ targetImage
]

{ #category : 'as yet unclassified' }
RZRoutingDecision >> targetImage: anImage [
	targetImage := anImage
]
