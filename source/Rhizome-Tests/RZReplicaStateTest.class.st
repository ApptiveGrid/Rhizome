Class {
	#name : 'RZReplicaStateTest',
	#superclass : 'TestCase',
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZReplicaStateTest >> testNoRecordIsNotPrimary [
	| store state |
	store := RZInMemoryOwnershipStore new.
	state := RZReplicaState new store: store; dbId: #db1; yourself.
	self deny: (state isPrimary: 'host-a')
]

{ #category : 'as yet unclassified' }
RZReplicaStateTest >> testReflectsCurrentStoreOwner [
	| store manager state |
	store := RZInMemoryOwnershipStore new.
	manager := RZHostLeaseManager new store: store; selfHost: 'host-a'; yourself.
	manager tryPromoteFor: #db1.
	state := RZReplicaState new store: store; dbId: #db1; yourself.
	self assert: (state isPrimary: 'host-a').
	self deny: (state isPrimary: 'host-b')
]
