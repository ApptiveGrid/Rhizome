Class {
	#name : 'RZNode',
	#superclass : 'Object',
	#instVars : [
		'port',
		'host',
		'services',
		'openDatabases',
		'gossiper'
	],
	#category : 'Rhizome-Core-Objects',
	#package : 'Rhizome-Core',
	#tag : 'Objects'
}

{ #category : 'accessing' }
RZNode class >> port: anInteger [ 
	^ self new 
		port: anInteger 
]

{ #category : 'accessing' }
RZNode >> address [
	^ host address
]

{ #category : 'public - layout' }
RZNode >> cluster [
	^ host cluster 
]

{ #category : 'as yet unclassified' }
RZNode >> handlesKey: aString [ 
	^ (host resolveHostForKey: aString) == host
		and: [ (host resolveNodeForKey: aString) == self ]
]

{ #category : 'accessing' }
RZNode >> host [
	^ host
]

{ #category : 'accessing' }
RZNode >> host: aRZHost [ 
	host := aRZHost 
]

{ #category : 'testing' }
RZNode >> isLocalHost [
	^ host isLocal
]

{ #category : 'testing' }
RZNode >> isLocalNode [
	self subclassResponsibility 
]

{ #category : 'accessing' }
RZNode >> openDatabases [
	"Which databases this node holds open, as it last said. Kept here for the same
	reason #services is: what a node is and does belongs to the node, and what
	gossip makes of it belongs to the discovery."

	^ openDatabases ifNil: [ openDatabases := #(  ) ]
]

{ #category : 'accessing' }
RZNode >> openDatabases: aCollectionOfIds [
	openDatabases := aCollectionOfIds asArray
]

{ #category : 'accessing' }
RZNode >> port [
	^ port
]

{ #category : 'accessing' }
RZNode >> port: anInteger [ 
	port := anInteger
]

{ #category : 'printing' }
RZNode >> printOn: aStream [ 
	aStream << 'port: ' << port asString.
	aStream << ', '.
	host printOn: aStream
]

{ #category : 'as yet unclassified' }
RZNode >> targetNodeFor: aString [ 
	^ (self handlesKey: aString)
		ifTrue: [ self ]
		ifFalse: [ (host resolveHostForKey: aString) resolveNodeForKey: aString  ] 
]

{ #category : 'accessing' }
RZNode >> offers: aServiceName at: anEndpoint [
	"This node serves that, and it is reachable there. One endpoint per service, so
	two services of one node may share an address or not - whether they do is a
	question for the deployment and not for the protocol.

	The name is the name the rest of the system already uses for a component -
	'apptive-base', 'apptive-account' - plus what Rhizome serves itself."

	self services at: aServiceName put: anEndpoint
]

{ #category : 'accessing' }
RZNode >> services [
	"What this node offers, as name -> endpoint. Empty is a real answer: a node that
	serves nothing still takes part, hears everybody and is heard."

	^ services ifNil: [ services := Dictionary new ]
]
