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
			spec
				package: 'Rhizome' with: [ ];
				package: 'Rhizome-Tests' with: [ spec requires: #('Rhizome') ].

			spec
				group: 'default' with: #('Core');
				group: 'Core' with: #('Rhizome' 'Rhizome-Tests') ].
]
