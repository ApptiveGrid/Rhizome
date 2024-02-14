Class {
	#name : #RZNotificationHandler,
	#superclass : #SoilNotificationHandler,
	#instVars : [
		'endpoint'
	],
	#category : #Rhizome
}

{ #category : #counting }
RZNotificationHandler >> transactionCommitted: txn [ 
	self halt.
]
