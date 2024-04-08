Class {
	#name : #RZRestCall,
	#superclass : #ZnJSONRestCall,
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZRestCall class >> pattern [
	^ #( #none )
]

{ #category : #accessing }
RZRestCall >> virtualNode [
	^ delegate virtualNode 
]
