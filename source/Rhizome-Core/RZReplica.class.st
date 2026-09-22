Class {
	#name : 'RZReplica',
	#superclass : 'Object',
	#instVars : [
		'replicaSet',
		'node'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZReplica >> address [
	^ node address
]

{ #category : 'accessing' }
RZReplica >> host [
	^ node host
]

{ #category : 'accessing' }
RZReplica >> node: aRZNode [ 
	node := aRZNode 
]

{ #category : 'accessing' }
RZReplica >> port [
	^ node port
]

{ #category : 'printing' }
RZReplica >> printOn: aStream [ 
	aStream << 'replica on '.
	node printOn: aStream 
]

{ #category : 'as yet unclassified' }
RZReplica >> replicaSet [
	^ replicaSet
]

{ #category : 'as yet unclassified' }
RZReplica >> replicaSet: aRZReplicaSet [ 
	replicaSet := aRZReplicaSet 
]
