Class {
	#name : #PlainCodeGeneration,
	#superclass : #Object,
	#instVars : [
		'something'
	],
	#category : #PlainCodeGeneration
}

{ #category : #'as yet unclassified' }
PlainCodeGeneration >> GenerateCode: aSelector withBody: aBlock [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock.
	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body.

]

{ #category : #'as yet unclassified' }
PlainCodeGeneration >> aCodeGeneratorFromBlock:aBlock [
	| visitor ast |
	visitor:=CodeGenerationVisitor new
		context:aBlock outerContext;
		initialMethod: aBlock outerContext methodNode;
		yourself.
	ast:=aBlock sourceNode.
	ast acceptVisitor: visitor.
	^ast
]

{ #category : #'as yet unclassified' }
PlainCodeGeneration >> aMethodThatGenerateCode: anArg [
	| a n c d b |
	a:=3.
	n:=5.
	c:='truc'.
	a:=6.
	d:= { #a . #n }.
	^PlainCodeGeneration new GenerateCode: #myMethodSelector:withArg: withBody:[:g :anotherAnotherArg |
		something.
		d ifTrue:[ anArg. b:=3. ].
		^a.
		].

]

{ #category : #formatting }
PlainCodeGeneration >> formatSelector: aSymbol withArguments: aCollection [ 
	^RBMethodNode new 
		selector: aSymbol;
		arguments: aCollection;
		asString
]
