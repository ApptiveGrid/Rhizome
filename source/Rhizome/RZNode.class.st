Class {
	#name : #RZNode,
	#superclass : #Object,
	#instVars : [
		'address',
		'name',
		'images'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZNode class >> name: aString [ 
	^ self new 
		name: aString 
]

{ #category : #adding }
RZNode >> addImage: aRZImage [ 
	aRZImage node: self.
	images add: aRZImage 
]

{ #category : #accessing }
RZNode >> address [
	^ address
]

{ #category : #accessing }
RZNode >> address: aString [ 
	address := aString
]

{ #category : #accessing }
RZNode >> images [
	^ images
]

{ #category : #initialization }
RZNode >> initialize [ 
	super initialize.
	images := OrderedCollection new
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
	aStream << 'node: ' << name printString << '('.
	images 
		do: [:image| image printOn: aStream ]
		separatedBy: [ aStream << ',' ].
	aStream << ')'
]
