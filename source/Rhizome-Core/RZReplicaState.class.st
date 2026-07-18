Class {
	#name : 'RZReplicaState',
	#superclass : 'Object',
	#instVars : [
		'store',
		'dbId'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZReplicaState >> currentRecord [
	"Pull-based: always read the authoritative store directly rather than
	caching, since the store is the single source of truth for ownership
	(see Rhizome spec.md - Router darf Ownership cachen, aber kurz)."
	^ store read: dbId
]

{ #category : 'as yet unclassified' }
RZReplicaState >> dbId: anObject [
	dbId := anObject
]

{ #category : 'as yet unclassified' }
RZReplicaState >> isPrimary: aHostIdentifier [
	| record |
	record := self currentRecord.
	^ record notNil and: [ record primaryHost = aHostIdentifier ]
]

{ #category : 'as yet unclassified' }
RZReplicaState >> store: aStore [
	store := aStore
]
