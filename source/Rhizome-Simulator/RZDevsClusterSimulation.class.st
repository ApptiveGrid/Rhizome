"
The one DEVS model a simulated cluster runs in, shared by every host in it.

Until now the fault-injecting router was only asked a question - would you drop this? - and the call went straight to its target, arriving before it was sent. The router was an oracle rather than a component. Here it is a component again: a host hands a message to it, it carries or delays or drops it, and the receiver gets it in a later step of the model.

One model, one simulation, one router for the whole cluster. Each RZDevsSimulatedNetwork - there is one per host - holds the same instance of me.

What is not here yet is a second run: DEVSBasicSolver>>simulate: re-initialises the model at the current clock, so #runTo: is once per scenario. Making the solver resumable is Stufe A of the roadmap, and until it is done a test sends, runs, and looks.
"
Class {
	#name : 'RZDevsClusterSimulation',
	#superclass : 'Object',
	#instVars : [
		'devsNetwork',
		'simulation',
		'servers'
	],
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'adding' }
RZDevsClusterSimulation >> hostAt: anAddress deliverWith: aBlock [
	"One host with one server on it, standing for one Rhizome host. The block is
	called with the arriving message, in the step it arrives in; what it answers is
	not sent back, because nothing here waits for an answer yet."

	| host server |
	servers at: anAddress ifPresent: [ :each | ^ each ].
	server := DEVSPluggableServer new
		          name: ('server-' , anAddress asString) asSymbol;
		          port: self port;
		          yourself.
	server onIncomingDo: [ :message :each |
		aBlock value: message.
		nil ].
	host := DEVSNetworkHost new
		        name: ('host-' , anAddress asString) asSymbol;
		        address: anAddress;
		        yourself.
	host addServer: server.
	devsNetwork addHost: host.
	servers at: anAddress put: server.
	^ server
]

{ #category : 'initialization' }
RZDevsClusterSimulation >> initialize [
	super initialize.
	servers := Dictionary new.
	devsNetwork := DEVSNetwork new
		               name: #cluster;
		               yourself.
	"before any host: addHost: couples each one to whatever router is in place"
	devsNetwork router: DEVSFaultInjectingNetworkRouter new.
	simulation := DEVSSimulation new.
	simulation model: devsNetwork.
	simulation coordinator: DEVSRootSolver new
]

{ #category : 'accessing' }
RZDevsClusterSimulation >> knowsHostAt: anAddress [
	^ servers includesKey: anAddress
]

{ #category : 'accessing' }
RZDevsClusterSimulation >> port [
	"One port per host is enough while the only thing travelling is the journal.
	Rhizome addresses a node by host and port; the port lives in the payload until
	something needs to be routed by it."

	^ 1
]

{ #category : 'accessing' }
RZDevsClusterSimulation >> router [
	^ devsNetwork router
]

{ #category : 'running' }
RZDevsClusterSimulation >> runTo: aTime [
	"Let the model run. Once per scenario - see the class comment."

	simulation runTo: aTime
]

{ #category : 'sending' }
RZDevsClusterSimulation >> sendFrom: anAddress payload: aPayload to: aRemoteAddress [
	"Hand the message to this host's server. It reaches the router in the next step
	and the far side in the one after that, or later, or never - which is the whole
	point of sending it rather than calling."

	(servers at: anAddress) send: aPayload to: aRemoteAddress port: self port
]

{ #category : 'accessing' }
RZDevsClusterSimulation >> simulation [
	^ simulation
]

{ #category : 'accessing' }
RZDevsClusterSimulation >> time [
	^ simulation coordinator time
]
