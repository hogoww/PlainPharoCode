Extension { #name : #String }

{ #category : #'*PlainCodeGeneration' }
String >> asMethodWithBody: aBlock [
	^ aBlock asMethod: self
]

{ #category : #'*PlainCodeGeneration' }
String >> asMethodWithBody: aBlock withArguments: aDictionary [
	^ aBlock asPlainCodeBC asMethod: self withArguments: aDictionary
]
