Class {
	#name : 'RZInMemoryOwnershipStore',
	#superclass : 'RZOwnershipStore',
	#instVars : [
		'records',
		'semaphore'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZInMemoryOwnershipStore >> initialize [
	super initialize.
	records := Dictionary new.
	semaphore := Semaphore forMutualExclusion
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
				and: [ current leaseUntil < DateAndTime now ] ])
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
