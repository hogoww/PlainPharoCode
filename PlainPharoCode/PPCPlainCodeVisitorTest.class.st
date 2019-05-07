"
I represent the tests for PlainCodeVisitor

    Instance Variables
	anInstanceVariable:	<Object> whatever, it's to use for tests
	parser:		<RBParser> Applied on the result to check that it's a valid AST.
	plainCode:		<PlainCodeVisitor> plainCode instance to tests


"
Class {
	#name : #PPCPlainCodeVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'anInstanceVariable',
		'parser',
		'plainCode'
	],
	#category : #'PlainPharoCode-tests'
}

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> aTestExternargumentSet:anArg [
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
PPCPlainCodeVisitorTest >> aTestExternargumentUnSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: anArg isNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 1. 
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #running }
PPCPlainCodeVisitorTest >> countID: anID in: aNode [
	| visitor |
	visitor:= PPCRBIDCounterVisitor new 
		anID: anID;
		yourself.
	aNode acceptVisitor: visitor.
	^visitor count.
]

{ #category : #running }
PPCPlainCodeVisitorTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	parser := RBParser.
	plainCode := PPCPlainCodeVisitor new.
]

{ #category : #'tests-messages' }
PPCPlainCodeVisitorTest >> testBinarySelectors [
	| b initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	b := #- .
	initialBlock:=[ ^ 1 b:{ 1} ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: b isNotNil.
	self assert: (self countID:'b:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #- in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PPCPlainCodeVisitorTest >> testExpandInReturnOneUnary [
	| u initialBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	u := { #truc . #truc2 }.
	initialBlock:=[ ^ 1 u ].
	self should:[ plainCode generateCode: #aMethod withBody: initialBlock ] raise:PPCExpandReturnError.
]

{ #category : #'test-message-expand' }
PPCPlainCodeVisitorTest >> testExpandInReturnTwoUnary [
	| u initialBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	u := { #truc . #truc2 }.
	initialBlock:=[ ^ 1 u b ].
	self should:[ plainCode generateCode: #aMethod withBody: initialBlock ] raise:PPCExpandReturnError.
]

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> testExternArgumentSet [
	self aTestExternargumentSet: 'truc'.
]

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> testExternArgumentUnSet [
	self aTestExternargumentUnSet: nil.
]

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> testExternTemporarySet [
	| t initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'truc'.
	initialBlock:=[ ^ t ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNotNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'t' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
	
]

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> testExternTemporaryUnset [
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
PPCPlainCodeVisitorTest >> testInnerArgument [
	| initialBlock modifiedBlock |
	"Nothing in the outer environnement, nothing changes"
	initialBlock:=[:anArg | ^ anArg ].
	modifiedBlock := plainCode generateCode: #aMethod: withBody: initialBlock.
	
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'test-message-expand' }
PPCPlainCodeVisitorTest >> testInnerReplaceOneTernaryKeywordSelectorByTwoTernaryKeywordSelectors [
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
PPCPlainCodeVisitorTest >> testInnerTemporary [
	| initialBlock modifiedBlock|
	"The outerContext doesn't affect the inner conntext, so nothing should move."
	initialBlock:=[ |t| ^ t ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PPCPlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessage [
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
PPCPlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentReplaced [
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
PPCPlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentSameAsSelector [
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
PPCPlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentUnreplaced [
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
PPCPlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithSimpleArgument [
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
PPCPlainCodeVisitorTest >> testInnerUnarySelectorChangeWithUnaryOuterNode [
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
PPCPlainCodeVisitorTest >> testInstanceVariableSet [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block"
	
	anInstanceVariable := 'truc' .
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: anInstanceVariable isNotNil.
	self assert: (self countID:'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anInstanceVariable' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1.
	anInstanceVariable := nil.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> testInstanceVariableUnset [
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
PPCPlainCodeVisitorTest >> testKeywordMessageOneArg [
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
PPCPlainCodeVisitorTest >> testKeywordMessageTwoArgs [
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
PPCPlainCodeVisitorTest >> testKeywordMessageWithTempSet [
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

{ #category : #'tests-messages' }
PPCPlainCodeVisitorTest >> testOuterUnarySelectorChange [
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

{ #category : #'tests-variables' }
PPCPlainCodeVisitorTest >> testReplaceInnerArgumentWithSetValue [
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
PPCPlainCodeVisitorTest >> testReplaceInnerArgumentWithUnsetValue [
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
PPCPlainCodeVisitorTest >> testReplaceOneBinaryKeywordSelectorByTwoBinaryKeywordSelectors [
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
PPCPlainCodeVisitorTest >> testReplaceOneBinarySelectorByTwoBinarySelectors [
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
PPCPlainCodeVisitorTest >> testReplaceOneKeywordSelectorByTwoKeywordSelectors [
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
PPCPlainCodeVisitorTest >> testReplaceOneTernaryKeywordSelectorByTwoTernaryKeywordSelectors [
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
PPCPlainCodeVisitorTest >> testReplaceOneUnaryKeywordSelectorByTwoUnaryKeywordSelectors [
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
PPCPlainCodeVisitorTest >> testReplaceOneUnarySelectorByTwoUnarySelectors [
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

{ #category : #'tests-mixte' }
PPCPlainCodeVisitorTest >> testTempSetOnSelectorAndVariable [
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
PPCPlainCodeVisitorTest >> testTempUnsetOnSelectorAndVariable [
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
PPCPlainCodeVisitorTest >> testTryExpandOnAReturn [
	| initialBlock a |
	"Cannot expand an array on a return, it would give the following code:
	^druss
	^ŵaylander
	which is obviously not valid"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	^ a aMessage ].
	self should: [plainCode generateCode: #aMethod withBody: initialBlock ] raise:PPCExpandReturnError.	
]

{ #category : #'tests-messages' }
PPCPlainCodeVisitorTest >> testUnarySelector [
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
PPCPlainCodeVisitorTest >> testUnarySelectorWithEmptyArguments [
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

{ #category : #'test-variable-expand' }
PPCPlainCodeVisitorTest >> testVariableNodeIsArray [
	| initialBlock modifiedBlock a |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	a aMessage ].
	modifiedBlock := plainCode generateCode: #aMethod withBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID:'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: #aMessage in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]
