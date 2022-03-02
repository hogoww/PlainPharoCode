Extension { #name : #RBMessageNode }

{ #category : #'*PlainPharoCode' }
RBMessageNode >> innerMostMessage [
	^self receiver isMessage 
		ifTrue:[
				self receiver innerMostMessage
			]
		ifFalse:[
				self
			]
		
]

{ #category : #'*PlainPharoCode' }
RBMessageNode >> isInnerMessage [
	^parent isSequence not & parent isReturn not
]

{ #category : #'*PlainPharoCode' }
RBMessageNode >> outerMostMessage [
	^self isInnerMessage
		ifTrue:[
			^parent outerMostMessage.
			]
		ifFalse:[
			^self
			]
		
]
