"
Guards the package cut: Rhizome-Core is the model and must stay free of outside projects.

Everything that needs Soil, Zinc or murmur3 lives in Rhizome-Soil, Rhizome-Endpoints or Rhizome-Placement - as a whole class where the class is about that project, and as an extension method where only one method is. Without this test the cut would hold for exactly as long as nobody adds a reference in the wrong place, which is the fate of every cut that is only written down.
"
Class {
	#name : 'RZPackageCutTest',
	#superclass : 'TestCase',
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'accessing' }
RZPackageCutTest >> forbiddenPackagePrefixesForTheModel [
	^ #( 'Soil' 'Zinc' 'NCH' )
]

{ #category : 'running' }
RZPackageCutTest >> referencesFrom: aBehavior [
	"Answers a collection of name -> package for every class this behaviour names,
	skipping extension methods - those belong to the package they are tagged for."
	| refs |
	refs := OrderedCollection new.
	aBehavior methodDict valuesDo: [ :method |
		(([ method protocol name ] on: Error do: [ '' ]) beginsWith: '*') ifFalse: [
			method literals do: [ :literal |
				(literal isVariableBinding and: [ literal value isBehavior ]) ifTrue: [
					([ literal value package name ] on: Error do: [ nil ]) ifNotNil: [ :package |
						refs add: method selector -> package ] ] ] ] ].
	^ refs
]

{ #category : 'tests' }
RZPackageCutTest >> testTheModelNamesNoOtherRhizomePackage [
	"The model is underneath the others, so it may not reach up into them."
	| offenders |
	offenders := OrderedCollection new.
	((self class environment at: #PackageOrganizer) default packageNamed: 'Rhizome-Core') definedClasses do: [ :each |
		{ each . each class } do: [ :side |
			(self referencesFrom: side) do: [ :ref |
				((ref value beginsWith: 'Rhizome-') and: [ ref value ~= 'Rhizome-Core' ])
					ifTrue: [ offenders add: side name , '>>' , ref key , ' -> ' , ref value ] ] ] ].
	self assert: offenders asArray equals: #()
]

{ #category : 'tests' }
RZPackageCutTest >> testTheModelNamesNoOutsideProject [
	| offenders |
	offenders := OrderedCollection new.
	(self class environment at: #PackageOrganizer) default
		packageNamed: 'Rhizome-Core'
		ifAbsent: [ ^ self fail ].
	((self class environment at: #PackageOrganizer) default packageNamed: 'Rhizome-Core') definedClasses do: [ :each |
		{ each . each class } do: [ :side |
			(self referencesFrom: side) do: [ :ref |
				(self forbiddenPackagePrefixesForTheModel anySatisfy: [ :prefix | ref value beginsWith: prefix ])
					ifTrue: [ offenders add: side name , '>>' , ref key , ' -> ' , ref value ] ] ].
		each superclass ifNotNil: [ :superclass |
			([ superclass package name ] on: Error do: [ nil ]) ifNotNil: [ :package |
				(self forbiddenPackagePrefixesForTheModel anySatisfy: [ :prefix | package beginsWith: prefix ])
					ifTrue: [ offenders add: each name , ' inherits from ' , superclass name , ' -> ' , package ] ] ] ].
	self assert: offenders asArray equals: #()
]
