Class {
	#name : 'RZRestServerDelegate',
	#superclass : 'ZnJSONRestServerDelegate',
	#instVars : [
		'virtualNode'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZRestServerDelegate >> virtualNode [

	^ virtualNode
]

{ #category : 'accessing' }
RZRestServerDelegate >> virtualNode: anObject [

	virtualNode := anObject
]
