Class {
	#name : 'RZRestServerDelegate',
	#superclass : 'ZnJSONRestServerDelegate',
	#instVars : [
		'node'
	],
	#category : 'Rhizome-Endpoints',
	#package : 'Rhizome-Endpoints'
}

{ #category : 'accessing' }
RZRestServerDelegate >> node [

	^ node
]

{ #category : 'accessing' }
RZRestServerDelegate >> node: anObject [

	node := anObject
]
