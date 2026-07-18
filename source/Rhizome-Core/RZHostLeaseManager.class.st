Class {
	#name : 'RZHostLeaseManager',
	#superclass : 'Object',
	#instVars : [
		'store',
		'selfHost',
		'records',
		'semaphore',
		'leaseDuration',
		'renewInterval',
		'safetyMargin',
		'process',
		'running'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> cacheRecord: aRecord [
	semaphore critical: [ records at: aRecord dbId put: aRecord ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> cachedRecordFor: dbId [
	^ semaphore critical: [ records at: dbId ifAbsent: [ nil ] ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> dropCachedRecordFor: dbId [
	semaphore critical: [ records removeKey: dbId ifAbsent: [ nil ] ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> initialize [
	super initialize.
	records := Dictionary new.
	semaphore := Semaphore forMutualExclusion.
	leaseDuration := 15 seconds.
	renewInterval := 5 seconds.
	safetyMargin := 2 seconds.
	running := false
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> isWritableFor: dbId [
	| record until |
	record := self cachedRecordFor: dbId.
	record ifNil: [ ^ false ].
	record primaryHost = selfHost ifFalse: [ ^ false ].
	until := self writeAllowedUntilFor: dbId.
	^ DateAndTime now < until
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> leaseDuration: aDuration [
	leaseDuration := aDuration
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> localCommitTokenFor: dbId [
	| record |
	record := self cachedRecordFor: dbId.
	^ record ifNil: [ nil ] ifNotNil: [ record commitToken ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> localEpochFor: dbId [
	| record |
	record := self cachedRecordFor: dbId.
	^ record ifNil: [ nil ] ifNotNil: [ record epoch ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> renewAll [
	| dbIds |
	dbIds := semaphore critical: [ records keys asArray ].
	dbIds do: [ :dbId | self renewFor: dbId ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> renewFor: dbId [
	"Attempt to renew our own lease for dbId. Answers the refreshed
	RZOwnershipRecord on success, or nil if we are no longer primary
	(the caller should treat that as immediate demotion)."
	| current updated result |
	current := self cachedRecordFor: dbId.
	current ifNil: [ ^ nil ].
	updated := current copy.
	updated leaseUntil: (DateAndTime now + leaseDuration).
	result := store tryRenew: updated.
	result
		ifNotNil: [ self cacheRecord: result ]
		ifNil: [ self dropCachedRecordFor: dbId ].
	^ result
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> renewInterval: aDuration [
	renewInterval := aDuration
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> safetyMargin: aDuration [
	safetyMargin := aDuration
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> selfHost [
	^ selfHost
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> selfHost: aHostIdentifier [
	selfHost := aHostIdentifier
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> start [
	running ifTrue: [ ^ self ].
	running := true.
	process := [
		[ running ] whileTrue: [
			self renewAll.
			renewInterval wait ] ]
		forkNamed: 'RZHostLeaseManager renewal loop for ', selfHost printString
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> stop [
	running := false.
	process ifNotNil: [
		process terminate.
		process := nil ]
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> store [
	^ store
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> store: aStore [
	store := aStore
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> tryPromoteFor: dbId [
	"Attempt to become primary for dbId. Answers the new RZOwnershipRecord
	on success (and caches it), or nil if the CAS failed (someone else won)."
	| observed candidate newEpoch result |
	observed := store read: dbId.
	newEpoch := observed ifNil: [ 1 ] ifNotNil: [ observed epoch + 1 ].
	candidate := RZOwnershipRecord
		dbId: dbId
		primaryHost: selfHost
		epoch: (observed ifNil: [ 0 ] ifNotNil: [ observed epoch ])
		leaseUntil: (DateAndTime now + leaseDuration)
		commitToken: UUID new asString
		lastCommittedJournalPosition: (observed ifNil: [ 0 ] ifNotNil: [ observed lastCommittedJournalPosition ]).
	result := store tryPromote: candidate to: newEpoch.
	result
		ifNotNil: [ self cacheRecord: result ]
		ifNil: [ self dropCachedRecordFor: dbId ].
	^ result
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> writeAllowedUntilFor: dbId [
	| record |
	record := self cachedRecordFor: dbId.
	^ record ifNil: [ nil ] ifNotNil: [ record leaseUntil - safetyMargin ]
]
