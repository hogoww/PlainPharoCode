Class {
	#name : #CodeGenerationVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'context',
		'initialMethod',
		'argumentDictionary'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #accessing }
CodeGenerationVisitor >> argumentDictionary [
	^argumentDictionary
]

{ #category : #accessing }
CodeGenerationVisitor >> argumentDictionary: aDictionary [
	^argumentDictionary:= aDictionary
]

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
		ifNotNil: [ :value | 
			value isArray
				ifTrue: [ ^ value ]
				ifFalse: [ ^ value asString ] ].
	^ aString
]

{ #category : #accessing }
CodeGenerationVisitor >> initialMethod [
	^initialMethod
]

{ #category : #accessing }
CodeGenerationVisitor >> initialMethod: aMethodNode [
	^initialMethod := aMethodNode
]

{ #category : #expand }
CodeGenerationVisitor >> message: aMessageNode expandInMultipleSelectors: aCollectionOfSelector [ 
	| newArguments replacementNodes oom |
	oom := aMessageNode outerMostMessageNode.
	
	oom parent isReturn ifTrue:[ ExpandReturnError signal ].
	
	newArguments:=aMessageNode arguments
		ifNotEmpty:[:args| args at:1 ] "we take the ArrayNode's collection directly"
		ifEmpty:[ OrderedCollection new ]. 
	newArguments size > 0 ifTrue:[ newArguments := newArguments statements].

	replacementNodes:=	aCollectionOfSelector collect:[:aSelector| 
			RBMessageNode receiver: aMessageNode receiver
				selector: aSelector
				arguments: newArguments
			].
	oom parent replaceNode:oom withNodes: replacementNodes.
]

{ #category : #'As yet unclassified' }
CodeGenerationVisitor >> message: aMessageNode withNewSelector: newSelector [
	| newArguments replacementNodes |
	newArguments:=aMessageNode arguments 
		ifNotEmpty:[:args| args at:1 ] "we take the ArrayNode's collection directly"
		ifEmpty:[ OrderedCollection new ]. 
	newArguments size > 0 ifTrue:[ newArguments := newArguments statements].

	replacementNodes:=	RBMessageNode receiver: aMessageNode receiver
				selector: newSelector
				arguments: newArguments.
	
	aMessageNode parent replaceNode:aMessageNode withNode: replacementNodes.
]

{ #category : #visiting }
CodeGenerationVisitor >> variableExpandsInArrayNode: anArrayNode [
	| omm res |
	(anArrayNode parent isMessage and:[ anArrayNode parent receiver = anArrayNode ])
	ifFalse:[^self].
	omm:=anArrayNode parent outerMostMessageNode.
	omm parent isReturn ifTrue:[^ExpandReturnError new signal].
	
	res:=(context lookupSymbol: anArrayNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #visiting }
CodeGenerationVisitor >> visitArgumentNode: anArgumentNode [
	| replacementName |
	replacementName:=argumentDictionary at:anArgumentNode name ifAbsent:[
		^self visitVariableNode: anArgumentNode.
		].
	replacementName ifNotNil:[
		anArgumentNode name: replacementName.
	]
	
]

{ #category : #visiting }
CodeGenerationVisitor >> visitMessageNode: aMessageNode [
	| newSelector |
	super visitMessageNode:aMessageNode.
	
	newSelector:=self getMessageSelector:aMessageNode selector.
	newSelector = aMessageNode selector
	ifTrue:[^self]. "Nothing to change here !"
	
	newSelector isArray
	ifFalse:[ self message: aMessageNode withNewSelector: newSelector.] 
	ifTrue:[ self message: aMessageNode expandInMultipleSelectors: newSelector].
]

{ #category : #visiting }
CodeGenerationVisitor >> visitVariableNode: aVariableNode [
	| resolvedVariable |
	super visitVariableNode: aVariableNode.
	
	resolvedVariable := context lookupSymbol: aVariableNode name.
	resolvedVariable isArray
		ifTrue: [ self variableExpandsInArrayNode: aVariableNode ]
		ifFalse: [ aVariableNode name: (self getReplacementName: aVariableNode name) ]
]
