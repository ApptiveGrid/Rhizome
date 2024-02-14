Class {
	#name : #RZRestCall,
	#superclass : #ZnJSONRestCall,
	#category : #Rhizome
}

{ #category : #accessing }
RZRestCall class >> pattern [
	^ #( #none )
]

{ #category : #accessing }
RZRestCall >> endpoint [
	^ delegate endpoint
]

{ #category : #'as yet unclassified' }
RZRestCall >> rhizome [
	^ delegate endpoint
]
