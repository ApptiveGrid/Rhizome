Class {
	#name : 'RZHostLeaseManagerTest',
	#superclass : 'TestCase',
	#instVars : [
		'manager',
		'store'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZHostLeaseManagerTest >> setUp [
	super setUp.
	store := RZInMemoryOwnershipStore new.
	manager := RZHostLeaseManager new.
	manager store: store; selfHost: 'host-a'; leaseDuration: 15 seconds; renewInterval: 5 seconds; safetyMargin: 2 seconds
]

{ #category : 'as yet unclassified' }
RZHostLeaseManagerTest >> testFreshPromoteMakesWritable [
	| result |
	result := manager tryPromoteFor: #db1.
	self assert: result notNil.
	self assert: (manager isWritableFor: #db1).
	self assert: (manager localEpochFor: #db1) equals: 1
]

{ #category : 'as yet unclassified' }
RZHostLeaseManagerTest >> testLosingOwnershipDemotesImmediately [
	| ownedByUs rivalCandidate |
	manager tryPromoteFor: #db1.
	self assert: (manager isWritableFor: #db1).

	"Simulate host-b winning a promotion behind our back: force the
	stored leaseUntil into the past, then have host-b successfully
	promote directly against the shared store, exactly as a real rival
	host would (through its own RZHostLeaseManager, not ours)."
	ownedByUs := store read: #db1.
	ownedByUs leaseUntil: (DateAndTime now - 1 second).
	rivalCandidate := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-b' epoch: ownedByUs epoch
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: 'rival-token'
		lastCommittedJournalPosition: ownedByUs lastCommittedJournalPosition.
	store tryPromote: rivalCandidate to: (ownedByUs epoch + 1).

	self deny: (manager renewFor: #db1) notNil.
	self deny: (manager isWritableFor: #db1)
]

{ #category : 'as yet unclassified' }
RZHostLeaseManagerTest >> testRenewAllExtendsEveryHeldLease [
	| manualClock beforeOne beforeTwo |
	manualClock := RZManualClock new.
	manager clock: manualClock.
	store clock: manualClock.
	manager tryPromoteFor: #db1.
	manager tryPromoteFor: #db2.
	beforeOne := manager writeAllowedUntilFor: #db1.
	beforeTwo := manager writeAllowedUntilFor: #db2.
	manualClock advanceBy: 1 second.
	manager renewAll.
	self assert: (manager writeAllowedUntilFor: #db1) > beforeOne.
	self assert: (manager writeAllowedUntilFor: #db2) > beforeTwo
]

{ #category : 'as yet unclassified' }
RZHostLeaseManagerTest >> testRenewExtendsWriteWindow [
	| manualClock before after |
	manualClock := RZManualClock new.
	manager clock: manualClock.
	store clock: manualClock.
	manager tryPromoteFor: #db1.
	before := manager writeAllowedUntilFor: #db1.
	manualClock advanceBy: 1 second.
	manager renewFor: #db1.
	after := manager writeAllowedUntilFor: #db1.
	self assert: after > before
]
