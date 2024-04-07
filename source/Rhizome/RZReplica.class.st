Class {
	#name : #RZReplica,
	#superclass : #Object,
	#instVars : [
		'soil',
		'state',
		'notificationHandler',
		'members',
		'virtualNode'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZReplica >> databaseId [
	^ soil path basename
]

{ #category : #'as yet unclassified' }
RZReplica >> doInitialSync: remote [
	RZSoilReplicateVisitor new 
		socket: (ZnWebSocket to: 'ws://', remote addressString ,':', remote port asString ,'/ws');
		soil: soil;
		traverse 
]

{ #category : #accessing }
RZReplica >> endpointStatusAt: aReplica [ 
	| response |
	response := ZnClient new 
		url: (ZnUrl new host: aReplica address printString; port: aReplica port) / #cluster / #databases / self databaseId;
		get;
		response.
	^ response isSuccess 
		ifTrue: [ STON fromString: response contents ]
		ifFalse: [ nil ]
]

{ #category : #accessing }
RZReplica >> id [
	^ soil path basename
]

{ #category : #'instance creation' }
RZReplica >> newNotificationHandler [
	^ RZNotificationHandler new
		replica: self 
]

{ #category : #accessing }
RZReplica >> notificationHandler [
	^ notificationHandler ifNil: [ 
		notificationHandler := self newNotificationHandler ]
]

{ #category : #printing }
RZReplica >> printOn: aStream [ 
	aStream << 'replica on '.
	virtualNode printOn: aStream 
]

{ #category : #'as yet unclassified' }
RZReplica >> replicateTransactionJournal: aSoilTransactionJournal [
	members do: [ :member | 
		member replicateTransactionJournal: aSoilTransactionJournal] 
]

{ #category : #accessing }
RZReplica >> soil: aSoil [ 
	soil := aSoil.
	soil notificationHandler: self notificationHandler
]

{ #category : #accessing }
RZReplica >> start [
	| memberStatus |
	memberStatus := (members collect: [ :each | 
		each -> (self endpointStatusAt: each)  ]) asDictionary.
	memberStatus keysAndValuesDo: [ :remote :status |
		status 
			ifNotNil: [ 
				(soil databaseVersion = status databaseVersion) ifFalse: [ 
					(soil databaseVersion > status databaseVersion)
						ifTrue: [ self syncTransactionJournalsFrom: status databaseVersion to: soil databaseVersion ]
						ifFalse: [ Error signal: 'replica is newer' ] ] ]
			ifNil: [ self doInitialSync: remote ]
		 ]
]

{ #category : #accessing }
RZReplica >> stop [
	soil close 
]

{ #category : #'as yet unclassified' }
RZReplica >> syncTransactionJournalsFrom: from to: to [ 
	(from + 1 to: to) do: [ :index |
		self replicateTransactionJournal: (soil journal transactionJournalAt: index) ]
	
]

{ #category : #'as yet unclassified' }
RZReplica >> transactionCreated: aSoilTransaction [ 
	
]

{ #category : #accessing }
RZReplica >> virtualNode: aRZVirtualNode [ 
	virtualNode := aRZVirtualNode 
]

{ #category : #'as yet unclassified' }
RZReplica >> virtualNode: aRZLocalNode resolveVirtualNodeForKey: aString [ 
	self shouldBeImplemented.
]
