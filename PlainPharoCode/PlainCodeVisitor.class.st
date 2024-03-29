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
		'explicitReplacement'
	],
	#category : #'PlainPharoCode-format'
}

{ #category : #formatting }
PlainCodeVisitor >> aCodeGeneratorFromBlock: aPlainCodeBlock andArguments: aDictionary [
	^ aPlainCodeBlock asPlainCodeBC asBlock: aDictionary
]

{ #category : #accessing }
PlainCodeVisitor >> context [
	<ignoreForCoverage>
	^ context
]

{ #category : #accessing }
PlainCodeVisitor >> context: aContext [
	<ignoreForCoverage>
	^ context := aContext
]

{ #category : #accessing }
PlainCodeVisitor >> explicitReplacements [
	<ignoreForCoverage>
	^ explicitReplacement
]

{ #category : #accessing }
PlainCodeVisitor >> explicitReplacements: aDictionary [
	<ignoreForCoverage>
	^ explicitReplacement := aDictionary
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

	updatedBlock := self aCodeGeneratorFromBlock: aBlock andArguments: aDictionnary.

	^ RBMethodNode
		selector: aSelector
		arguments: updatedBlock arguments
		body: updatedBlock body
]

{ #category : #visiting }
PlainCodeVisitor >> getMessageSelector: aString [
	| newName resolvedName |
	newName:=aString withoutSuffix: ':'.
	resolvedName := self getReplacementName: newName.
	^ newName == resolvedName 
		ifTrue:[ aString ] ifFalse:[ resolvedName ]
]

{ #category : #visiting }
PlainCodeVisitor >> getReplacementName: aString [	
	(self lookUpName: aString)
		ifNotNil: [ :value | 
			(value isCollection and:[ value isString not])
				ifTrue: [ ^ value ]
				ifFalse: [ ^ value asString ] ].
	^ aString
]

{ #category : #visiting }
PlainCodeVisitor >> lookUpName: aString [
	^ explicitReplacement at: aString ifAbsent:[ context at: aString ifAbsent: [ nil ] ]
]

{ #category : #expand }
PlainCodeVisitor >> message: aMessageNode expandInMultipleSelectors: aCollectionOfSelector [ 
	| newArguments replacementNodes oom |
	oom := aMessageNode outerMostMessage.

	oom parent isReturn ifTrue:[ ExpandReturnError signal ].
	
	newArguments := aMessageNode arguments
		ifNotEmpty:[:args| args at:1 ] "we take the ArrayNode's collection directly"
		ifEmpty:[ OrderedCollection new ]. 
	newArguments size > 0 ifTrue:[ newArguments := newArguments statements].

	replacementNodes := aCollectionOfSelector collect:[:aSelector| | newOom newMessageNode replacementNode |
			newOom := oom copy.
			replacementNode := RBMessageNode receiver: aMessageNode receiver
			selector: aSelector
			arguments: newArguments.
			
			oom = aMessageNode ifTrue:[ replacementNode ]
			ifFalse:[ 
					newMessageNode := newOom children detect: [:aNode| aNode = aMessageNode ].
					newOom replaceNode: newMessageNode withNode: replacementNode.
					].
			].
	oom parent replaceNode:oom withNodes: replacementNodes.
]

{ #category : #visiting }
PlainCodeVisitor >> message: aMessageNode withNewSelector: newSelector [
	| newArguments replacementNodes |
	newArguments := aMessageNode arguments 
		ifNotEmpty:[:args| | res |
			res := args at:1.
			(res isLiteralArray or: [ res isDynamicArray ] )
				ifTrue: [ res ]	"we take the ArrayNode's collection directly"
				ifFalse: [ BadArgument new expected: #(RBLiteralArrayNode RBArrayNode) ; result: res class ;  signal ]]
				"We expect an array node as argument, so we can replace the selector with an arbitrary number of arguments"
		ifEmpty:[ OrderedCollection new ]. 
	newArguments size > 0 ifTrue:[ newArguments := newArguments statements ].

	replacementNodes := RBMessageNode receiver: aMessageNode receiver
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
	omm parent isReturn ifTrue:[ ^ ExpandReturnError new signal ].
	
	res := (self lookUpName: aNode name) collect:[:aStatement| 
		omm copy innerMostMessage receiver: (RBVariableNode named:aStatement)
		].
	omm parent replaceNode: omm withNodes: res.
]

{ #category : #visiting }
PlainCodeVisitor >> variablesNodesVisit: aNode [
	"visits for IV/argument/temporary nodes"
	| resolvedVariable |
	resolvedVariable := self lookUpName: aNode name.
	resolvedVariable ifNil: [ ^ self ].
	resolvedVariable isArray
		ifTrue: [ resolvedVariable
				ifEmpty: [ |statement|
					statement := aNode statement.
					statement parent removeNode: statement.
					^ self ]
				ifNotEmpty: [ resolvedVariable size > 1
						ifTrue: [ ^ self variableExpandsInMultipleVariables: aNode ]
						ifFalse: [ resolvedVariable := resolvedVariable anyOne ] ] ].
	aNode name: resolvedVariable.
]

{ #category : #visiting }
PlainCodeVisitor >> visitArgumentNode: anArgumentNode [
	| replacementName |
	"This will take care of the replacing the inner block's arguments
	[:b| b ] with the dictionary containing 'b'->a and a:=c will output the method with the body [:c| c ]"
	replacementName:= (self lookUpName: anArgumentNode name) ifNil:[
		^self variablesNodesVisit: anArgumentNode.
		].
	replacementName ifNotNil:[
		anArgumentNode name: replacementName.
	]
	
]

{ #category : #visiting }
PlainCodeVisitor >> visitAssignmentNode: anAssignmentNode [
	| resolvedName expandedNodes |

	anAssignmentNode value acceptVisitor:self.

	resolvedName := self lookUpName: anAssignmentNode variable name.
	resolvedName ifNil:[ ^self ].
	
	resolvedName isArray ifFalse:[resolvedName := { resolvedName } ].
	expandedNodes := resolvedName collect:[:aName| 
		|node|
		node := anAssignmentNode copy.
		node variable name: aName.
		node.
		].
	
	expandedNodes size = 1
	ifTrue:[anAssignmentNode parent replaceNode: anAssignmentNode withNode: expandedNodes anyOne]"needed for nodes who don't know #replaceNode:withNodes (ReturnNode)"
	ifFalse:[anAssignmentNode parent replaceNode: anAssignmentNode withNodes: expandedNodes ]
]

{ #category : #visiting }
PlainCodeVisitor >> visitInstanceVariableNode: anInstanceVariable [
	self variablesNodesVisit: anInstanceVariable
]

{ #category : #visiting }
PlainCodeVisitor >> visitLiteralArrayNode: aLiteralArrayNode [
	| contents replacements |
	contents := OrderedCollection new.
	aLiteralArrayNode children 
		do: [ :each | 
			replacements := self getReplacementName: each value.
			(replacements isCollection and: [ replacements isString not ]) 
				ifTrue: [ contents addAll: replacements ]
				ifFalse: [ contents add: replacements ] ].
	aLiteralArrayNode contents: (contents collect: [ :aString | RBLiteralNode value: aString ])
"	aLiteralNode value isSymbol ifFalse: [ ^ self ]."
"	aLiteralNode value: (self getReplacementName: aLiteralNode value) asSymbol start: 0 stop: -1"
	"Bogus values, since we're parsing them back before use."
]

{ #category : #visiting }
PlainCodeVisitor >> visitLiteralValueNode: aLiteralNode [
	aLiteralNode value isSymbol ifFalse: [ ^ self ].
	aLiteralNode value: (self getReplacementName: aLiteralNode value) asSymbol start: 0 stop: -1
	"Bogus values, since we're parsing them back before use."
]

{ #category : #visiting }
PlainCodeVisitor >> visitLocalVariableNode: aNode [
	"Every node is redirected to  variable nodes. only is a problem for the argument.
	This fixes the tool for p9, and the variable refactor"
	aNode isArgumentVariable ifTrue: [ ^ self visitArgumentNode: aNode ].
	^ self visitTemporaryNode: aNode 
]

{ #category : #visiting }
PlainCodeVisitor >> visitMessageNode: aMessageNode [
	| newSelector |
	"This will dispatch the message depending if we won't to replace it's selector by one or several messages"
	super visitMessageNode: aMessageNode.
	
	newSelector := self getMessageSelector: aMessageNode selector.
	
	(newSelector isCollection and:[ newSelector isString not])
		ifFalse: [ 
			newSelector = aMessageNode selector
				ifTrue: [ ^ self ].	"Nothing to change here !"
			self message: aMessageNode withNewSelector: newSelector ]
		ifTrue: [ 
			newSelector ifEmpty:[ |statement|
				statement:= aMessageNode statement.
				statement parent removeNode:statement.
				^self ].
			
			newSelector size = 1
				ifTrue:[
					newSelector first = aMessageNode selector
					ifTrue: [ ^ self ].	"Nothing to change here !"
					self message: aMessageNode withNewSelector: newSelector first.
					^self
				].
			"Else, needs to be expanded"
			newSelector
				ifNotEmpty: [ self message: aMessageNode expandInMultipleSelectors: newSelector ] ]
]

{ #category : #visiting }
PlainCodeVisitor >> visitSequenceNode: aMethodNode [
	super visitSequenceNode: aMethodNode 
]

{ #category : #visiting }
PlainCodeVisitor >> visitTemporaryNode: aTemporaryNode [
	self variablesNodesVisit: aTemporaryNode
]
