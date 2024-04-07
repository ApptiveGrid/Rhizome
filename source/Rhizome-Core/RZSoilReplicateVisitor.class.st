Class {
	#name : #RZSoilReplicateVisitor,
	#superclass : #SoilInstanceVisitor,
	#instVars : [
		'socket'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #'private - protocol' }
RZSoilReplicateVisitor >> sendCommand: aCommand [ 
	socket sendMessage: aCommand serialize.
	^ STON fromString: socket readMessage
]

{ #category : #accessing }
RZSoilReplicateVisitor >> socket: aZnWebSocket [ 
	socket := aZnWebSocket
]

{ #category : #api }
RZSoilReplicateVisitor >> traverse [
	| response |
	response := self sendCommand: (RZInitializeDatabase new 
		id: soil path basename;
		databaseVersion: soil databaseVersion).
	response isSuccess ifFalse: [ Error signal: 'nope' ].
	super traverse: soil
]

{ #category : #api }
RZSoilReplicateVisitor >> traverse: aSoil [ 
	| response |
	response := self sendCommand: (RZInitializeDatabase new id: soil id).
	super traverse: aSoil.
	self halt.
]

{ #category : #visiting }
RZSoilReplicateVisitor >> visitDatabaseJournal: aSoilJournal [ 
	^ aSoilJournal 
]

{ #category : #visiting }
RZSoilReplicateVisitor >> visitMetaSegment: aSoilMetaSegment [ 
	^ aSoilMetaSegment 
]

{ #category : #visiting }
RZSoilReplicateVisitor >> visitParameters: aSoilParameterFile [ 	
	^ aSoilParameterFile 
]

{ #category : #visiting }
RZSoilReplicateVisitor >> visitPersistentClusterVersion: aSoilPersistentClusterVersion [ 
	| backupCluster |
	backupCluster := aSoilPersistentClusterVersion copy
		behaviorDescriptions: aSoilPersistentClusterVersion behaviorDescriptions;
		references: aSoilPersistentClusterVersion references;
		bytes: aSoilPersistentClusterVersion bytes;
		version: aSoilPersistentClusterVersion version;
		resetPreviousVersion.
	self sendCommand: (RZWriteCluster new 
		objectId: aSoilPersistentClusterVersion objectId;
		cluster: (ByteArray streamContents: [:stream |
			stream nextPutAll: backupCluster serialize ])).
	backupCluster references do: [ :reference |
		self visit: reference ].
	aSoilPersistentClusterVersion indexIds do:[ :indexId |
		self processIndexId: indexId segment: aSoilPersistentClusterVersion segment ].

	^ aSoilPersistentClusterVersion 
]
