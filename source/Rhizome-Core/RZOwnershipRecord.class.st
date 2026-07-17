Class {
	#name : 'RZOwnershipRecord',
	#superclass : 'Object',
	#instVars : [
		'dbId',
		'primaryHost',
		'epoch',
		'leaseUntil',
		'commitToken',
		'lastCommittedJournalPosition'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZOwnershipRecord class >> dbId: aDbId primaryHost: aHost epoch: anEpoch leaseUntil: aDateAndTime commitToken: aToken lastCommittedJournalPosition: aPosition [
	^ self new
		dbId: aDbId;
		primaryHost: aHost;
		epoch: anEpoch;
		leaseUntil: aDateAndTime;
		commitToken: aToken;
		lastCommittedJournalPosition: aPosition;
		yourself
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> commitToken [
	^ commitToken
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> commitToken: anObject [
	commitToken := anObject
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> dbId [
	^ dbId
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> dbId: anObject [
	dbId := anObject
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> epoch [
	^ epoch
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> epoch: anObject [
	epoch := anObject
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> lastCommittedJournalPosition [
	^ lastCommittedJournalPosition
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> lastCommittedJournalPosition: anObject [
	lastCommittedJournalPosition := anObject
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> leaseUntil [
	^ leaseUntil
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> leaseUntil: anObject [
	leaseUntil := anObject
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> primaryHost [
	^ primaryHost
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> primaryHost: anObject [
	primaryHost := anObject
]

{ #category : 'as yet unclassified' }
RZOwnershipRecord >> printOn: aStream [
	aStream
		<< 'RZOwnershipRecord(db: ' << dbId printString
		<< ', primary: ' << primaryHost printString
		<< ', epoch: ' << epoch printString
		<< ', leaseUntil: ' << leaseUntil printString
		<< ')'
]
