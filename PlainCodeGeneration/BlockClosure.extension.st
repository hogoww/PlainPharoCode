Extension { #name : #BlockClosure }

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> + aBlock [
	^ self add: aBlock
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> add: aBlock [
	^ self add: aBlock withArguments: {}
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> add: aBlock withArguments: argumentsDictionnary [
	^ PCBlocks new
		add: self;
		add: aBlock withArguments: argumentsDictionnary;
		yourself
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asMethod: aSelector [
	^ self asMethod: aSelector withArguments: Dictionary new

]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asMethod: aSelector withArguments: aDictionary [
	^ self asPlainCodeBC asMethod: aSelector withArguments: aDictionary
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asPCBlock [
	^ PCBlock new
		block: self;
		yourself
		
]

{ #category : #'*PlainCodeGeneration' }
BlockClosure >> asPlainCodeBC [
	^ PCBlocks new
		+ self ;
		yourself
]
