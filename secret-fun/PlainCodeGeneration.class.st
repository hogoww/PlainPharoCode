Class {
	#name : #PlainCodeGeneration,
	#superclass : #Object,
	#classInstVars : [
		'something'
	],
	#category : #'secret-fun'
}

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> aCodeGeneratorFromBlock:aBlock [
	| debugerEnv |
	aBlock sourceNode.
	debugerEnv:=aBlock outerContext gtBytecodeDebuggerRetrieveContextValues asDictionary. 
	1halt.
	^1
]

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> aMethodThatGenerateCode: anArg [
	| a n c b |
	a:=3.
	n:=5.
	c:='truc'.
	PlainCodeGeneration myMethodSelector:[
		^b.
		].

]

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> doesNotUnderstand: aMessage [
	^RBMethodNode new
		selector: aMessage selector;
		body: (self aCodeGeneratorFromBlock:aMessage argument);
		yourself.
]
