Class {
	#name : 'RZReplicaSetFencingTest',
	#superclass : 'TestCase',
	#instVars : [
		'cluster',
		'replicaSet',
		'localReplica',
		'remoteReplica'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'as yet unclassified' }
RZReplicaSetFencingTest >> setUp [
	| localHost remoteHost localImage remoteImage |
	super setUp.
	cluster := RZCluster new.
	cluster localAddress: '127.0.0.1'.
	cluster buildNodesFromList: { #hostA -> '127.0.0.1'. #hostB -> '10.0.0.2' }.
	cluster ownershipStore: RZInMemoryOwnershipStore new.

	localHost := cluster localNode.
	localImage := RZLocalImage port: 9001.
	localHost addVirtualNode: localImage.

	remoteHost := cluster nodeWithName: #hostB.
	remoteImage := RZRemoteImage port: 9002.
	remoteHost addVirtualNode: remoteImage.

	replicaSet := RZReplicaSet new key: #db1; cluster: cluster; yourself.
	localReplica := RZLocalReplica new replicaSet: replicaSet; virtualNode: localImage; yourself.
	remoteReplica := RZRemoteReplica new replicaSet: replicaSet; virtualNode: remoteImage; yourself.
	replicaSet addReplica: localReplica.
	replicaSet addReplica: remoteReplica
]

{ #category : 'as yet unclassified' }
RZReplicaSetFencingTest >> testNotPrimaryMarksLocalReplicaStale [
	| stolen |
	cluster hostLeaseManager tryPromoteFor: #db1.
	stolen := cluster ownershipStore read: #db1.
	stolen leaseUntil: (DateAndTime now - 1 second).
	cluster ownershipStore tryPromote: (RZOwnershipRecord
		dbId: #db1 primaryHost: 'host-b' epoch: stolen epoch
		leaseUntil: (DateAndTime now + 15 seconds) commitToken: 'tok-b'
		lastCommittedJournalPosition: stolen lastCommittedJournalPosition) to: stolen epoch + 1.

	self deny: localReplica isStale.
	replicaSet handleRemoteAheadOf: remoteReplica status: nil.
	self assert: localReplica isStale
]

{ #category : 'as yet unclassified' }
RZReplicaSetFencingTest >> testStillPrimaryRefusesToGuess [
	cluster hostLeaseManager tryPromoteFor: #db1.
	self should: [ replicaSet handleRemoteAheadOf: remoteReplica status: nil ] raise: Error.
	self deny: localReplica isStale
]
