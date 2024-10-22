Class {
	#name : #RZClusterSimulationBuilder,
	#superclass : #Object,
	#category : #'Rhizome-Simulator'
}

{ #category : #'instance creation' }
RZClusterSimulationBuilder >> build: cluster [ 
	| network |
	network := RZSimulatedNetwork new. 
	cluster nodes do: [ :node |
		network registerNode: node  ].
	^ network 
]
