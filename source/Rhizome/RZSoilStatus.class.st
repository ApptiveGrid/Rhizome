Class {
	#name : #RZSoilStatus,
	#superclass : #Object,
	#instVars : [
		'databaseVersion'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZSoilStatus >> soil: aSoil [ 
	aSoil isOpen ifFalse: [ 
		aSoil open ].
	databaseVersion := aSoil databaseVersion
]
