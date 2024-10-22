Class {
	#name : #RZLocalVirtualNode,
	#superclass : #RZVirtualNode,
	#instVars : [
		'server'
	],
	#category : #'Rhizome-Core-Objects'
}

{ #category : #testing }
RZLocalVirtualNode >> isLocal [ 
	^ true
]

{ #category : #testing }
RZLocalVirtualNode >> isLocalVirtualNode [
	^ true
]

{ #category : #accessing }
RZLocalVirtualNode >> server [
	^ server ifNil: [ 
		server := self cluster network newRestServer
			virtualNode: self; 
			yourself ]
]
