Class {
	#name : #RZLocalReplica,
	#superclass : #RZReplica,
	#instVars : [
		'soil',
		'state',
		'notificationHandler'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZLocalReplica >> databaseId [
	^ soil path basename
]

{ #category : #accessing }
RZLocalReplica >> databaseVersion [
	^ self soil control databaseVersion 
]

{ #category : #'as yet unclassified' }
RZLocalReplica >> doInitialSync: remote [
	RZSoilReplicateVisitor new 
		socket: (ZnWebSocket to: 'ws://', remote address ,':', remote port asString ,'/ws');
		soil: soil;
		traverse 
]

{ #category : #accessing }
RZLocalReplica >> id [
	^ soil path basename
]

{ #category : #'instance creation' }
RZLocalReplica >> newNotificationHandler [
	^ RZNotificationHandler new
		replica: self 
]

{ #category : #accessing }
RZLocalReplica >> notificationHandler [
	^ notificationHandler ifNil: [ 
		notificationHandler := self newNotificationHandler ]
]

{ #category : #'as yet unclassified' }
RZLocalReplica >> openSoil [
	^ (virtualNode node databaseWithId: replicaSet key) open  
]

{ #category : #accessing }
RZLocalReplica >> soil [
	^ soil ifNil: [ 
		soil := self openSoil  ]
]

{ #category : #accessing }
RZLocalReplica >> soil: aSoil [ 
	soil := aSoil.
	soil notificationHandler: self notificationHandler
]

{ #category : #accessing }
RZLocalReplica >> stop [
	soil close 
]

{ #category : #'as yet unclassified' }
RZLocalReplica >> syncTransactionJournalsFrom: from to: to [ 
	(from + 1 to: to) do: [ :index |
		self replicateTransactionJournal: (soil journal transactionJournalAt: index) ]
	
]

{ #category : #'as yet unclassified' }
RZLocalReplica >> syncTransactionJournalsFrom: from to: to target: target [ 
	(from + 1 to: to) do: [ :index |
		target replicateTransactionJournal: (soil journal transactionJournalAt: index) ]
	
]

{ #category : #'as yet unclassified' }
RZLocalReplica >> transactionCreated: aSoilTransaction [ 
	
]
