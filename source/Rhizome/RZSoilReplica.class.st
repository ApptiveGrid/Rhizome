Class {
	#name : #RZSoilReplica,
	#superclass : #Object,
	#instVars : [
		'soil',
		'state',
		'group',
		'notificationHandler'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZSoilReplica >> databaseId [
	^ #'4321'
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
RZSoilReplica >> group: aCollection [ 
	group := aCollection
]

{ #category : #'instance creation' }
RZSoilReplica >> newNotificationHandler [
	^ RZNotificationHandler new
]

{ #category : #accessing }
RZSoilReplica >> notificationHandler [
	^ notificationHandler ifNil: [ 
		notificationHandler := self newNotificationHandler ]
]

{ #category : #accessing }
RZSoilReplica >> soil: aSoil [ 
	soil := aSoil.
	soil notificationHandler: self notificationHandler
]

{ #category : #accessing }
RZSoilReplica >> start [
	| memberStatus |
	memberStatus := (group collect: [ :each | 
		each -> (self endpointStatusAt: each)  ]) asDictionary.
	memberStatus keysAndValuesDo: [ :remote :status |
		status 
			ifNotNil: [ 
				(soil databaseVersion = status databaseVersion) ifFalse: [ 
					self halt ]  ]
			ifNil: [ self doInitialSync: remote ]
		 ]
]

{ #category : #accessing }
RZSoilReplica >> stop [
	soil close 
]

{ #category : #'as yet unclassified' }
RZSoilReplica >> transactionCreated: aSoilTransaction [ 
	
]