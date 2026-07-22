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
			spec
				package: 'Rhizome-Core' with: [ spec requires: #('NonCryptographicHashes' 'Gossip' 'Soil' 'ZincHTTPComponents') ];
				package: 'Rhizome-Simulator' with: [ spec requires: #('Rhizome-Core' 'PharoDEVS') ];
				package: 'Rhizome-Tests' with: [ spec requires: #('Rhizome-Core' 'Rhizome-Simulator') ].

			spec
				group: 'default' with: #('Core');
				group: 'Core' with: #('Rhizome-Core' 'Rhizome-Simulator' 'Rhizome-Tests') ]
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
				repository: 'github://ApptiveGrid/PharoDEVS:main/source' ]
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
