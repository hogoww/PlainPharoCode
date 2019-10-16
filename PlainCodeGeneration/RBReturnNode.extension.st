Extension { #name : #RBReturnNode }

{ #category : #'*PlainCodeGeneration' }
RBReturnNode >> statement [
	^ self parent isSequence ifTrue:[ self ] ifFalse:[ self parent ]
]
