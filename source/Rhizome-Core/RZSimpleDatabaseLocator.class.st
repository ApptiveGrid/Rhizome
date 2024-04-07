Class {
	#name : #RZSimpleDatabaseLocator,
	#superclass : #Object,
	#instVars : [
		'endpoint'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZSimpleDatabaseLocator >> endpoint: aRZEndpoint [ 
	endpoint := aRZEndpoint 
]

{ #category : #'as yet unclassified' }
RZSimpleDatabaseLocator >> pathForId: aString [ 
	^ endpoint basePath / aString
]
