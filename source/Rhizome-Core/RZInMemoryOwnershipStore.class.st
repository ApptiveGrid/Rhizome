Class {
	#name : 'RZInMemoryOwnershipStore',
	#superclass : 'RZOwnershipStore',
	#instVars : [
		'records',
		'semaphore',
		'clock'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> clock [
	"The store keeps its own clock on purpose: expiry is decided against the
	stored truth, so a candidate cannot force an expiry claim by carrying a
	clock of its own."
	^ clock
]

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> clock: aClock [
	clock := aClock
]

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> initialize [
	super initialize.
	records := Dictionary new.
	semaphore := Semaphore forMutualExclusion.
	clock := DateAndTime
]

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> read: dbId [
	^ records at: dbId ifAbsent: [ nil ]
]

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> tryPromote: aRecord to: newEpoch [
	^ semaphore critical: [
		| current promoted |
		current := records at: aRecord dbId ifAbsent: [ nil ].
		(current isNil
			or: [ current epoch = aRecord epoch
				and: [ current leaseUntil < clock now ] ])
			ifTrue: [
				promoted := aRecord copy.
				promoted epoch: newEpoch.
				records at: aRecord dbId put: promoted.
				promoted ]
			ifFalse: [ nil ] ]
]

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> tryRenew: aRecord [
	^ semaphore critical: [
		| current |
		current := records at: aRecord dbId ifAbsent: [ nil ].
		(current notNil
			and: [ current primaryHost = aRecord primaryHost
				and: [ current epoch = aRecord epoch
					and: [ current commitToken = aRecord commitToken ] ] ])
			ifTrue: [
				records at: aRecord dbId put: aRecord.
				aRecord ]
			ifFalse: [ nil ] ]
]
