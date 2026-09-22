Class {
	#name : 'RZRestCall',
	#superclass : 'ZnJSONRestCall',
	#category : 'Rhizome-Endpoints',
	#package : 'Rhizome-Endpoints'
}

{ #category : 'accessing' }
RZRestCall class >> pattern [
	^ #( #none )
]

{ #category : 'accessing' }
RZRestCall >> node [
	^ delegate node 
]
