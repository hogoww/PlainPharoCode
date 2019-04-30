Class {
	#name : #PlainCodeGeneration,
	#superclass : #Object,
	#classInstVars : [
		'something'
	],
	#category : #'secret-fun'
}

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> GenerateCode: aSelector withBody: aBlock [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock.
	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body.

]

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> aCodeGeneratorFromBlock:aBlock [
	| visitor ast |
	visitor:=CodeGenerationVisitor new
		context:aBlock outerContext;
		yourself.
	ast:=aBlock sourceNode.
	ast acceptVisitor: visitor.
	^ast
]

{ #category : #'as yet unclassified' }
PlainCodeGeneration class >> aMethodThatGenerateCode: anArg [
	| a n c |
	a:=3.
	n:=5.
	c:='truc'.
	a:=6.
	^PlainCodeGeneration GenerateCode: #myMethodSelector:withArg: withBody:[:anotherArg :anotherAnotherArg | |b|
		something.
		n ifTrue:[ anArg. b:=3. ].
		^a.
		].

]

{ #category : #formatting }
PlainCodeGeneration class >> formatSelector: aSymbol withArguments: aCollection [ 
	^RBMethodNode new 
		selector: aSymbol;
		arguments: aCollection;
		asString
]
