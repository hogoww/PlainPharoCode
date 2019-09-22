"
I represent the tests for PlainCodeVisitor

    Instance Variables
	anInstanceVariable:	<Object> whatever, it's to use for tests
	parser:		<RBParser> Applied on the result to check that it's a valid AST.
	plainCode:		<PlainCodeVisitor> plainCode instance to tests


"
Class {
	#name : #PlainCodeVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'anInstanceVariable',
		'parser',
		'plainCode'
	],
	#category : #'PlainCodeGeneration-tests'
}

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> aTestExternargumentSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: anArg isNotNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1. 
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> aTestExternargumentUnSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: anArg isNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 1. 
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #running }
PlainCodeVisitorTest >> countID: anID in: aNode [
	| visitor |
	visitor:= RBIDCounterVisitor new 
		anID: anID;
		yourself.
	aNode acceptVisitor: visitor.
	^visitor count.
]

{ #category : #running }
PlainCodeVisitorTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	parser := RBParser.
	plainCode := PlainCodeVisitor new.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testBinarySelectors [
	| b initialBlock modifiedBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	b := #- .
	initialBlock:=[ ^ 1 b:{ 1 } ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	"Expected: [^1-1 ]".
	
	self assert: b isNotNil.
	self assert: (self countID:'b:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #- in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testExpandInReturnTwoUnary [
	| u initialBlock |
	"The variable is instanciated with an array, it should therefore be expanded as two messages. But given that you can't have two return statement in a row, hence, it'll throw an error"
	u := { #truc . #truc2 }.
	initialBlock:=[ ^ 1 u ].
	"Expected: [ 1 truc1. 1 truc2.] (if it didn't fail)"
	self should:[ plainCode generateCode: #aMethod withBody: initialBlock ] raise:ExpandReturnError.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternArgumentSet [
	self aTestExternargumentSet: 'truc'.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternArgumentUnSet [
	self aTestExternargumentUnSet: nil.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternTemporarySet [
	| t initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'truc'.
	initialBlock:=[ ^ t ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	"Expected: [ ^truc ]"
	
	self assert: t isNotNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'t' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
	
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternTemporaryUnset [
	| t initialBlock modifiedBlock|
	"There should be no replacement if the block's outer environment's variable equals nil"
	initialBlock:=[ ^ t ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'t' in: modifiedBlock) equals: 1. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInnerArgument [
	| initialBlock modifiedBlock |
	"Nothing in the outer environnement, nothing changes"
	initialBlock:=[:anArg | ^ anArg ].
	modifiedBlock := plainCode generateCode: #aMethod: withBody: initialBlock.
	
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testInnerReplaceOneTernaryKeywordSelectorByTwoTernaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc: . #truc2: }.
	initialBlock:=[ (1 k:{ 0 }) u ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc: in: modifiedBlock) equals: 1.
	self assert: (self countID:#truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInnerTemporary [
	| initialBlock modifiedBlock|
	"The outerContext doesn't affect the inner conntext, so nothing should move."
	initialBlock:=[ |t| ^ t ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessage [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: b ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID:'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID:'b' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentReplaced [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	b := 'druss'.
	initialBlock:=[ ^ 1 k a: {b} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.
	self assert: (self countID:'b' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID:'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID:'druss' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentSameAsSelector [
	| k initialBlock modifiedBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: {k} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 2.
	self assert: (self countID:'a:' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentUnreplaced [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: {b} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID:'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID:'b' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithSimpleArgument [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: b ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID:'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID:'b' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithUnaryOuterNode [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID:'a' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInstanceVariableSet [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block"
	
	anInstanceVariable := 'truc' .
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	[
		self assert: anInstanceVariable isNotNil.
		self assert: (self countID:'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
		self assert: (self countID:'anInstanceVariable' in: modifiedBlock) equals: 0. 
		self assert: (self countID:'truc' in: modifiedBlock) equals: 1.
		self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
	] ensure: [
		anInstanceVariable := nil.
	]
	
	
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInstanceVariableUnset [
	| initialBlock modifiedBlock |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anInstanceVariable := nil.
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: anInstanceVariable isNil.
	self assert: (self countID:'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anInstanceVariable' in: modifiedBlock) equals: 1. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testKeywordMessageOneArg [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:.
	initialBlock:=[ ^ 1 k:{ 1 } ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#aSelector: in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testKeywordMessageTwoArgs [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:withAnotherArg:.
	initialBlock:=[ ^ 1 k:{ 1 . 2 } ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector:withAnotherArg: in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-mixte' }
PlainCodeVisitorTest >> testKeywordMessageWithTempSet [
	| k initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:.
	t := 'aValue'.
	initialBlock:=[ ^ t k:{ t } ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#aSelector: in: modifiedBlock) equals: 1.
	
	self assert: t isNotNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'aValue' in: modifiedBlock) equals: 2.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
	
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testLeftSideAssignementVariableNodeExpand [
	| initialBlock modifiedBlock a |
	"Both value should be assigned with the right hand side"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	a:=#aMessage ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID:'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: #aMessage in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testOuterUnarySelectorChange [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 a k ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID:'a' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testReceiverVariableNodeExpand [
	| initialBlock modifiedBlock a |
	"The message should be send to both values of a individually"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	a aMessage ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a' in: modifiedBlock) equals: 0.
	self assert: (self countID:'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID:'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: #aMessage in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testReplaceInnerArgumentWithSetValue [
	| initialBlock modifiedBlock anotherArg argReplacement |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anotherArg:= 'something'.
	
	initialBlock := [:anArg|	^ anArg ].
	argReplacement := Dictionary new add: 'anArg' -> anotherArg ; yourself.
	modifiedBlock := plainCode generateCode: #aMethod: withBody: initialBlock andArguments: argReplacement.
	
	self assert: anotherArg isNotNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 0.
	self assert: (self countID:'something' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testReplaceInnerArgumentWithUnsetValue [
	| initialBlock modifiedBlock anotherArg argReplacement |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anotherArg := nil.
	
	initialBlock := [:anArg|	^ anArg ].
	argReplacement := Dictionary new add: 'anArg' -> anotherArg ; yourself.
	modifiedBlock := plainCode generateCode: #aMethod: withBody: initialBlock andArguments: argReplacement.
	
	self assert: anotherArg isNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 2.
	self assert: (self countID:'something' in: modifiedBlock) equals: 0. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneBinaryKeywordSelectorByTwoBinaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc:truc: . #truc2:truc2: }.
	initialBlock:=[ 1 k:{ 1 . 2 } ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc:truc: in: modifiedBlock) equals: 1.
	self assert: (self countID:#truc2:truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneBinarySelectorByTwoBinarySelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #- . #+ }.
	initialBlock:=[ 1 k:{1} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#+ in: modifiedBlock) equals: 1.
	self assert: (self countID:#- in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneKeywordSelectorByTwoKeywordSelectors [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := { #truc: . #truc2: }.
	initialBlock:=[ 1 u:{1} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID:'u:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'u:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc: in: modifiedBlock) equals: 1.
	self assert: (self countID:#truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneTernaryKeywordSelectorByTwoTernaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc:truc:truc: . #truc2:truc2:truc2: }.
	initialBlock:=[ 1 k:{ 0. 1 . 2 } ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc:truc:truc: in: modifiedBlock) equals: 1.
	self assert: (self countID:#truc2:truc2:truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneUnaryKeywordSelectorByTwoUnaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc: . #truc2: }.
	initialBlock:=[ 1 k:{1} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc: in: modifiedBlock) equals: 1.
	self assert: (self countID:#truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneUnarySelectorByTwoUnarySelectors [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := { #truc . #truc2 }.
	initialBlock:=[ 1 u ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID:'u' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'u' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc in: modifiedBlock) equals: 1.
	self assert: (self countID:#truc2 in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testRighSideAssignementVariableNodeExpand [
	| initialBlock modifiedBlock a b |
	"Both value should be assigned to the left hand side. I doubt it makes sense, but it should be possible"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	b:=a. ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'a' in: modifiedBlock) equals: 0.
	self assert: (self countID:'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID:'waylander' in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-mixte' }
PlainCodeVisitorTest >> testTempSetOnSelectorAndVariable [
	| initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'aValue'.
	initialBlock:=[ ^ t t].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNotNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 0.
	self assert: (self countID:#aValue in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-mixte' }
PlainCodeVisitorTest >> testTempUnsetOnSelectorAndVariable [
	| initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	t := nil.
	initialBlock:=[ ^ t t].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testTryExpandOnAReturn [
	| initialBlock a |
	"Cannot expand an array on a return, it would give the following code:
	^druss
	^ŵaylander
	which is obviously not valid"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	^ a aMessage ].
	self should: [plainCode generateCode: #aMethod withBody: initialBlock ] raise:ExpandReturnError.	
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testUnarySelector [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := #truc.
	initialBlock:=[ ^ 1 u ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID:'u' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'u' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testUnarySelectorWithEmptyArguments [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := #truc.
	initialBlock:=[ ^ 1 u:{} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID:'u:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'u:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]
