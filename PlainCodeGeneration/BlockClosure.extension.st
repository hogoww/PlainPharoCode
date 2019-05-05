Extension { #name : #BlockClosure }

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asMethod: aSelector [
	^ self asMethod: aSelector withArgs: Dictionary new

]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asMethod: aSelector withArgs: aDictionary [
	^ PlainCodeVisitor new generateCode: aSelector withBody: self andArguments: aDictionary
]
