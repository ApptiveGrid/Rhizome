Class {
	#name : 'RZOwnershipStore',
	#superclass : 'Object',
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZOwnershipStore >> read: dbId [
	"Answer the current RZOwnershipRecord for dbId, or nil if none exists."
	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
RZOwnershipStore >> tryPromote: aRecord to: newEpoch [
	"aRecord is the observed (possibly stale/absent) current record.
	Succeeds only if epoch still matches what is stored (or none is stored)
	and the stores own staleness policy considers the old owner gone.
	Answers a new RZOwnershipRecord (primaryHost/epoch/commitToken/leaseUntil
	all updated) on success, or nil if the CAS failed."
	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
RZOwnershipStore >> tryRenew: aRecord [
	"aRecord is the callers believed-current record. Succeeds only if the
	stored record still matches exactly on primaryHost/epoch/commitToken.
	Answers a new RZOwnershipRecord with a refreshed leaseUntil on success,
	or nil if the CAS failed (someone else already changed ownership)."
	^ self subclassResponsibility
]
