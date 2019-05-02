Class {
	#name : #PlainCodeGeneration,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'something'
	],
	#category : #PlainCodeGeneration
}

{ #category : #'as yet unclassified' }
PlainCodeGeneration >> aCodeGeneratorFromBlock:aBlock [ 
	| visitor ast |
	visitor:=CodeGenerationVisitor new
		context:aBlock outerContext;
		initialMethod: aBlock outerContext methodNode;
		yourself.
	ast:=aBlock sourceNode copy.
	ast acceptVisitor: visitor.
	^ast
]

{ #category : #'as yet unclassified' }
PlainCodeGeneration >> aMethodThatGenerateCode: anArg [
	| a n c d b u n2 |
	a:=3.
	c:='truc'.
	a:=6.
	d:= { #a . #c }.
	u:= #aMessage.
	b:= #-.
	n:= #aMessageWith:.
	n2:= #aMessage:with:.
	^PlainCodeGeneration new generateCode: #myMethodSelector:withArg: withBody:[:g :anotherAnotherArg |
		something n2:{ n . c }.
		a aMes1 b:{ c }.
		a n:{ a }.
		c u.
		a aMes.
		c ifTrue:[ anArg. b:=3. ].
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

{ #category : #'as yet unclassified' }
PlainCodeGeneration >> generateCode: aSelector withBody: aBlock [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock.
	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body.

]
