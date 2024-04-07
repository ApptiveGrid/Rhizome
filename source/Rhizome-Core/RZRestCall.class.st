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
RZRestCall >> endpoint [
	^ delegate node
]

{ #category : #accessing }
RZRestCall >> node [ 
	^ delegate node 
]
