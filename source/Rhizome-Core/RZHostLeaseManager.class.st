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
		'clock'
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
RZHostLeaseManager >> clock [
	"The source of 'now' for every lease comparison this manager makes.
	Defaults to the DateAndTime class itself, which already answers #now -
	in production no extra object is involved. A test injects a clock it
	controls; each time reader holds its own, which is what makes clock
	skew between hosts representable at all."
	^ clock
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> clock: aClock [
	clock := aClock
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
	clock := DateAndTime
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> isWritableFor: dbId [
	| record until |
	record := self cachedRecordFor: dbId.
	record ifNil: [ ^ false ].
	record primaryHost = selfHost ifFalse: [ ^ false ].
	until := self writeAllowedUntilFor: dbId.
	^ clock now < until
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
	"Renew every lease this host currently holds, once. Nothing inside this
	class calls it on a timer: the manager owns no process. Whoever drives the
	host decides when a renewal round happens - the RZNode in production, the
	model in a simulation - and reads #renewInterval for how often."
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
	updated leaseUntil: (clock now + leaseDuration).
	result := store tryRenew: updated.
	result
		ifNotNil: [ self cacheRecord: result ]
		ifNil: [ self dropCachedRecordFor: dbId ].
	^ result
]

{ #category : 'as yet unclassified' }
RZHostLeaseManager >> renewInterval [
	"How often a renewal round should happen. The manager does not act on this
	itself; it is the cadence it asks its driver for."
	^ renewInterval
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
		leaseUntil: (clock now + leaseDuration)
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
