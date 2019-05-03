Extension { #name : #RBMessageNode }

{ #category : #'*PlainCodeGeneration' }
RBMessageNode >> innerMostMessage [
	^self receiver isMessage 
		ifTrue:[
				self receiver innerMostMessage
			]
		ifFalse:[
				self
			]
		
]

{ #category : #'*PlainCodeGeneration' }
RBMessageNode >> isInnerMessage [
	^parent isSequence not & parent isReturn not
]

{ #category : #'*PlainCodeGeneration' }
RBMessageNode >> outerMostMessageNode [
	^self isInnerMessage
		ifTrue:[
			^parent outerMostMessageNode.
			]
		ifFalse:[
			^self
			]
		
]
