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
	#name : #PlainCodeVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'context',
		'argumentDictionary'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #formatting }
PlainCodeVisitor >> aCodeGeneratorFromBlock:aBlock andArguments: aDictionary [
	| visitor pcbc |
	visitor:=PlainCodeVisitor new
		context:aBlock outerContext;
		argumentDictionary: aDictionary;
		yourself.
	pcbc:=aBlock asPlainCodeBC copy. "Working on a copy, to not modify the defined ast"
		
	pcbc blockNode acceptVisitor: visitor.
	^pcbc blockNode
]

{ #category : #accessing }
PlainCodeVisitor >> argumentDictionary [
	^argumentDictionary
]

{ #category : #accessing }
PlainCodeVisitor >> argumentDictionary: aDictionary [
	^argumentDictionary:= aDictionary
]

{ #category : #accessing }
PlainCodeVisitor >> context [ 
	^context
]

{ #category : #accessing }
PlainCodeVisitor >> context: aContext [
	^context:=aContext
]

{ #category : #formatting }
PlainCodeVisitor >> generateCode: aSelector withBody: aBlock [
	^ self
		generateCode: aSelector
		withBody: aBlock
		andArguments: Dictionary new
]

{ #category : #formatting }
PlainCodeVisitor >> generateCode: aSelector withBody: aBlock andArguments: aDictionnary [
	| updatedBlock |

	updatedBlock:=self aCodeGeneratorFromBlock:aBlock andArguments: aDictionnary.

	^RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body
]

{ #category : #visiting }
PlainCodeVisitor >> getMessageSelector: aString [
	| newName resolvedName |
	newName:=aString withoutSuffix: ':'.
	resolvedName := self getReplacementName: newName.
	^newName == resolvedName 
	ifTrue:[ aString ] ifFalse:[ resolvedName ]
]

{ #category : #visiting }
PlainCodeVisitor >> getReplacementName: aString [
	(context lookupSymbol: aString)
		ifNotNil: [ :value | 
			value isArray
				ifTrue: [ ^ value ]
				ifFalse: [ ^ value asString ] ].
	^ aString
]

{ #category : #expand }
PlainCodeVisitor >> message: aMessageNode expandInMultipleSelectors: aCollectionOfSelector [ 
	| newArguments replacementNodes oom |
	oom := aMessageNode outerMostMessage.
	
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

{ #category : #visiting }
PlainCodeVisitor >> message: aMessageNode withNewSelector: newSelector [
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
PlainCodeVisitor >> variableExpandsInMultipleVariables: aNode [
	| omm res |

	aNode parent isReturn
		ifTrue: [ ExpandReturnError signal ].
	(aNode parent isMessage and:[ aNode parent receiver = aNode ])
	ifFalse:[^self].

	omm:=aNode parent outerMostMessage.
	omm parent isReturn ifTrue:[^ExpandReturnError new signal].
	
	res:=(context lookupSymbol: aNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #expand }
PlainCodeVisitor >> variableExpandsInMultipleVariablesInMessage: aNode [
	| omm res |
	omm:=aNode parent outerMostMessage.
	omm parent isReturn ifTrue:[^ExpandReturnError new signal].
	
	res:=(context lookupSymbol: aNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #visiting }
PlainCodeVisitor >> visitArgumentNode: anArgumentNode [
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
PlainCodeVisitor >> visitAssignmentNode: anAssignmentNode [
	| resolvedName expandedNodes |
	anAssignmentNode value acceptVisitor:self.
	
	resolvedName:=context lookupSymbol: anAssignmentNode variable name.
	resolvedName isArray 
	ifFalse:[^self].
	expandedNodes:=resolvedName collect:[:aName| 
		|node|
		node:=anAssignmentNode copy.
		node variable name: aName.
		node.
		].
	anAssignmentNode parent replaceNode: anAssignmentNode withNodes: expandedNodes.
]

{ #category : #visiting }
PlainCodeVisitor >> visitGlobalNode: aGlobalNode [
	"The other kind of variable nodes have to be treated. This one doesn't"
]

{ #category : #visiting }
PlainCodeVisitor >> visitMessageNode: aMessageNode [
	| newSelector |
	"This will dispatch the message depending if we won't to replace it's selector by one or several messages"
	super visitMessageNode: aMessageNode.
	newSelector := self getMessageSelector: aMessageNode selector.
	newSelector = aMessageNode selector
		ifTrue: [ ^ self ].	"Nothing to change here !"
	newSelector isArray
		ifFalse: [ self message: aMessageNode withNewSelector: newSelector ]
		ifTrue: [ newSelector
				ifNotEmpty: [ self message: aMessageNode expandInMultipleSelectors: newSelector ] ]
]

{ #category : #visiting }
PlainCodeVisitor >> visitVariableNode: aVariableNode [
	| resolvedVariable |
	super visitVariableNode: aVariableNode.
	resolvedVariable := context lookupSymbol: aVariableNode name.
	resolvedVariable isNil
		ifTrue: [ ^ self ].
	resolvedVariable isArray
		ifTrue: [ resolvedVariable
				ifEmpty: [ ^ self ]
				ifNotEmpty: [ resolvedVariable size > 1
						ifTrue: [ ^ self variableExpandsInMultipleVariables: aVariableNode ]
						ifFalse: [ resolvedVariable := resolvedVariable anyOne ] ] ].
	aVariableNode name: resolvedVariable
]
