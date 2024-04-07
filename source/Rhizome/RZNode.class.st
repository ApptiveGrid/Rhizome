Class {
	#name : #RZNode,
	#superclass : #Object,
	#instVars : [
		'address',
		'name',
		'virtualNodes'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZNode class >> name: aString [ 
	^ self new 
		name: aString 
]

{ #category : #'as yet unclassified' }
RZNode class >> name: aString address: addressString [ 
	^ self new 
		name: aString;
		address: addressString
]

{ #category : #adding }
RZNode >> addVirtualNode: aRZImage [ 
	aRZImage node: self.
	virtualNodes add: aRZImage 
]

{ #category : #accessing }
RZNode >> address [
	^ address
]

{ #category : #accessing }
RZNode >> address: aString [ 
	address := aString
]

{ #category : #testing }
RZNode >> hasName: aString [ 
	^ name = aString 
]

{ #category : #initialization }
RZNode >> initialize [ 
	super initialize.
	virtualNodes := OrderedCollection new
]

{ #category : #accessing }
RZNode >> name [
	^ name
]

{ #category : #accessing }
RZNode >> name: aString [ 
	name := aString 
]

{ #category : #accessing }
RZNode >> port [
	self shouldBeImplemented.
]

{ #category : #printing }
RZNode >> printOn: aStream [ 
	aStream <<  name asString << '['.
	address printOn: aStream.
	aStream << ']'
]

{ #category : #accessing }
RZNode >> virtualNodes [
	^ virtualNodes
]
