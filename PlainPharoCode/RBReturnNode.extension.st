Extension { #name : #RBReturnNode }

{ #category : #'*PlainPharoCode' }
RBReturnNode >> statement [
	^ self parent isSequence ifTrue:[ self ] ifFalse:[ self parent ]
]
