Class {
	#name : #RZDatabasesCall,
	#superclass : #RZTuberRestCall,
	#category : #Rhizome
}

{ #category : #accessing }
RZDatabasesCall class >> pattern [ 
	^ #( 'databases' '*' )
]

{ #category : #public }
RZDatabasesCall >> get [ 
	| db |
	db := self rhizome 
		databaseWithId: request url pathSegments second
		ifAbsent: [
			response :=  ZnResponse notFound: request url.
			^ self  ].
	response := ZnResponse ok: db printString
]
