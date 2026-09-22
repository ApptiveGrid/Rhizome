Extension { #name : 'RZHost' }

{ #category : '*Rhizome-Placement' }
RZHost >> resolveNodeForKey: aString [ 
	| hashes |
	nodes ifEmpty: [ Error signal: 'host ', name , ' has no nodes' ].
	hashes := nodes collect: [ :each | 
		(NCHMurmur3 withSeed: 0) hash: (each port asString, aString) asByteArray ].
	^ nodes at: (hashes indexOf: hashes sorted last)
]
