Class {
	#name : #PlainCodeGeneration,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'something'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #formatting }
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

{ #category : #formatting }
PlainCodeGeneration >> generateCode: aSelector withBody: aBlock [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock.
	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body.

]
