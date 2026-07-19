Class {
	#name : 'RZSoilReplicateVisitor',
	#superclass : 'SoilVisitor',
	#instVars : [
		'socket'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'private - protocol' }
RZSoilReplicateVisitor >> sendCommand: aCommand [ 
	socket sendMessage: aCommand serialize.
	^ STON fromString: socket readMessage
]

{ #category : 'accessing' }
RZSoilReplicateVisitor >> socket: aZnWebSocket [ 
	socket := aZnWebSocket
]

{ #category : 'api' }
RZSoilReplicateVisitor >> traverse [
	| response |
	response := self sendCommand: (RZInitializeDatabase new 
		id: soil path basename;
		databaseVersion: soil control databaseVersion).
	response isSuccess ifFalse: [ Error signal: 'nope' ].
	self visitSoil: soil
]

{ #category : 'visiting' }
RZSoilReplicateVisitor >> visitDatabaseJournal: aSoilJournal [ 
	^ aSoilJournal 
]

{ #category : 'visiting' }
RZSoilReplicateVisitor >> visitMetaSegment: aSoilMetaSegment [ 
	^ super visitMetaSegment: aSoilMetaSegment
]

{ #category : 'visiting' }
RZSoilReplicateVisitor >> visitParameters: aSoilParameterFile [ 	
	^ aSoilParameterFile 
]

{ #category : 'visiting' }
RZSoilReplicateVisitor >> visitPersistentClusterVersion: aSoilPersistentClusterVersion [ 
	| backupCluster |
	super visitPersistentClusterVersion: aSoilPersistentClusterVersion.
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
	aSoilPersistentClusterVersion indexIds do:[ :indexId |
		self processIndexId: indexId segment: aSoilPersistentClusterVersion segment ].
	^ aSoilPersistentClusterVersion
]
