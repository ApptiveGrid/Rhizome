Class {
	#name : #RZSimulatedRestServer,
	#superclass : #Object,
	#instVars : [
		'virtualNode'
	],
	#category : #'Rhizome-Simulator'
}

{ #category : #running }
RZSimulatedRestServer >> apiHandler [ 
	^ RZRestServerDelegate new 
		virtualNode: virtualNode;
		uriSpace: (ZnCallHierarchyRestUriSpace new
			rootClass: RZRestCall)
]

{ #category : #running }
RZSimulatedRestServer >> apiPrefix [
	^ #cluster
]

{ #category : #'public - layout' }
RZSimulatedRestServer >> cluster [
	^ virtualNode cluster 
]

{ #category : #options }
RZSimulatedRestServer >> debugMode [
	^ true
]

{ #category : #public }
RZSimulatedRestServer >> handleRequest: aZnRequest [
	^ ZnCurrentServer
		value: self
		during: [
			self handler handleRequest: aZnRequest  ]

]

{ #category : #running }
RZSimulatedRestServer >> handler [ 
	| handler |
	handler := ZnPrefixMappingDelegate new
 	   map: self apiPrefix to: self apiHandler.
	^ handler
]

{ #category : #accessing }
RZSimulatedRestServer >> port [
	^ virtualNode port
]

{ #category : #accessing }
RZSimulatedRestServer >> virtualNode [
	^ virtualNode
]

{ #category : #accessing }
RZSimulatedRestServer >> virtualNode: aRZLocalNode [ 
	virtualNode := aRZLocalNode 
]
