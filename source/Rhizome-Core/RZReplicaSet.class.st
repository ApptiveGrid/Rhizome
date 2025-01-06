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
	| memberStatus |
	memberStatus := (self remoteReplicas collect: [ :each | 
		each -> (self endpointStatusAt: each)  ]) asDictionary.
	memberStatus keysAndValuesDo: [ :remote :status |
		status 
			ifNotNil: [ 
				(self localReplica databaseVersion = status databaseVersion) ifFalse: [ 
					(self localReplica databaseVersion > status databaseVersion)
						ifTrue: [ 
								self localReplica 
									syncTransactionJournalsFrom: status databaseVersion 
									to: self localReplica databaseVersion
									target: remote  ]
						ifFalse: [ Error signal: 'replica is newer' ] ] ]
			ifNil: [ self localReplica doInitialSync: remote ]
		 ]
]
