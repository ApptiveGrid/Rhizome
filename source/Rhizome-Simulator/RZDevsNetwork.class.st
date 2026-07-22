Class {
	#name : 'RZDevsNetwork',
	#superclass : 'DEVSNetwork',
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'as yet unclassified' }
RZDevsNetwork >> initialize [
	super initialize.
	router := RZDevsNetworkRouter new name: #router.
	self addComponent: router
]

{ #category : 'as yet unclassified' }
RZDevsNetwork >> router [
	^ router
]
