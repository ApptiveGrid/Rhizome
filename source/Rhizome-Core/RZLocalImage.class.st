Class {
	#name : 'RZLocalImage',
	#superclass : 'RZImage',
	#instVars : [
		'server',
		'process',
		'running'
	],
	#category : 'Rhizome-Core-Objects',
	#package : 'Rhizome-Core',
	#tag : 'Objects'
}

{ #category : 'initialization' }
RZLocalImage >> initialize [
	super initialize.
	running := false
]

{ #category : 'testing' }
RZLocalImage >> isLocal [ 
	^ true
]

{ #category : 'testing' }
RZLocalImage >> isLocalVirtualNode [
	^ true
]

{ #category : 'testing' }
RZLocalImage >> isRunning [
	^ process notNil and: [ process isTerminated not ]
]

{ #category : 'running' }
RZLocalImage >> runPeriodicWork [
	"The tick the host lease manager no longer owns. It reads its cadence from
	the manager, which no longer acts on it by itself."
	[ running ] whileTrue: [
		self cluster hostLeaseManager renewAll.
		self cluster hostLeaseManager renewInterval wait ]
]

{ #category : 'accessing' }
RZLocalImage >> server [
	^ server ifNil: [ 
		server := self cluster network newRestServer
			virtualNode: self; 
			yourself ]
]

{ #category : 'running' }
RZLocalImage >> start [
	"Start this image's periodic work. One loop per image: today it renews the
	leases this host holds, and the gossiper is meant to join this loop rather
	than fork a second one. The REST server has its own lifecycle and is not
	touched here."
	process ifNotNil: [ ^ self ].
	running := true.
	process := [ self runPeriodicWork ]
		forkNamed: 'Rhizome periodic work on port ', port printString
]

{ #category : 'running' }
RZLocalImage >> stop [
	"Leave the loop cooperatively, then make sure no process survives this call -
	unlike Gossiper>>stop, which leaves its loop running."
	running := false.
	process ifNotNil: [ :p |
		p terminate.
		process := nil ]
]
