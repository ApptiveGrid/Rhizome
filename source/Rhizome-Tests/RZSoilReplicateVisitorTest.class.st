Class {
	#name : 'RZSoilReplicateVisitorTest',
	#superclass : 'TestCase',
	#instVars : [
		'soil'
	],
	#category : 'Rhizome-Tests-Visitor',
	#package : 'Rhizome-Tests',
	#tag : 'Visitor'
}

{ #category : 'helpers' }
RZSoilReplicateVisitorTest >> objectIdsSentTo: aFakeSocket [
	^ aFakeSocket sentCommands collect: [ :cmd | | stream |
		stream := ReadStream on: cmd asByteArray.
		stream next.
		SoilObjectId readFrom: stream ]
]

{ #category : 'accessing' }
RZSoilReplicateVisitorTest >> path [
	^ 'rhizome-replicate-tests' asFileReference
]

{ #category : 'initialization' }
RZSoilReplicateVisitorTest >> setUp [
	super setUp.
	soil := Soil path: self path.
	soil 
		destroy;
		initializeFilesystem
]

{ #category : 'running' }
RZSoilReplicateVisitorTest >> tearDown [
	super tearDown.
	soil ifNotNil: [ soil close ]
]

{ #category : 'tests' }
RZSoilReplicateVisitorTest >> testHandlesCyclicReferencesWithoutDuplicateWrites [
	"visitPersistentClusterVersion: used to iterate references with a raw
	self visit: reference, bypassing processReference:/processObjectId: and
	therefore the seen-set entirely - a genuine cycle in the object graph would
	recurse without ever terminating. Now that super is called, the shared
	seen-set is honored: each object (including both sides of a cycle) is
	visited/written exactly once, and the traversal terminates."
	| tx a b visitor fakeSocket objectIds |
	tx := soil newTransaction.
	a := SoilTestNestedObject new label: #a.
	b := SoilTestNestedObject new label: #b.
	a reference: b.
	b reference: a.
	tx root: (SoilTestGraphRoot new nested: a).
	tx makeRoot: tx root nested.
	tx commit.
	soil close.
	soil := Soil path: self path.
	soil open.

	fakeSocket := RZReplicateVisitorFakeSocketDouble new.
	visitor := RZSoilReplicateVisitor new.
	visitor soil: soil.
	visitor socket: fakeSocket.
	visitor visit: soil.

	objectIds := self objectIdsSentTo: fakeSocket.
	self assert: objectIds size equals: objectIds asSet size
]

{ #category : 'tests' }
RZSoilReplicateVisitorTest >> testReplicatesBehaviorDescriptionsAlongsideRegularObjects [
	"visitMetaSegment: was a no-op (no super call) and visitPersistentClusterVersion:
	never called super either, so behaviorDescriptions (segment 0 objects a cluster
	references) were never discovered or replicated - only the regular object
	itself. Both now call super, restoring the normal SoilVisitor discovery path."
	| tx a visitor fakeSocket objectIds |
	tx := soil newTransaction.
	a := SoilTestNestedObject new label: #a.
	tx root: (SoilTestGraphRoot new nested: a).
	tx makeRoot: tx root nested.
	tx commit.
	soil close.
	soil := Soil path: self path.
	soil open.

	fakeSocket := RZReplicateVisitorFakeSocketDouble new.
	visitor := RZSoilReplicateVisitor new.
	visitor soil: soil.
	visitor socket: fakeSocket.
	visitor visit: soil.

	objectIds := self objectIdsSentTo: fakeSocket.
	self assert: (objectIds anySatisfy: [ :id | id segment = 0 ])
]
