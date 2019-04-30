Class {
	#name : #CodeGenerationVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'context'
	],
	#category : #'secret-fun'
}

{ #category : #accessing }
CodeGenerationVisitor >> context [ 
	^context
]

{ #category : #accessing }
CodeGenerationVisitor >> context: aContext [
	^context:=aContext
]

{ #category : #visiting }
CodeGenerationVisitor >> replaceNode: aNode [
	(context lookupSymbol: aNode name) 
	ifNotNil:[:value| 
		aNode name: value asString.
		].
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aTemporaryNode [
	self replaceNode: aTemporaryNode
]
