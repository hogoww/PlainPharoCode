Class {
	#name : #CodeGenerationVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'context',
		'initialMethod'
	],
	#category : #PlainCodeGeneration
}

{ #category : #accessing }
CodeGenerationVisitor >> context [ 
	^context
]

{ #category : #accessing }
CodeGenerationVisitor >> context: aContext [
	^context:=aContext
]

{ #category : #accessing }
CodeGenerationVisitor >> initialMethod [
	^initialMethod
]

{ #category : #accessing }
CodeGenerationVisitor >> initialMethod: aMethodNode [
	^initialMethod := aMethodNode
]

{ #category : #visiting }
CodeGenerationVisitor >> replaceNode: aNode [
	(context lookupSymbol: aNode name) 
	ifNotNil:[:value| 
		aNode name: value asString.
		].
]

{ #category : #visiting }
CodeGenerationVisitor >> visitMessageNode: aMessageNode [
	
	aMessageNode receiver name isArray
	ifTrue:[
		aMessageNode parent replaceNode: aMessageNode 
			withNodes: ((context lookupSymbol: (aMessageNode receiver name)) collect:[:anElement|
				RBMessageNode receiver: (RBVariableNode named:anElement)
					selector: aMessageNode selector 
					arguments: aMessageNode arguments
				]).
		]
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aVariableNode [
	self replaceNode: aVariableNode
]
