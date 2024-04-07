Class {
	#name : #RZReplicaSet,
	#superclass : #Object,
	#instVars : [
		'replicas'
	],
	#category : #Rhizome
}

{ #category : #adding }
RZReplicaSet >> addReplica: aRZReplica [ 
	replicas add: aRZReplica 
]

{ #category : #initialization }
RZReplicaSet >> initialize [ 
	super initialize.
	replicas := OrderedCollection new
]

{ #category : #accessing }
RZReplicaSet >> size [ 
	^ replicas size 
]
