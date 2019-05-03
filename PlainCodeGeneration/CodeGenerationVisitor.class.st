Class {
	#name : #CodeGenerationVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'context',
		'initialMethod'
	],
	#category : #'PlainCodeGeneration-format'
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
CodeGenerationVisitor >> getMessageSelector: aString [
	| newName resolvedName |
	newName:=aString withoutSuffix: ':'.
	resolvedName := self getReplacementName: newName.
	^newName == resolvedName 
	ifTrue:[ aString ] ifFalse:[ resolvedName ]
]

{ #category : #visiting }
CodeGenerationVisitor >> getReplacementName: aString [
	(context lookupSymbol: aString)
	ifNotNil:[:value| 
		^value asString
		].
	^ aString.
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
CodeGenerationVisitor >> variableExpandsInArrayNode: anArrayNode [
	| omm res |

	omm:=anArrayNode parent isMessage ifTrue:[ anArrayNode parent outerMostMessageNode ].
	omm parent isReturn ifTrue:[^ExpandReturnError new signal].
	
	res:=(context lookupSymbol: anArrayNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #visiting }
CodeGenerationVisitor >> visitMessageNode: aMessageNode [
	| replacementNodes  newSelector newArguments |
	super visitMessageNode:aMessageNode.
	
	newSelector:=self getMessageSelector:aMessageNode selector.
	newSelector = aMessageNode selector
	ifTrue:[^self]. "Nothing to change here !"
	
	newArguments:=aMessageNode arguments 
		ifNotEmpty:[:args| args at:1 ] "we take the ArrayNode's collection directly"
		ifEmpty:[ OrderedCollection new ]. 
	newArguments size > 0 ifTrue:[ newArguments := newArguments statements].

	replacementNodes:=RBMessageNode receiver: aMessageNode receiver
			selector: newSelector
			arguments: newArguments.
	
	
	aMessageNode parent replaceNode:aMessageNode withNode: replacementNodes.
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aVariableNode [
	| resolvedVariable |
	super visitVariableNode: aVariableNode.
	
	resolvedVariable := context lookupSymbol: aVariableNode name.

	resolvedVariable isArray
		ifTrue: [ self variableExpandsInArrayNode: aVariableNode ]
		ifFalse:
			[ aVariableNode name: (self getReplacementName: aVariableNode name) ]
]
