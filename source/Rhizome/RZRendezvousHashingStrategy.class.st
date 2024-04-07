Class {
	#name : #RZRendezvousHashingStrategy,
	#superclass : #Object,
	#instVars : [
		'cluster'
	],
	#category : #Rhizome
}

{ #category : #accessing }
RZRendezvousHashingStrategy >> cluster: aRZCluster [ 
	cluster := aRZCluster 
]

{ #category : #'as yet unclassified' }
RZRendezvousHashingStrategy >> nodeNameForKey: aString [ 
	| names hashes |
	names := cluster nodeNames.
	hashes := names collect: [ :name | 
		(NCHMurmur3 withSeed: 0) 
			hash: (name,aString) asByteArray ].
	^ names at: (hashes indexOf: hashes sorted last)
]

{ #category : #'as yet unclassified' }
RZRendezvousHashingStrategy >> nodeNamesForKey: aString [ 
	| names hashes |
	names := cluster nodeNames.
	hashes := names collect: [ :name | 
		(NCHMurmur3 withSeed: 0) 
			hash: (name,aString) asByteArray ].
	^ (hashes sorted reverse first: 3) collect: [ :hash |
		 names at: (hashes indexOf: hash) ] 
]
