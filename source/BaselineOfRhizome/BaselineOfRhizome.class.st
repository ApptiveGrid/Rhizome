Class {
	#name : #BaselineOfRhizome,
	#superclass : #BaselineOf,
	#category : #BaselineOfRhizome
}

{ #category : #baselines }
BaselineOfRhizome >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self 
				gossip: spec;
				soil: spec;
				zinc: spec.
			spec
				package: 'Rhizome-Core' with: [ spec requires: #('Gossip' 'Soil' 'ZincHTTPComponents') ];
				package: 'Rhizome-Tests' with: [ spec requires: #('Rhizome') ].

			spec
				group: 'default' with: #('Core');
				group: 'Core' with: #('Rhizome-Core' 'Rhizome-Tests') ].
]

{ #category : #'as yet unclassified' }
BaselineOfRhizome >> gossip: spec [

	spec baseline: 'Gossip' with: [ 
		spec 
			repository: 'github://ApptiveGrid/Gossip:main/source' ]
]

{ #category : #accessing }
BaselineOfRhizome >> soil: spec [
	
	spec baseline: 'Soil' with: [ 
		spec 
			repository: 'github://ApptiveGrid/Soil:main/src' ]
]

{ #category : #baselines }
BaselineOfRhizome >> zinc: spec [
	spec baseline: 'ZincHTTPComponents' with: [ 
		spec 
			loads: #('REST' 'WebSocket');
			repository: 'github://svenvc/zinc/repository']
]
