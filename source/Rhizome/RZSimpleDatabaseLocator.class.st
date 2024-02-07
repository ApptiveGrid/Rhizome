Class {
	#name : #RZSimpleDatabaseLocator,
	#superclass : #Object,
	#category : #Rhizome
}

{ #category : #'as yet unclassified' }
RZSimpleDatabaseLocator >> pathForId: aString [ 
	^ aString asFileReference 
]
