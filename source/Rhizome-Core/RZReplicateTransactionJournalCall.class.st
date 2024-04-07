Class {
	#name : #RZReplicateTransactionJournalCall,
	#superclass : #RZRestCall,
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZReplicateTransactionJournalCall class >> pattern [ 
	^ #( 'databases' '*' 'journals' )
]

{ #category : #public }
RZReplicateTransactionJournalCall >> get [ 
	| db |
	db := self endpoint
		databaseWithId: request url pathSegments second
		ifAbsent: [
			response :=  ZnResponse notFound: request url.
			^ self  ].
	response := ZnResponse ok: (ZnEntity 
		with: (STON toString: (RZSoilStatus new soil: db))
		type: (ZnMimeType main: 'text' sub: 'ston'))
]

{ #category : #public }
RZReplicateTransactionJournalCall >> post [ 
	| db |
	db := self endpoint
		databaseWithId: variables first
		ifAbsent: [
			response :=  ZnResponse notFound: request url.
			^ self  ].
	db isOpen ifFalse: [ db open ].
	db replayTransactionJournal: request contents soilMaterialize.
	response := ZnResponse ok: (ZnEntity 
		with: (STON toString: (RZSoilStatus new soil: db))
		type: (ZnMimeType main: 'text' sub: 'ston'))
]
