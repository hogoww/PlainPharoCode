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

{ #category : #visiting }
CodeGenerationVisitor >> getReplacementName: aString [
	(context lookupSymbol: aString)
	ifNotNil:[:value| 
		^value asString
		].
	^aString asString
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
CodeGenerationVisitor >> visitMessageNode: aMessageNode [
	(context lookupSymbol: aMessageNode receiver name) isArray
	ifTrue:[

		aMessageNode parent replaceNode: aMessageNode 
			withNodes: ((context lookupSymbol: (aMessageNode receiver name)) collect:[:anElement|
				RBMessageNode receiver: (RBVariableNode named: (self getReplacementName: anElement))
					selector: aMessageNode selector
					arguments: aMessageNode arguments
				]).
		].
	^aMessageNode
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aVariableNode [
	aVariableNode name: (self getReplacementName: aVariableNode name).
	^aVariableNode
]
