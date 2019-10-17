Extension { #name : #RBValueNode }

{ #category : #'*PlainCodeGeneration' }
RBValueNode >> statement [
	^ self parent isSequence ifTrue:[ self ] ifFalse:[ self parent ]
]
