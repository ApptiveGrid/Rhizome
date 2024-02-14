Class {
	#name : #RZRestServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#instVars : [
		'endpoint'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZRestServerDelegate >> endpoint [
	^ endpoint
]

{ #category : #accessing }
RZRestServerDelegate >> endpoint: aRZEndpoint [ 
	endpoint := aRZEndpoint
]
