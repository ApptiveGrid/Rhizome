Class {
	#name : 'RZNetwork',
	#superclass : 'Object',
	#category : 'Rhizome-Simulator',
	#package : 'Rhizome-Simulator'
}

{ #category : 'sending' }
RZNetwork >> post: anEntity to: aUrl [
	"Send something and do not wait for the answer. The one call in Rhizome that
	wants this is the journal going out to a replica - nobody reads what comes back,
	and a caller that waits for an answer it throws away cannot be modelled in
	simulated time at all.

	The default is what every caller did by hand until now: build a client, post,
	and let the answer fall on the floor. A network that runs in model time answers
	this differently - see RZDevsSimulatedNetwork."

	^ self newHttpClient
		  url: aUrl;
		  entity: anEntity;
		  post
]

{ #category : 'as yet unclassified' }
RZNetwork >> newWebSocketTo: aHost port: aPort [
	^ self subclassResponsibility
]
