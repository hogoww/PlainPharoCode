Class {
	#name : #PlainCodeGeneration,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'something'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #formatting }
PlainCodeGeneration >> aCodeGeneratorFromBlock:aBlock andArguments: aDictionary [
	| visitor ast |
	visitor:=CodeGenerationVisitor new
		context:aBlock outerContext;
		initialMethod: aBlock outerContext methodNode;
		argumentDictionary: aDictionary;
		yourself.
	ast:=aBlock sourceNode copy.
	ast acceptVisitor: visitor.
	^ast
]

{ #category : #formatting }
PlainCodeGeneration >> generateCode: aSelector withBody: aBlock [
	^ self
		generateCode: aSelector
		withBody: aBlock
		andArguments: Dictionary new
]

{ #category : #formatting }
PlainCodeGeneration >> generateCode: aSelector withBody: aBlock andArguments: aDictionnary [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock andArguments: aDictionnary.
	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body.

]
