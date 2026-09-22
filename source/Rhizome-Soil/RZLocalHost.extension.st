Extension { #name : 'RZLocalHost' }

{ #category : '*Rhizome-Soil' }
RZLocalHost >> createDatabaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifTrue: [ Error signal: 'database already exists' ].
	^ (Soil path: path)
		initializeFilesystem;
		yourself
]

{ #category : '*Rhizome-Soil' }
RZLocalHost >> databaseWithId: aString [ 
	| path |
	path := self databaseLocator pathForId: aString.
	path exists ifFalse: [ Error signal: 'database not found at ', path printString ].
	^ Soil path: path
]

{ #category : '*Rhizome-Soil' }
RZLocalHost >> databaseWithId: aString ifAbsent: aBlock [ 
	| path |
	path := self databaseLocator pathForId: aString.
	^ path exists 
		ifTrue: [ Soil path: path ]
		ifFalse: aBlock 
]
