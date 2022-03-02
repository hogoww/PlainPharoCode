Extension { #name : #RBValueNode }

{ #category : #'*PlainPharoCode' }
RBValueNode >> statement [
	^ self parent isSequence ifTrue:[ self ] ifFalse:[ self parent ]
]
