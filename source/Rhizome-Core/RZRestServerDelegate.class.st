Class {
	#name : #RZRestServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#instVars : [
		'endpoint'
	],
	#category : #'Rhizome-Core-Rhizome-Core'
}

{ #category : #accessing }
RZRestServerDelegate >> endpoint [
	^ endpoint
]

{ #category : #accessing }
RZRestServerDelegate >> endpoint: aRZEndpoint [ 
	endpoint := aRZEndpoint
]
