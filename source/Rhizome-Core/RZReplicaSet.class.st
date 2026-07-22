Class {
	#name : 'RZReplicaSet',
	#superclass : 'Object',
	#instVars : [
		'key',
		'replicas',
		'cluster'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'adding' }
RZReplicaSet >> addReplica: aRZReplica [ 
	replicas add: aRZReplica 
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> cluster [
	^ cluster
]

{ #category : 'accessing' }
RZReplicaSet >> cluster: aRZCluster [ 
	cluster := aRZCluster
]

{ #category : 'accessing' }
RZReplicaSet >> endpointStatusAt: aReplica [ 
	| response |
	
	response := cluster network newHttpClient
		url: (ZnUrl new host: aReplica address; port: aReplica port) / #cluster / #databases / key;
		get;
		response.
	^ response isSuccess 
		ifTrue: [ STON fromString: response contents ]
		ifFalse: [ nil ]
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> handleRemoteAheadOf: remote status: status [
	(self replicaState isPrimary: self cluster hostLeaseManager selfHost)
		ifTrue: [
			Error signal: 'replica is newer, but we believe we are primary - inconsistent state, refusing to guess' ]
		ifFalse: [
			self localReplica markStale ]
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> handleUnreachable: remote error: anError [
	Transcript
		show: 'Replica unreachable, skipping this sync round: ', remote printString, ' (', anError messageText, ')';
		cr
]

{ #category : 'initialization' }
RZReplicaSet >> initialize [ 
	super initialize.
	replicas := OrderedCollection new
]

{ #category : 'accessing' }
RZReplicaSet >> key [

	^ key
]

{ #category : 'accessing' }
RZReplicaSet >> key: anObject [

	key := anObject
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> localReplica [
	^ replicas detect: [ :replica | replica node = cluster localNode ]
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> remoteReplicas [
	^ replicas reject: [ :each | each node = cluster localNode ]
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> replicaState [
	^ RZReplicaState new
		store: self cluster ownershipStore;
		dbId: self key;
		yourself
]

{ #category : 'accessing' }
RZReplicaSet >> replicas [
	^ replicas
]

{ #category : 'accessing' }
RZReplicaSet >> replicateTransactionJournal: aSoilTransactionJournal [
	self remoteReplicas do: [ :replica | 
		replica replicateTransactionJournal: aSoilTransactionJournal] 
]

{ #category : 'accessing' }
RZReplicaSet >> size [ 
	^ replicas size 
]

{ #category : 'accessing' }
RZReplicaSet >> start [
	self remoteReplicas do: [ :remote |
		[ self syncWith: remote ]
			on: NetworkError
			do: [ :error | self handleUnreachable: remote error: error ] ]
]

{ #category : 'as yet unclassified' }
RZReplicaSet >> syncWith: remote [
	| status |
	status := self endpointStatusAt: remote.
	status
		ifNotNil: [
			(self localReplica databaseVersion = status databaseVersion) ifFalse: [
				(self localReplica databaseVersion > status databaseVersion)
					ifTrue: [
							self localReplica
								syncTransactionJournalsFrom: status databaseVersion
								to: self localReplica databaseVersion
								target: remote ]
					ifFalse: [ self handleRemoteAheadOf: remote status: status ] ] ]
		ifNil: [ self localReplica doInitialSync: remote ]
]
