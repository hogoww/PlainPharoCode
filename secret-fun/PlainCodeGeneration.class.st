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
	| debugerEnv visitor ast |
	visitor:=CodeGenerationVisitor new
		context:aBlock outerContext;
		yourself.
	ast:=aBlock sourceNode.
	ast acceptVisitor: visitor.
	self halt.
	^ast
]

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> aMethodThatGenerateCode: anArg [
	| a n c |
	a:=3.
	n:=5.
	c:='truc'.
	a:=6.
	^PlainCodeGeneration myMethodSelector:[|b|
		something.
		[ a.b. ].
		^a.
		].

]

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> doesNotUnderstand: aMessage [
	^RBMethodNode new
		selector: aMessage selector;
		body: (self aCodeGeneratorFromBlock:aMessage argument);
		yourself.
]
