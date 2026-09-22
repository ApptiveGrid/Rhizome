Class {
	#name : 'BaselineOfRhizome',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfRhizome',
	#package : 'BaselineOfRhizome'
}

{ #category : 'baselines' }
BaselineOfRhizome >> baseline: spec [
	<baseline>
	self pharoDevs: spec.
	spec
		for: #common
		do: [ 
			self 
				gossip: spec;
				murmur3: spec;
				soil: spec;
				zinc: spec.
			"Rhizome-Core is the model and requires nothing. Everything that needs an
			outside project sits beside it in a package of its own, so an image can
			take the model - and discovery on top of it - without taking Soil, Zinc
			or murmur3 along."
			spec
				package: 'Rhizome-Core';
				package: 'Rhizome-Placement' with: [ spec requires: #('Rhizome-Core' 'NonCryptographicHashes') ];
				package: 'Rhizome-Soil' with: [ spec requires: #('Rhizome-Core' 'Soil') ];
				package: 'Rhizome-Endpoints' with: [ spec requires: #('Rhizome-Core' 'ZincHTTPComponents') ];
				package: 'Rhizome-Discovery' with: [ spec requires: #('Rhizome-Core' 'Gossip') ];
				package: 'Rhizome-Discovery-Tests' with: [ spec requires: #('Rhizome-Discovery') ];
				package: 'Rhizome-Discovery-Simulation-Tests' with: [ spec requires: #('Rhizome-Discovery' 'PharoDEVS') ];
				package: 'Rhizome-Simulator' with: [ spec requires: #('Rhizome-Core' 'Rhizome-Endpoints' 'PharoDEVS') ];
				package: 'Rhizome-Tests' with: [ spec requires: #('Rhizome-Core' 'Rhizome-Placement' 'Rhizome-Soil' 'Rhizome-Endpoints' 'Rhizome-Simulator') ].

			spec
				group: 'default' with: #('All');
				group: 'Model' with: #('Rhizome-Core');
				group: 'Discovery' with: #('Rhizome-Core' 'Rhizome-Discovery' 'Rhizome-Discovery-Tests');
				group: 'All' with: #('Rhizome-Core' 'Rhizome-Placement' 'Rhizome-Soil' 'Rhizome-Endpoints'
					'Rhizome-Discovery' 'Rhizome-Discovery-Tests' 'Rhizome-Discovery-Simulation-Tests'
					'Rhizome-Simulator' 'Rhizome-Tests') ]
]

{ #category : 'as yet unclassified' }
BaselineOfRhizome >> gossip: spec [

	spec baseline: 'Gossip' with: [ 
		spec 
			repository: 'github://ApptiveGrid/Gossip:main/source' ]
]

{ #category : 'as yet unclassified' }
BaselineOfRhizome >> murmur3: spec [ 
	spec baseline: 'NonCryptographicHashes' with: [ 
		spec 
			repository: 'github://ApptiveGrid/pharo-non-cryptographic-hashes:master/src' ]
]

{ #category : 'as yet unclassified' }
BaselineOfRhizome >> pharoDevs: spec [

	spec
		baseline: 'PharoDEVS' with: [ 
			spec 
				repository: 'github://soil-fabric/PharoDEVS:feature/acting-in-simulated-time/source' ]
]

{ #category : 'accessing' }
BaselineOfRhizome >> soil: spec [
	
	spec baseline: 'Soil' with: [ 
		spec 
			repository: 'github://ApptiveGrid/Soil:main/src' ]
]

{ #category : 'baselines' }
BaselineOfRhizome >> zinc: spec [
	spec baseline: 'ZincHTTPComponents' with: [ 
		spec 
			loads: #('REST' 'WebSocket');
			repository: 'github://svenvc/zinc/repository']
]
