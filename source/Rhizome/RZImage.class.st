Class {
	#name : #RZImage,
	#superclass : #Object,
	#instVars : [
		'node',
		'port'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZImage class >> port: anInteger [ 
	^ self new 
		port: anInteger 
]

{ #category : #accessing }
RZImage >> address [
	^ node address
]

{ #category : #accessing }
RZImage >> node: aRZNode [ 
	node := aRZNode
]

{ #category : #accessing }
RZImage >> port [
	^ port
]

{ #category : #accessing }
RZImage >> port: anInteger [ 
	port := anInteger
]

{ #category : #printing }
RZImage >> printOn: aStream [ 
	aStream << 'image: ' << port printString
]
