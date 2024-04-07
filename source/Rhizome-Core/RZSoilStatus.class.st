Class {
	#name : #RZSoilStatus,
	#superclass : #Object,
	#instVars : [
		'databaseVersion'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZSoilStatus >> databaseVersion [
	^ databaseVersion
]

{ #category : #printing }
RZSoilStatus >> printOn: aStream [ 
	aStream << 'database version: ' << databaseVersion printString 
]

{ #category : #accessing }
RZSoilStatus >> soil: aSoil [ 
	aSoil isOpen ifFalse: [ 
		aSoil open ].
	databaseVersion := aSoil databaseVersion
]
