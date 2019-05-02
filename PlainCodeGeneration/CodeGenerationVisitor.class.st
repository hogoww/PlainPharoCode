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
	| isMethodSelector newName |
	isMethodSelector := aString endsWith: ':'.
	newName:=aString withoutSuffix: ':'.
	(context lookupSymbol: newName)
	ifNotNil:[:value| 
		^value asString
		].
	^isMethodSelector ifTrue:[ newName , ':'] ifFalse:[ newName].
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
	super visitMessageNode:aMessageNode.
	aMessageNode receiver isMessage | aMessageNode receiver isLiteral not ifFalse:[
		(context lookupSymbol: aMessageNode receiver name) isArray
		ifTrue:[
			aMessageNode parent replaceNode: aMessageNode 
				withNodes: ((context lookupSymbol: (aMessageNode receiver name)) collect:[:anElement|
					RBMessageNode receiver: (RBVariableNode named: (self getReplacementName: anElement))
						selector: (self getReplacementName: aMessageNode selector)
						arguments: aMessageNode arguments
					]).
				].
	].

	aMessageNode parent replaceNode: aMessageNode 
		withNode: (RBMessageNode receiver: aMessageNode receiver
			selector: (self getReplacementName: (aMessageNode selector))
			arguments: ([| args |
				(self getReplacementName: (aMessageNode selector)) = aMessageNode selector
				ifTrue:[aMessageNode arguments]
				ifFalse:[
					args:=aMessageNode arguments ifNotEmpty:[:argus| argus at:1] ifEmpty:[ OrderedCollection new].
					args size > 0 ifTrue:[ args statements do:[:aStatement| aStatement acceptVisitor: self ]] ifFalse:[args]]]  value)).
]

{ #category : #visiting }
CodeGenerationVisitor >> visitMethodNode: aMethodNode [
	"allow to return the method node we just modified, while using the walk defined in super"
	super visitMethodNode:aMethodNode.
	^aMethodNode
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aVariableNode [
	aVariableNode name: (self getReplacementName: aVariableNode name).
	^aVariableNode
]
