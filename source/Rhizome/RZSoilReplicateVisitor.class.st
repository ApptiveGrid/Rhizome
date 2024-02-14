Class {
	#name : #RZSoilReplicateVisitor,
	#superclass : #SoilInstanceVisitor,
	#instVars : [
		'socket'
	],
	#category : #Rhizome
}

{ #category : #'private - protocol' }
RZSoilReplicateVisitor >> sendCommand: aCommand [ 
	socket sendMessage: aCommand serialize
]

{ #category : #accessing }
RZSoilReplicateVisitor >> socket: aZnWebSocket [ 
	socket := aZnWebSocket
]

{ #category : #api }
RZSoilReplicateVisitor >> traverse [
	| response |
	response := self sendCommand: (RZInitializeDatabase new id: soil path basename).
	self halt.
	super traverse: soil.
	self halt.
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
			aSoilPersistentClusterVersion objectId writeOn: stream.  
			stream nextPutAll: backupCluster serialize ])).
	backupCluster references do: [ :reference |
		self visit: reference ].
	aSoilPersistentClusterVersion indexIds do:[ :indexId |
		self processIndexId: indexId segment: aSoilPersistentClusterVersion segment ].

	^ aSoilPersistentClusterVersion 
]
