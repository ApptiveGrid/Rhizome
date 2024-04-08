Class {
	#name : #RZRestServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#instVars : [
		'virtualNode'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZRestServerDelegate >> virtualNode [

	^ virtualNode
]

{ #category : #accessing }
RZRestServerDelegate >> virtualNode: anObject [

	virtualNode := anObject
]
