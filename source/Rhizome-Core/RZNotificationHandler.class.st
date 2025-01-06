Class {
	#name : 'RZNotificationHandler',
	#superclass : 'SoilNotificationHandler',
	#instVars : [
		'endpoint',
		'replica'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'as yet unclassified' }
RZNotificationHandler >> replica: aRZSoilReplica [ 
	replica := aRZSoilReplica 
]

{ #category : 'counting' }
RZNotificationHandler >> transactionCommitted: txn [ 
	replica replicateTransactionJournal: txn journal 
]
