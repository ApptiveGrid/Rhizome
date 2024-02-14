Class {
	#name : #RZInitializeDatabase,
	#superclass : #RZStringCommand,
	#instVars : [
		'id'
	],
	#category : #Rhizome
}

{ #category : #'as yet unclassified' }
RZInitializeDatabase >> executeIn: aHandler [ 
	aHandler database: (aHandler endpoint createDatabaseWithId: id) 
]

{ #category : #accessing }
RZInitializeDatabase >> id: aString [ 
	id := aString
]
