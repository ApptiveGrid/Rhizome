Class {
	#name : #RZSimulatedNetwork,
	#superclass : #RZNetwork,
	#instVars : [
		'addresses'
	],
	#category : #'Rhizome-Simulator'
}

{ #category : #'as yet unclassified' }
RZSimulatedNetwork >> addressAt: aString [ 
	^ addresses at: aString 
]

{ #category : #'as yet unclassified' }
RZSimulatedNetwork >> announce: aRZLocalVirtualNode to: aString [ 
	(addresses at: aString) values do: [ :each | 
		(each cluster nodeWithAddress: aRZLocalVirtualNode node address)
				addVirtualNodeWithPort: aRZLocalVirtualNode port ]
]

{ #category : #'as yet unclassified' }
RZSimulatedNetwork >> hosts [
	^ addresses values
]

{ #category : #initialization }
RZSimulatedNetwork >> initialize [ 
	super initialize.
	addresses := Dictionary new
]

{ #category : #'instance creation' }
RZSimulatedNetwork >> newHttpClient [
	^ RZSimulatedZincClient new
		network: self;
		yourself
]

{ #category : #'instance creation' }
RZSimulatedNetwork >> newRestServer [
	^ RZSimulatedRestServer new
]

{ #category : #'as yet unclassified' }
RZSimulatedNetwork >> registerCluster: cluster [ 
	cluster nodes do: [ :node |
		node isLocalNode ifTrue: [  
			self registerNode: node ] ].
]

{ #category : #'as yet unclassified' }
RZSimulatedNetwork >> registerNode: aRZNode [ 
	| host |
	host := addresses at: aRZNode address ifAbsentPut: [ Dictionary new ].
	"host at: aRZNode server port put: aRZNode server"
]

{ #category : #'as yet unclassified' }
RZSimulatedNetwork >> virtualNodeWithAddress: aString port: aNumber [ 
	^ (addresses at: aString) at: aNumber  
]
