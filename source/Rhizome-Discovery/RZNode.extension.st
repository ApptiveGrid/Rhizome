Extension { #name : 'RZNode' }

{ #category : '*Rhizome-Discovery' }
RZNode >> announceServices [
	"Publish what this node serves and where - one gossip state per service, keyed
	under the service namespace.

	One key per service rather than one list of them, because a GossipApplicationState
	carries its own version and a partial delta over #applicationStatesAfterVersion:
	then travels only the service that moved. A list would travel whole, every time.

	The price is that a key cannot be taken back: GossipEndpointState has no
	counterpart to #applicationStateAt:put:, so a service that stops being offered
	stands until the image restarts and its new incarnation replaces the state
	wholesale. While one container is one service, that case does not arise."

	self services keysAndValuesDo: [ :name :endpoint |
		gossiper stateAt: (self class serviceKeyFor: name) put: endpoint ]
]

{ #category : '*Rhizome-Discovery' }
RZNode >> hasOpenDatabases: aCollectionOfIds [
	"Say which databases this image currently holds open - all of them, every time,
	not what changed.

	State, not events, which is what gossip is for: a member that misses a round
	misses nothing, because the next one carries the whole answer again. It also
	means the cost is bounded by how often a round happens, not by how often a
	database opens - a busy image that opens and closes a hundred times between two
	rounds sends one list.

	Not a GossipListValue, although one exists and #addToList:item: would take it.
	A list value earns its tombstones where several writers add to one set; here
	there is exactly one writer, its own image, and the value is replaced whole on
	the far side. The tombstones would be bytes that buy nothing - and this is a set
	that turns over, so there would be many of them.

	*What it costs*, measured on 2026-09-25: about 27 bytes per database and member,
	on top of 62 for the key itself. An ACK with the full delta of 11 members, each
	holding two databases open, is 4270 B against 3005 B without. The ceiling is the
	datagram: 65507 B works out to roughly 200 open databases per image at 11
	members. Nobody is near that - alpha runs at two - but whoever raises it should
	know where it ends."

	| ids |
	ids := aCollectionOfIds asArray.
	"Saying the same thing again is not saying anything, and it is worth one
	comparison to keep it that way: the caller is the registry's hot path, it answers
	for every request, and mostly nothing has changed. A state whose version moves
	for nothing lands in every partial delta for nothing."
	self openDatabases = ids ifTrue: [ ^ self ].
	self openDatabases: ids.
	gossiper stateAt: self class openDatabasesKey put: ids
]

{ #category : '*Rhizome-Discovery' }
RZNode >> discovery [
	^ RZDiscovery on: gossiper
]

{ #category : '*Rhizome-Discovery' }
RZNode >> gossipEndpoint [
	"This node's identity in the discovery: address plus the gossiper's port."
	^ gossiper localEndpoint
]

{ #category : '*Rhizome-Discovery' }
RZNode >> gossiper [
	^ gossiper
]

{ #category : '*Rhizome-Discovery' }
RZNode >> gossiper: aGossiper [
	"Take the gossiper and tell it which address to publish. Left to itself a
	GossipServer resolves its own address through NetNameResolver, which answers
	whatever the machine calls itself - not necessarily the address the others can
	reach. The host knows the address this node is published under; which port the
	server binds stays the gossiper's own business."
	gossiper := aGossiper.
	gossiper address: self publishedAddress.
	^ gossiper
]

{ #category : '*Rhizome-Discovery' }
RZNode >> publishedAddress [
	"The address the others are told about, taken from the host rather than from
	the machine's own idea of its name."
	^ NetNameResolver addressForName: self host address
]

{ #category : '*Rhizome-Discovery' }
RZNode >> seeds [
	"Where this node starts asking. Answers gossip endpoints."
	^ gossiper seedNodes
]

{ #category : '*Rhizome-Discovery' }
RZNode >> seeds: aCollectionOfEndpoints [
	"Configured, not discovered: these are only the endpoints gossip turns to
	first. A node may be in its own seed list; gossip leaves itself out when it
	picks whom to talk to."
	gossiper seedNodes: aCollectionOfEndpoints
]

{ #category : '*Rhizome-Discovery' }
RZNode >> seedsFromConfiguration: aString [
	self seeds: (RZDiscovery seedsFrom: aString)
]

{ #category : '*Rhizome-Discovery' }
RZNode >> servicesOfMember: aGossipEndpoint [
	"What another node offers, as name -> endpoint, or empty while nothing has been
	heard from it. The reading belongs to the discovery, which is also where asking
	the other way round lives - RZDiscovery>>membersOffering:."

	^ self discovery servicesOf: aGossipEndpoint
]

{ #category : '*Rhizome-Discovery' }
RZNode >> startGossiping [
	gossiper start
]

{ #category : '*Rhizome-Discovery' }
RZNode >> stopGossiping [
	gossiper ifNotNil: [ gossiper stop ]
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> openDatabasesKey [
	"The key a node publishes its open databases under. Beside #servicePrefix and
	for the same reason: what is published is the discovery's vocabulary, and the
	one place that spells it is here rather than in Gossip or in a caller."

	^ 'databases.open'
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> isServiceKey: aString [
	^ aString beginsWith: self servicePrefix
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> knownServices [
	"The names in use, and the vocabulary is not new: ApptiveGridService>>componentName
	has been answering 'apptive-base' and 'apptive-account' all along, and the internal
	proxy tells components apart by exactly those. 'apptive-scheduler' joins them - it
	was never one of the four kinds a node could be, which is why the scheduler image
	has been announcing itself as a metabase and saying nothing about the scheduler.

	'replication' is Rhizome's own, not an apptive component: it is what serves
	/cluster and /ws. Hence no prefix on it.

	And a node that offers none is a real case, not a gap: Rhizome decisions of
	2026-09-22 named #lurker for a laptop taking part without taking on work, and
	since 2026-09-25 that laptop is a GossipObserver, which publishes nothing. In
	this shape it needs no name of its own - it is the empty set of services.

	Not enforced. A name that is not here travels rather than being refused, the same
	way a wrong type used to."

	^ #( 'apptive-base' 'apptive-account' 'apptive-metabase' 'apptive-scheduler'
	     'replication' )
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> serviceKeyFor: aServiceName [
	^ self servicePrefix , aServiceName
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> serviceNameFrom: aKey [
	^ aKey allButFirst: self servicePrefix size
]

{ #category : '*Rhizome-Discovery' }
RZNode class >> servicePrefix [
	"The namespace services are published under, so that reading them back is a
	convention of the discovery rather than a string comparison scattered about.

	It lives here and not in Gossip: Gossip names Rhizome nowhere and must not - what
	a service is, is not part of a gossip protocol. This sits beside the other things
	the discovery layer puts into a gossip state."

	^ 'service.'
]
