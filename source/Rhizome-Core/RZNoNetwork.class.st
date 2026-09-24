"
A cluster was asked to talk and has nobody to talk through.

Rhizome-Core sends six messages to its network - announce:to:, registerHost:, addressAt:, newRestServer among them - and the only thing that answers them is the simulator. There is no real network. RZCluster>>network used to fall back to #realNetwork, a method nobody ever wrote, so a cluster without a network failed with a doesNotUnderstand on something missing. That reads like a defect in Rhizome, and it is not: the real network has not been built, and saying so plainly is the honest answer.

A simulation puts its own in with RZCluster>>network: and never sees this.
"
Class {
	#name : 'RZNoNetwork',
	#superclass : 'Error',
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZNoNetwork >> messageText [
	^ messageText ifNil: [
		  'this cluster has no network: a simulation puts one in with RZCluster>>network:, and there is no real one to fall back on' ]
]
