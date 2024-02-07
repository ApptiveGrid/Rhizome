Class {
	#name : #RZSoilReplicateVisitor,
	#superclass : #SoilBackupVisitor,
	#instVars : [
		'socket'
	],
	#category : #Rhizome
}

{ #category : #api }
RZSoilReplicateVisitor >> backup: aSoil [ 
	| objectId |
	source := aSoil.
	self visit: source.
	
	[ toBeProcessed isEmpty ] whileFalse: [  
		objectId := toBeProcessed  removeFirst.
		self visit: (source objectRepository at: objectId) ]
]

{ #category : #accessing }
RZSoilReplicateVisitor >> socket: aZnWebSocket [ 
	socket := aZnWebSocket
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
	socket sendMessage: (ByteArray streamContents: [:stream |
		aSoilPersistentClusterVersion objectId writeOn: stream.  
		stream nextPutAll: backupCluster serialize ]).
	backupCluster references do: [ :reference |
		self process: reference ].
	aSoilPersistentClusterVersion indexIds do:[ :indexId |
		self copyIndexAt: indexId segment: aSoilPersistentClusterVersion segment ].

	^ aSoilPersistentClusterVersion 
]
