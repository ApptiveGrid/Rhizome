Class {
	#name : #RZDatabasesCall,
	#superclass : #RZRestCall,
	#category : #Rhizome
}

{ #category : #accessing }
RZDatabasesCall class >> pattern [ 
	^ #( 'databases' '*' )
]

{ #category : #public }
RZDatabasesCall >> get [ 
	| db |
	db := self endpoint
		databaseWithId: request url pathSegments second
		ifAbsent: [
			response :=  ZnResponse notFound: request url.
			^ self  ].
	response := ZnResponse ok: (ZnEntity 
		with: (STON toString: (RZSoilStatus new soil: db))
		type: (ZnMimeType main: 'text' sub: 'ston'))
]
