Class {
	#name : 'RZCluster',
	#superclass : 'Object',
	#instVars : [
		'localAddress',
		'placementStrategy',
		'network',
		'hostLeaseManager',
		'ownershipStore',
		'hosts'
	],
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'adding' }
RZCluster >> addHost: aRZHost [ 
	aRZHost cluster: self.
	hosts add: aRZHost 
]

{ #category : 'as yet unclassified' }
RZCluster >> announceAll [
	self remoteHosts do: [ :host | 
		network announce: self localNode to: host address  ]
]

{ #category : 'as yet unclassified' }
RZCluster >> buildHostsFromList: aCollection [ 
	aCollection do: [ :assoc | 
		self addHost: ((assoc value = localAddress)
			ifTrue: [  RZLocalHost name: assoc key address: assoc value ]
			ifFalse: [ RZRemoteHost name: assoc key address: assoc value ]) ]
]

{ #category : 'as yet unclassified' }
RZCluster >> hostLeaseManager [
	^ hostLeaseManager ifNil: [
		hostLeaseManager := RZHostLeaseManager new
			store: self ownershipStore;
			selfHost: self localHost name;
			yourself ]
]

{ #category : 'as yet unclassified' }
RZCluster >> hostLeaseManager: aManager [
	hostLeaseManager := aManager
]

{ #category : 'as yet unclassified' }
RZCluster >> hostNameForKey: aString [ 
	^ self hostWithName: (self placementStrategy hostNameForKey: aString)  
]

{ #category : 'private - tree building' }
RZCluster >> hostNamed: aString [ 
	^ hosts detect: [ :each | each hasName: aString ]
]

{ #category : 'as yet unclassified' }
RZCluster >> hostNames [
	^ hosts collect: #name
]

{ #category : 'as yet unclassified' }
RZCluster >> hostWithAddress: anAddress [ 
	^ hosts 
		detect: [ :each | each address = anAddress ]
		ifNone: [ nil ]
]

{ #category : 'as yet unclassified' }
RZCluster >> hostWithAddress: anAddress andPort: aPort [ 
	^ hosts 
		detect: [ :each | each address = anAddress and: [ each port = aPort ] ]
		ifNone: [ nil ]
]

{ #category : 'flow interface' }
RZCluster >> hostWithName: aString [ 
	^ hosts detect: [ :host | host name = aString  ]
]

{ #category : 'accessing' }
RZCluster >> hosts [
	^ hosts
]

{ #category : 'accessing' }
RZCluster >> hosts: aCollection [ 
	hosts := aCollection 
]

{ #category : 'initialization' }
RZCluster >> initialize [ 
	super initialize.
	hosts := OrderedCollection new
]

{ #category : 'accessing' }
RZCluster >> localAddress: aString [ 
	localAddress := aString
]

{ #category : 'as yet unclassified' }
RZCluster >> localHost [
	^ self hostWithAddress: localAddress 
]

{ #category : 'as yet unclassified' }
RZCluster >> localNode [
	^ self localHost localNode 
]

{ #category : 'accessing' }
RZCluster >> network [
	"What this cluster talks through, or a named error when it was given none.

	It used to fall back to #realNetwork, which nobody ever wrote - so a cluster
	without a network failed with a doesNotUnderstand on something missing, which
	reads like a defect rather than like what it is. There is no real network yet;
	only the simulator answers what Rhizome-Core sends here."

	^ network ifNil: [ RZNoNetwork signal ]
]

{ #category : 'accessing' }
RZCluster >> network: anObject [

	network := anObject
]

{ #category : 'as yet unclassified' }
RZCluster >> ownershipStore [
	^ ownershipStore ifNil: [
		ownershipStore := RZInMemoryOwnershipStore new ]
]

{ #category : 'as yet unclassified' }
RZCluster >> ownershipStore: aStore [
	ownershipStore := aStore
]

{ #category : 'as yet unclassified' }
RZCluster >> placementStrategy [
	^ placementStrategy ifNil: [ 
		placementStrategy := self defaultPlacementStrategy
			cluster: self;
			yourself ]
]

{ #category : 'as yet unclassified' }
RZCluster >> remoteHosts [
	^ hosts copyWithout: self localHost 
]

{ #category : 'as yet unclassified' }
RZCluster >> replicaSetForKey: aString [ 
	| replicaSet |
	replicaSet := RZReplicaSet new key: aString; cluster: self.
	(self placementStrategy hostNamesForKey: aString) do: [ :name | | replica |
		replica := (name = self localHost name)
			ifTrue: [ RZLocalReplica new ]
			ifFalse: [ RZRemoteReplica new ].
		replicaSet addReplica: (replica
			replicaSet: replicaSet;
			node: ((self hostWithName: name) resolveNodeForKey: aString) ) ].
	^ replicaSet 
]
