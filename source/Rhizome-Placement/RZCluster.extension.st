Extension { #name : 'RZCluster' }

{ #category : '*Rhizome-Placement' }
RZCluster >> defaultPlacementStrategy [
	^ RZRendezvousHashingStrategy new 
]
