Class {
	#name : #RZSoilReplica,
	#superclass : #Object,
	#instVars : [
		'soil',
		'state',
		'notificationHandler',
		'members'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZSoilReplica >> databaseId [
	^ soil path basename
]

{ #category : #'as yet unclassified' }
RZSoilReplica >> doInitialSync: remote [
	RZSoilReplicateVisitor new 
		socket: (ZnWebSocket to: 'ws://', remote addressString ,':', remote port asString ,'/ws');
		soil: soil;
		traverse
]

{ #category : #accessing }
RZSoilReplica >> endpointStatusAt: aReplica [ 
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
RZSoilReplica >> id [
	^ soil path basename
]

{ #category : #accessing }
RZSoilReplica >> memberAddresses: aCollection [ 
	members := aCollection do: [ :each |
		each primary: self  ]
]

{ #category : #accessing }
RZSoilReplica >> members: aCollection [ 
	members := aCollection
]

{ #category : #'instance creation' }
RZSoilReplica >> newNotificationHandler [
	^ RZNotificationHandler new
		replica: self 
]

{ #category : #accessing }
RZSoilReplica >> notificationHandler [
	^ notificationHandler ifNil: [ 
		notificationHandler := self newNotificationHandler ]
]

{ #category : #'as yet unclassified' }
RZSoilReplica >> replicateTransactionJournal: aSoilTransactionJournal [
	members do: [ :member | 
		member replicateTransactionJournal: aSoilTransactionJournal] 
]

{ #category : #accessing }
RZSoilReplica >> soil: aSoil [ 
	soil := aSoil.
	soil notificationHandler: self notificationHandler
]

{ #category : #accessing }
RZSoilReplica >> start [
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
RZSoilReplica >> stop [
	soil close 
]

{ #category : #'as yet unclassified' }
RZSoilReplica >> syncTransactionJournalsFrom: from to: to [ 
	(from + 1 to: to) do: [ :index |
		self replicateTransactionJournal: (soil journal transactionJournalAt: index) ]
	
]

{ #category : #'as yet unclassified' }
RZSoilReplica >> transactionCreated: aSoilTransaction [ 
	
]
