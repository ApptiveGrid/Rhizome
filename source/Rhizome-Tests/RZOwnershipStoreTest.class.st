Class {
	#name : 'RZOwnershipStoreTest',
	#superclass : 'TestCase',
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZOwnershipStoreTest >> testFreshPromoteSucceeds [
	| store rec promoted |
	store := RZInMemoryOwnershipStore new.
	rec := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-a' epoch: 0
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: #tokA lastCommittedJournalPosition: 0.
	promoted := store tryPromote: rec to: 1.
	self assert: promoted notNil.
	self assert: promoted primaryHost equals: 'host-a'.
	self assert: promoted epoch equals: 1
]

{ #category : 'as yet unclassified' }
RZOwnershipStoreTest >> testPromoteAfterRealExpirySucceeds [
	| store rec promoted candidate result |
	store := RZInMemoryOwnershipStore new.
	rec := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-a' epoch: 5
		leaseUntil: (DateAndTime now - 1 second) commitToken: #tokA lastCommittedJournalPosition: 100.
	promoted := store tryPromote: rec to: 6.
	candidate := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-b' epoch: 6
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: #tokB lastCommittedJournalPosition: 100.
	result := store tryPromote: candidate to: 7.
	self assert: result notNil.
	self assert: result primaryHost equals: 'host-b'.
	self assert: result epoch equals: 7
]

{ #category : 'as yet unclassified' }
RZOwnershipStoreTest >> testPromoteWhileLeaseStillValidFails [
	| store rec promoted candidate result |
	store := RZInMemoryOwnershipStore new.
	rec := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-a' epoch: 0
		leaseUntil: (DateAndTime now + 30 seconds) commitToken: #tokA lastCommittedJournalPosition: 0.
	promoted := store tryPromote: rec to: 1.
	candidate := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-b' epoch: 1
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: #tokB lastCommittedJournalPosition: 0.
	result := store tryPromote: candidate to: 2.
	self assert: result isNil.
	self assert: (store read: #db1) primaryHost equals: 'host-a'
]

{ #category : 'as yet unclassified' }
RZOwnershipStoreTest >> testReadOnEmptyStoreIsNil [
	| store |
	store := RZInMemoryOwnershipStore new.
	self assert: (store read: #db1) isNil
]

{ #category : 'as yet unclassified' }
RZOwnershipStoreTest >> testRenewWithMatchingFieldsSucceeds [
	| store rec promoted renewCandidate renewed |
	store := RZInMemoryOwnershipStore new.
	rec := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-a' epoch: 0
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: #tokA lastCommittedJournalPosition: 0.
	promoted := store tryPromote: rec to: 1.
	renewCandidate := promoted copy.
	renewCandidate leaseUntil: (DateAndTime now + 30 seconds).
	renewed := store tryRenew: renewCandidate.
	self assert: renewed notNil.
	self assert: renewed leaseUntil equals: renewCandidate leaseUntil
]

{ #category : 'as yet unclassified' }
RZOwnershipStoreTest >> testRenewWithStaleEpochFails [
	| store rec promoted staleRenew result |
	store := RZInMemoryOwnershipStore new.
	rec := RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-a' epoch: 0
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: #tokA lastCommittedJournalPosition: 0.
	promoted := store tryPromote: rec to: 1.
	staleRenew := promoted copy.
	staleRenew epoch: 999.
	result := store tryRenew: staleRenew.
	self assert: result isNil
]
