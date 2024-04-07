Class {
	#name : #RZReplica,
	#superclass : #Object,
	#instVars : [
		'soil',
		'state',
		'notificationHandler',
		'virtualNode'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZReplica >> address [
	^ virtualNode address
]

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
RZReplica >> id [
	^ soil path basename
]

{ #category : #'instance creation' }
RZReplica >> newNotificationHandler [
	^ RZNotificationHandler new
		replica: self 
]

{ #category : #accessing }
RZReplica >> node [
	^ virtualNode node
]

{ #category : #accessing }
RZReplica >> notificationHandler [
	^ notificationHandler ifNil: [ 
		notificationHandler := self newNotificationHandler ]
]

{ #category : #accessing }
RZReplica >> port [
	^ virtualNode port
]

{ #category : #printing }
RZReplica >> printOn: aStream [ 
	aStream << 'replica on '.
	virtualNode printOn: aStream 
]

{ #category : #accessing }
RZReplica >> soil: aSoil [ 
	soil := aSoil.
	soil notificationHandler: self notificationHandler
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
