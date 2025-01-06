Class {
	#name : 'RZInitializeDatabase',
	#superclass : 'RZStringCommand',
	#instVars : [
		'id',
		'databaseVersion'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZInitializeDatabase >> databaseVersion [

	^ databaseVersion
]

{ #category : 'accessing' }
RZInitializeDatabase >> databaseVersion: anObject [

	databaseVersion := anObject
]

{ #category : 'as yet unclassified' }
RZInitializeDatabase >> executeIn: aHandler [ 
	| database |
	database := (aHandler endpoint createDatabaseWithId: id).
	aHandler database: database.
	database databaseVersion: databaseVersion.
	^ RZSuccess new
]

{ #category : 'accessing' }
RZInitializeDatabase >> id [

	^ id
]

{ #category : 'accessing' }
RZInitializeDatabase >> id: aString [ 
	id := aString
]
