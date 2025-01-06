Class {
	#name : 'RZReplica',
	#superclass : 'Object',
	#instVars : [
		'replicaSet',
		'virtualNode'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZReplica >> address [
	^ virtualNode address
]

{ #category : 'accessing' }
RZReplica >> node [
	^ virtualNode node
]

{ #category : 'accessing' }
RZReplica >> port [
	^ virtualNode port
]

{ #category : 'printing' }
RZReplica >> printOn: aStream [ 
	aStream << 'replica on '.
	virtualNode printOn: aStream 
]

{ #category : 'as yet unclassified' }
RZReplica >> replicaSet: aRZReplicaSet [ 
	replicaSet := aRZReplicaSet 
]

{ #category : 'accessing' }
RZReplica >> virtualNode: aRZVirtualNode [ 
	virtualNode := aRZVirtualNode 
]
