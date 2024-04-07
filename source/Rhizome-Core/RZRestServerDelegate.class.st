Class {
	#name : #RZRestServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#instVars : [
		'node'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZRestServerDelegate >> node [

	^ node
]

{ #category : #accessing }
RZRestServerDelegate >> node: anObject [

	node := anObject
]
