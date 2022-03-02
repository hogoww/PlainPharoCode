Extension { #name : #BlockClosure }

{ #category : #'*PlainPharoCode' }
BlockClosure >> + aBlock [
	^ self add: aBlock
]

{ #category : #'*PlainPharoCode' }
BlockClosure >> add: aBlock [
	^ self add: aBlock withArguments: {}
]

{ #category : #'*PlainPharoCode' }
BlockClosure >> add: aBlock withArguments: argumentsDictionnary [
	^ PCBlocks new
		add: self;
		add: aBlock withArguments: argumentsDictionnary;
		yourself
]

{ #category : #'*PlainPharoCode' }
BlockClosure >> asMethod: aSelector [
	^ self asMethod: aSelector withArguments: Dictionary new

]

{ #category : #'*PlainPharoCode' }
BlockClosure >> asMethod: aSelector withArguments: aDictionary [
	^ self asPlainCodeBC asMethod: aSelector withArguments: aDictionary
]

{ #category : #'*PlainPharoCode' }
BlockClosure >> asPCBlock [
	^ PCBlock new
		block: self;
		yourself
		
]

{ #category : #'*PlainPharoCode' }
BlockClosure >> asPlainCodeBC [
	^ PCBlocks new
		+= self ;
		yourself
]
