Class {
	#name : 'RZSimulatedRestServer',
	#superclass : 'Object',
	#instVars : [
		'node'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'running' }
RZSimulatedRestServer >> apiHandler [ 
	^ RZRestServerDelegate new 
		node: node;
		uriSpace: (ZnCallHierarchyRestUriSpace new
			rootClass: RZRestCall)
]

{ #category : 'running' }
RZSimulatedRestServer >> apiPrefix [
	^ #cluster
]

{ #category : 'public - layout' }
RZSimulatedRestServer >> cluster [
	^ node cluster 
]

{ #category : 'options' }
RZSimulatedRestServer >> debugMode [
	^ true
]

{ #category : 'public' }
RZSimulatedRestServer >> handleRequest: aZnRequest [
	^ ZnCurrentServer
		value: self
		during: [
			self handler handleRequest: aZnRequest  ]

]

{ #category : 'running' }
RZSimulatedRestServer >> handler [ 
	| handler |
	handler := ZnPrefixMappingDelegate new
 	   map: self apiPrefix to: self apiHandler.
	^ handler
]

{ #category : 'accessing' }
RZSimulatedRestServer >> node [
	^ node
]

{ #category : 'accessing' }
RZSimulatedRestServer >> node: aRZLocalNode [ 
	node := aRZLocalNode 
]

{ #category : 'accessing' }
RZSimulatedRestServer >> port [
	^ node port
]
