Extension { #name : #String }

{ #category : #'*PlainCodeGeneration' }
String >> asMethodWithBody: aBlock [
	^ aBlock asMethod: self
]

{ #category : #'*PlainCodeGeneration' }
String >> asMethodWithBody: aBlock withArgs: aDictionary [
	^ aBlock asMethod: self withArgs: aDictionary
]
