"
I represent a Visitor that allow to write pharo code which will be formated and returns an Abstract Syntax Tree.

I use the context in which a block is define to replace every variable that has a value with the value.

Public API and Key Messages

- generateCode: aSelector WithBody: aBlock >> generate the code of the method with the Selector, with aBlock as a body.
- generateCode: aSelector WithBody: aBlock andArguments: aCollection >> same thing, but will replace the block's arguments as well.

/!\
	We use the Stack's context.
	Block can't be defined in other blocks, the outeContext won't work otherwise. If you need some control flow, you HAVE to use #ifTrue:ifFalse: or a variation, because it's inlined by the compiler.
 
    Instance Variables
	context: <Context> OuterContext of the block's argument.
	argumentDictionary: <Dictionary> Dictionary containing the associations to replace the arguments of the block.

Plenty of small examples are available in PlainCodeVisitorTest
"
Class {
	#name : #PPCPlainCodeVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'context',
		'argumentDictionary'
	],
	#category : #'PlainPharoCode-format'
}

{ #category : #formatting }
PPCPlainCodeVisitor >> aCodeGeneratorFromBlock:aBlock andArguments: aDictionary [
	| visitor ast |
	visitor:=PPCPlainCodeVisitor new
		context:aBlock outerContext;
		argumentDictionary: aDictionary;
		yourself.
	ast:=aBlock sourceNode copy. "Working on a copy, to not modify the defined ast"
		
	ast acceptVisitor: visitor.
	^ast
]

{ #category : #accessing }
PPCPlainCodeVisitor >> argumentDictionary [
	^argumentDictionary
]

{ #category : #accessing }
PPCPlainCodeVisitor >> argumentDictionary: aDictionary [
	^argumentDictionary:= aDictionary
]

{ #category : #accessing }
PPCPlainCodeVisitor >> context [ 
	^context
]

{ #category : #accessing }
PPCPlainCodeVisitor >> context: aContext [
	^context:=aContext
]

{ #category : #formatting }
PPCPlainCodeVisitor >> generateCode: aSelector withBody: aBlock [
	^ self
		generateCode: aSelector
		withBody: aBlock
		andArguments: Dictionary new
]

{ #category : #formatting }
PPCPlainCodeVisitor >> generateCode: aSelector withBody: aBlock andArguments: aDictionnary [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock andArguments: aDictionnary.

	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body.
]

{ #category : #visiting }
PPCPlainCodeVisitor >> getMessageSelector: aString [
	| newName resolvedName |
	newName:=aString withoutSuffix: ':'.
	resolvedName := self getReplacementName: newName.
	^newName == resolvedName 
	ifTrue:[ aString ] ifFalse:[ resolvedName ]
]

{ #category : #visiting }
PPCPlainCodeVisitor >> getReplacementName: aString [
	(context lookupSymbol: aString)
		ifNotNil: [ :value | 
			value isArray
				ifTrue: [ ^ value ]
				ifFalse: [ ^ value asString ] ].
	^ aString
]

{ #category : #expand }
PPCPlainCodeVisitor >> message: aMessageNode expandInMultipleSelectors: aCollectionOfSelector [ 
	| newArguments replacementNodes oom |
	oom := aMessageNode outerMostMessageNode.
	
	oom parent isReturn ifTrue:[ PPCExpandReturnError signal ].
	
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

{ #category : #visiting }
PPCPlainCodeVisitor >> message: aMessageNode withNewSelector: newSelector [
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

{ #category : #expand }
PPCPlainCodeVisitor >> variableExpandsInArrayNode: anArrayNode [
	| omm res |
	(anArrayNode parent isMessage and:[ anArrayNode parent receiver = anArrayNode ])
	ifFalse:[^self].
	omm:=anArrayNode parent outerMostMessageNode.
	omm parent isReturn ifTrue:[^PPCExpandReturnError new signal].
	
	res:=(context lookupSymbol: anArrayNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #visiting }
PPCPlainCodeVisitor >> visitArgumentNode: anArgumentNode [
	| replacementName |
	"This will take care of the replacing the inner block's arguments
	[:b| b ] with the dictionary containing 'b'->a and a:=c will output the method with the body [:c| c ]"

	replacementName:=argumentDictionary at:anArgumentNode name ifAbsent:[
		^self visitVariableNode: anArgumentNode.
		].
	replacementName ifNotNil:[
		anArgumentNode name: replacementName.
	]
	
]

{ #category : #visiting }
PPCPlainCodeVisitor >> visitMessageNode: aMessageNode [
	| newSelector |
	"This will dispatch the message depending if we won't to replace it's selector by one or several messages"
	super visitMessageNode:aMessageNode.
	
	newSelector:=self getMessageSelector:aMessageNode selector.
	newSelector = aMessageNode selector
	ifTrue:[^self]. "Nothing to change here !"
	
	newSelector isArray
	ifFalse:[ self message: aMessageNode withNewSelector: newSelector.] 
	ifTrue:[ self message: aMessageNode expandInMultipleSelectors: newSelector].
]

{ #category : #visiting }
PPCPlainCodeVisitor >> visitVariableNode: aVariableNode [
	| resolvedVariable |
	super visitVariableNode: aVariableNode.
	
	resolvedVariable := context lookupSymbol: aVariableNode name.
	resolvedVariable isArray
		ifTrue: [ self variableExpandsInArrayNode: aVariableNode ]
		ifFalse: [ aVariableNode name: (self getReplacementName: aVariableNode name) ]
]