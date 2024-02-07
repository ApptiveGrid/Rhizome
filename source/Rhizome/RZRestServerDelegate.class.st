Class {
	#name : #RZRestServerDelegate,
	#superclass : #ZnJSONRestServerDelegate,
	#instVars : [
		'rhizome'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZRestServerDelegate >> rhizome [
	^ rhizome
]

{ #category : #accessing }
RZRestServerDelegate >> rhizome: aRhizome [
	rhizome := aRhizome 
]
