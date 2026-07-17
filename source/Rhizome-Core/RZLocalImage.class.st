Class {
	#name : 'RZLocalImage',
	#superclass : 'RZImage',
	#instVars : [
		'server'
	],
	#category : 'Rhizome-Core-Objects',
	#package : 'Rhizome-Core',
	#tag : 'Objects'
}

{ #category : 'testing' }
RZLocalImage >> isLocal [ 
	^ true
]

{ #category : 'testing' }
RZLocalImage >> isLocalVirtualNode [
	^ true
]

{ #category : 'accessing' }
RZLocalImage >> server [
	^ server ifNil: [ 
		server := self cluster network newRestServer
			virtualNode: self; 
			yourself ]
]
