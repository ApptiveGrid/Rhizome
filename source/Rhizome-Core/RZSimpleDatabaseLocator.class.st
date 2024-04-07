Class {
	#name : #RZSimpleDatabaseLocator,
	#superclass : #Object,
	#instVars : [
		'node'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZSimpleDatabaseLocator >> node: aRZNode [ 
	node := aRZNode 
]

{ #category : #'as yet unclassified' }
RZSimpleDatabaseLocator >> pathForId: aString [ 
	^ node basePath / aString
]
