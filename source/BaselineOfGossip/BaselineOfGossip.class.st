Class {
	#name : #BaselineOfGossip,
	#superclass : #BaselineOf,
	#category : #BaselineOfGossip
}

{ #category : #baselines }
BaselineOfGossip >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec
				package: 'Gossip';
				package: 'Gossip-Tests' with: [ spec requires: #('Gossip') ].
				
			spec
				group: 'Core' with: 'Gossip';
				group: 'Tests' with: #('Gossip-Tests') ]
]
