Extension { #name : #BlockClosure }

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> + aBlock [
	^ self asPlainCodeBC + aBlock
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asMethod: aSelector [
	^ self asMethod: aSelector withArgs: Dictionary new

]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asMethod: aSelector withArgs: aDictionary [
	^ PlainCodeVisitor new generateCode: aSelector withBody: self andArguments: aDictionary
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asPlainCodeBC [
	^PCBlocks new
		+ self copy;
		yourself
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> replaceWithContextAndArguments: aDictionaryForArguments [
	^ self asPlainCodeBC
		replaceWithContextAndArguments: aDictionaryForArguments
]
