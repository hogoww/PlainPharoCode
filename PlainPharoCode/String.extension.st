Extension { #name : #String }

{ #category : #'*PlainPharoCode' }
String >> asMethodWithBody: aBlock [
	^ aBlock asMethod: self
]

{ #category : #'*PlainPharoCode' }
String >> asMethodWithBody: aBlock withArguments: aDictionary [
	^ aBlock asPlainCodeBC asMethod: self withArguments: aDictionary
]
