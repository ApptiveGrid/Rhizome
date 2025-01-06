Class {
	#name : 'RZDatabasesCall',
	#superclass : 'RZRestCall',
	#category : 'Rhizome-Core',
	#package : 'Rhizome-Core'
}

{ #category : 'accessing' }
RZDatabasesCall class >> pattern [ 
	^ #( 'databases' '*' )
]

{ #category : 'public' }
RZDatabasesCall >> get [ 
	| db |
	db := self virtualNode node
		databaseWithId: request url pathSegments second
		ifAbsent: [
			response :=  ZnResponse notFound: request url.
			^ self  ].
	response := ZnResponse ok: (ZnEntity 
		with: (STON toString: (RZSoilStatus new soil: db))
		type: (ZnMimeType main: 'text' sub: 'ston'))
]
