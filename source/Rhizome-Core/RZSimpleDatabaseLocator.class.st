Class {
	#name : 'RZSimpleDatabaseLocator',
	#superclass : 'Object',
	#instVars : [
		'host'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZSimpleDatabaseLocator >> host: aRZHost [ 
	host := aRZHost 
]

{ #category : 'as yet unclassified' }
RZSimpleDatabaseLocator >> pathForId: aString [ 
	^ host basePath / aString
]
