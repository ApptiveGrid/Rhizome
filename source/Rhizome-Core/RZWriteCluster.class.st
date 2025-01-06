Class {
	#name : 'RZWriteCluster',
	#superclass : 'RZBinaryCommand',
	#instVars : [
		'objectId',
		'cluster'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZWriteCluster class >> typeCode [
	^ 1
]

{ #category : 'as yet unclassified' }
RZWriteCluster >> cluster: aCollection [ 
	cluster := aCollection 
]

{ #category : 'as yet unclassified' }
RZWriteCluster >> executeIn: handler [ 
	handler database objectRepository at: objectId put: cluster.
	^ RZSuccess new
]

{ #category : 'accessing' }
RZWriteCluster >> objectId: aSoilObjectId [ 
	objectId := aSoilObjectId 
]

{ #category : 'instance creation' }
RZWriteCluster >> readFrom: stream [ 
	objectId := SoilObjectId readFrom: stream.
	cluster := stream upToEnd
]

{ #category : 'writing' }
RZWriteCluster >> writeOn: stream [ 
	objectId writeOn: stream.
	stream nextPutAll: cluster 
]
