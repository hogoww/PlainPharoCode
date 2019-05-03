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
	omm parent isReturn ifTrue:[self error:'Cannot duplicate a return'].
	
	res:=(context lookupSymbol: anArrayNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #visiting }
CodeGenerationVisitor >> visitMessageNode: aMessageNode [
	super visitMessageNode:aMessageNode.

	aMessageNode parent replaceNode: aMessageNode 
		withNode: (RBMessageNode receiver: aMessageNode receiver
			selector: (self getMessageSelector: (aMessageNode selector))
			arguments: ([| args |
				(self getMessageSelector: (aMessageNode selector)) = aMessageNode selector
				ifTrue:[aMessageNode arguments]
				ifFalse:[
					args:=aMessageNode arguments ifNotEmpty:[:argus| argus at:1] ifEmpty:[ OrderedCollection new].
					args size > 0 ifTrue:[ args statements] ifFalse:[args]]]  value)).
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aVariableNode [
	| resolvedVariable |
	resolvedVariable := context lookupSymbol: aVariableNode name.

	resolvedVariable isArray
		ifTrue: [ self variableExpandsInArrayNode: aVariableNode ]
		ifFalse:
			[ aVariableNode name: (self getReplacementName: aVariableNode name) ]
]
