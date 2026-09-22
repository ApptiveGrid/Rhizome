"
Eine Uhr, die sich nicht von selbst bewegt. Der Test setzt sie und stellt sie vor; sonst verhaelt sie sich wie DateAndTime.

Sie ist die Testseite der Uhr-Naht: RZHostLeaseManager, RZInMemoryOwnershipStore und - ueber den Lease-Manager - RZRequestRouter lesen ihre Zeit aus einem clock-Objekt, das in Produktion die Klasse DateAndTime selbst ist. Jeder Zeitleser haelt seine eigene Uhr; genau das macht spaeter Uhrenversatz zwischen Hosts darstellbar.
"
Class {
	#name : 'RZManualClock',
	#superclass : 'Object',
	#instVars : [
		'now'
	],
	#category : 'Rhizome-Tests',
	#package : 'Rhizome-Tests'
}

{ #category : 'instance creation' }
RZManualClock class >> from: aDateAndTime [
	^ self new
		now: aDateAndTime;
		yourself
]

{ #category : 'accessing' }
RZManualClock >> advanceBy: aDuration [
	"Move the clock forward and answer the new time."
	now := now + aDuration.
	^ now
]

{ #category : 'initialization' }
RZManualClock >> initialize [
	super initialize.
	now := DateAndTime now
]

{ #category : 'accessing' }
RZManualClock >> now [
	^ now
]

{ #category : 'accessing' }
RZManualClock >> now: aDateAndTime [
	now := aDateAndTime
]
