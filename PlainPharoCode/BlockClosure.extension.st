Extension { #name : #BlockClosure }

{ #category : #'*PlainPharoCode' }
BlockClosure >> asMethod: aSelector [
	^ self asMethod: aSelector withArgs: Dictionary new

]

{ #category : #'*PlainPharoCode' }
BlockClosure >> asMethod: aSelector withArgs: aDictionary [
	^ PPCPlainCodeVisitor new generateCode: aSelector withBody: self andArguments: aDictionary
]
