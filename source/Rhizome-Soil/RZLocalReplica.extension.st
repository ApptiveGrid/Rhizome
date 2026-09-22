Extension { #name : 'RZLocalReplica' }

{ #category : '*Rhizome-Soil' }
RZLocalReplica >> doInitialSync: remote [
	RZSoilReplicateVisitor new 
		socket: (self replicaSet cluster network newWebSocketTo: remote address port: remote port);
		soil: soil;
		traverse
]

{ #category : '*Rhizome-Soil' }
RZLocalReplica >> newNotificationHandler [
	^ RZNotificationHandler new
		replica: self 
]
