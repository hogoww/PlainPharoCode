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
		'parser'
	],
	#category : #'PlainCodeGeneration-Tests-tests'
}

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> aTestExternargumentSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
		
	self assert: anArg isNotNil.
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 0. 
	self assert: (self countID: 'truc' in: modifiedBlock) equals: 1. 
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> aTestExternargumentUnSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: anArg isNil.
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 1. 
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #running }
PlainCodeVisitorTest >> countID: anID in: aNode [
	| visitor |
	visitor := RBIDCounterVisitor new 
		anID: anID;
		yourself.
	aNode acceptVisitor: visitor.
	^ visitor count
]

{ #category : #running }
PlainCodeVisitorTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	parser := RBParser.
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testArgumentInStringShouldNotBeReplaced [
	| initialBlock modifiedBlock anotherArg argReplacement |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anotherArg := 'something'.
	
	initialBlock := [ :anArg | 'anArg' ].
	argReplacement := Dictionary new add: 'anArg' -> anotherArg ; yourself.
	modifiedBlock := #aMethod: asMethodWithBody: initialBlock withArguments: argReplacement.
	
	self assert: anotherArg isNotNil.
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 2.
	"Only the argument node should be replaced"
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'something' in: modifiedBlock) equals: 1.
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testArgumentInSymbolShouldBeReplaced [
	| initialBlock modifiedBlock anotherArg argReplacement |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anotherArg := 'something'.
	
	initialBlock := [ :anArg | #anArg ].
	argReplacement := Dictionary new add: 'anArg' -> anotherArg ; yourself.
	modifiedBlock := #aMethod: asMethodWithBody: initialBlock withArguments: argReplacement.
	
	self assert: anotherArg isNotNil.
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 0.
	self assert: (self countID: 'something' in: modifiedBlock) equals: 2. 

	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testBinaryKeywordsArgumentBad [
	| b initialBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	b := #- .
	initialBlock:=[ ^ 1 b: 1 ].
	self should: [ initialBlock asMethod: #aMethod ] raise: BadArgument
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testBinaryKeywordsArgumentGood [
	| b initialBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	b := #- .
	initialBlock:=[ ^ 1 b: { 1 } ].
	self shouldnt: [ initialBlock asMethod: #aMethod ] raise: BadArgument
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testBinarySelectors [
	| b initialBlock modifiedBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	b := #- .
	initialBlock:=[ ^ 1 b:{ 1 } ].
	modifiedBlock := initialBlock asMethod: #aMethod
	"Expected: [^1-1 ]".
	
	self assert: b isNotNil.
	self assert: (self countID: 'b:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #- in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testExpandInReturnTwoUnary [
	| u initialBlock |
	"The variable is instanciated with an array, it should therefore be expanded as two messages. But given that you can't have two return statement in a row, hence, it'll throw an error"
	u := { #truc . #truc2 }.
	initialBlock := [ ^ 1 u ].

	self should:[ #aMethod asMethodWithBody: initialBlock ] raise: ExpandReturnError
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternArgumentSet [
	self aTestExternargumentSet: 'truc'
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternArgumentUnSet [
	self aTestExternargumentUnSet: nil
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternTemporarySet [
	| t initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'truc'.
	initialBlock:=[ ^ t ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	"Expected: [ ^truc ]"
	
	self assert: t isNotNil.
	self assert: (self countID: 't' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 't' in: modifiedBlock) equals: 0. 
	self assert: (self countID: 'truc' in: modifiedBlock) equals: 1.
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testExternTemporaryUnset [
	| t initialBlock modifiedBlock|
	"There should be no replacement if the block's outer environment's variable equals nil"
	initialBlock:=[ ^ t ].
	modifiedBlock := initialBlock asMethod: #aMethod.
	
	self assert: t isNil.
	self assert: (self countID: 't' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 't' in: modifiedBlock) equals: 1. 
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInnerArgument [
	| initialBlock modifiedBlock |
	"Nothing in the outer environnement, nothing changes"
	initialBlock:=[:anArg | ^ anArg ].
	modifiedBlock := #aMethod: asMethodWithBody: initialBlock.
	
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testInnerReplaceOneTernaryKeywordSelectorByTwoTernaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc: . #truc2: }.
	initialBlock:=[ (1 k:{ 0 }) u ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc: in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInnerTemporary [
	| initialBlock modifiedBlock|
	"The outerContext doesn't affect the inner conntext, so nothing should move."
	initialBlock:=[ |t| ^ t ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: (self countID: 't' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 't' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessage [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: b ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'b' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentReplaced [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	b := 'druss'.
	initialBlock:=[ ^ 1 k a: {b} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.
	self assert: (self countID: 'b' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'druss' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentSameAsSelector [
	| k initialBlock modifiedBlock |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: {k} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 2.
	self assert: (self countID: 'a:' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithArrayArgumentUnreplaced [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: {b} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'b' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithOuterKeywordMessageWithSimpleArgument [
	| k initialBlock modifiedBlock b |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a: b ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a:' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'b' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorChangeWithUnaryOuterNode [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 k a ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testInnerUnarySelectorExpandInsideABinarySelector [
	| k initialBlock modifiedBlock  |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #(druss #waylander).
	initialBlock:=[ 1 + self a k ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.
	self assert: (self countID: #+ in: modifiedBlock) equals: 2.
	self assert: (self countID: #druss in: modifiedBlock) equals: 1.
	self assert: (self countID: #waylander in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 2.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInstanceVariableSet [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block"
	
	anInstanceVariable := 'truc' .
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	[
		self assert: anInstanceVariable isNotNil.
		self assert: (self countID: 'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
		self assert: (self countID: 'anInstanceVariable' in: modifiedBlock) equals: 0. 
		self assert: (self countID: 'truc' in: modifiedBlock) equals: 1.
		self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
	] ensure: [
		anInstanceVariable := nil.
	]
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInstanceVariableSetWithEmptyArrayForMessage [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block
	Since the array is empty, it probably should remove the message alltogether"
	
	anInstanceVariable := {} .
	
	initialBlock := [	^ 1 anInstanceVariable ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	[
		self assert: anInstanceVariable isNotNil.
		self assert: (self countID: 'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
		self assert: modifiedBlock statements size equals: 0.
		self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
	] ensure: [
		anInstanceVariable := nil.
	]
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testInstanceVariableSetWithEmptyArrayForVariable [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block.
	The array is empty, hence the statement should be removed"
	
	anInstanceVariable := {}.
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	[
		self assert: anInstanceVariable isNotNil.
		self assert: (self countID: 'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
		self assert: modifiedBlock statements size equals: 0.
		self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
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
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: anInstanceVariable isNil.
	self assert: (self countID: 'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'anInstanceVariable' in: modifiedBlock) equals: 1. 
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testKeywordMessageOneArg [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:.
	initialBlock:=[ ^ 1 k:{ 1 } ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector: in: modifiedBlock) equals: 1.
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testKeywordMessageTwoArgs [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:withAnotherArg:.
	initialBlock:=[ ^ 1 k:{ 1 . 2 } ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector:withAnotherArg: in: modifiedBlock) equals: 1.
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-mixte' }
PlainCodeVisitorTest >> testKeywordMessageWithTempSet [
	| k initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:.
	t := 'aValue'.
	initialBlock:=[ ^ t k:{ t } ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector: in: modifiedBlock) equals: 1.
	
	self assert: t isNotNil.
	self assert: (self countID: 't' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 't' in: modifiedBlock) equals: 0. 
	self assert: (self countID: 'aValue' in: modifiedBlock) equals: 2.
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testLeftSideAssignementVariableNodeExpand [
	| initialBlock modifiedBlock a |
	"Both value should be assigned with the right hand side"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	a:=#aMessage ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: #aMessage in: modifiedBlock) equals: 2.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testMiddleUnarySelectorChangeWithUnaryOuterNode [
	| k initialBlock modifiedBlockAST|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 b k a ].
	modifiedBlockAST := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlockAST) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlockAST) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlockAST) equals: 1.
	self assert: (self countID: 'b' in: modifiedBlockAST) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlockAST asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testOuterUnarySelectorChange [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector.
	initialBlock:=[ ^ 1 a k ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.	
	self assert: (self countID: #aSelector in: modifiedBlock) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testOverridingVariableShouldBeTakenIntoAccount [
	| initialBlock modifiedBlock aTempVar explicitReplacement |
	aTempVar := 'something'.
	
	initialBlock := [ aTempVar ].
	explicitReplacement := {'aTempVar' -> nil} asDictionary ; yourself.
	modifiedBlock := #aMethod asMethodWithBody: initialBlock withArguments: explicitReplacement.
	
	self assert: aTempVar isNotNil.
	self assert: (self countID: 'aTempVar' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'aTempVar' in: modifiedBlock) equals: 1.
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testReceiverVariableNodeExpand [
	| initialBlock modifiedBlock a |
	"The message should be send to both values of a individually"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	a aMessage ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 0.
	self assert: (self countID: 'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: #aMessage in: modifiedBlock) equals: 2.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testReplaceBothAssignementSidesInReturn [
	| initialBlock a modifiedBlock b |
	"Cannot expand an array on a return, it would give the following code:
	^druss
	^ŵaylander
	which is obviously not valid"
	a := {'waylander'}.
	b := { 'druss' }.
	initialBlock := [ ^ a := b ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: a size equals: 1.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'b' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 0. 
	self assert: (self countID: 'b' in: modifiedBlock) equals: 0. 
	self assert: (self countID: 'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'druss' in: modifiedBlock) equals: 1.

	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testReplaceInnerArgumentWithSetValue [
	| initialBlock modifiedBlock anotherArg argReplacement |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anotherArg:= 'something'.
	
	initialBlock := [:anArg|	^ anArg ].
	argReplacement := Dictionary new add: 'anArg' -> anotherArg ; yourself.
	modifiedBlock := #aMethod: asMethodWithBody: initialBlock withArguments: argReplacement.
	
	self assert: anotherArg isNotNil.
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 0.
	self assert: (self countID: 'something' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testReplaceInnerArgumentWithUnsetValue [
	| initialBlock modifiedBlock anotherArg argReplacement |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anotherArg := nil.
	
	initialBlock := [:anArg|	^ anArg ].
	argReplacement := Dictionary new add: 'anArg' -> anotherArg ; yourself.
	modifiedBlock := #aMethod: asMethodWithBody: initialBlock withArguments: argReplacement.
	
	self assert: anotherArg isNil.
	self assert: (self countID: 'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 'anArg' in: modifiedBlock) equals: 2.
	self assert: (self countID: 'something' in: modifiedBlock) equals: 0. 
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceInsideOfLiteralArray [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc . #truc2 }.
	initialBlock:=[ #( k ) ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2 in: modifiedBlock) equals: 1.
	self assert: modifiedBlock statements first isLiteralArray.

	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneBinaryKeywordSelectorByTwoBinaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc:truc: . #truc2:truc2: }.
	initialBlock:=[ 1 k:{ 1 . 2 } ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc:truc: in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2:truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneBinarySelectorByTwoBinarySelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #- . #+ }.
	initialBlock:=[ 1 k:{1} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #+ in: modifiedBlock) equals: 1.
	self assert: (self countID: #- in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneKeywordSelectorByTwoKeywordSelectors [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := { #truc: . #truc2: }.
	initialBlock:=[ 1 u:{1} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID: 'u:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'u:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc: in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneTernaryKeywordSelectorByTwoTernaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc:truc:truc: . #truc2:truc2:truc2: }.
	initialBlock:=[ 1 k:{ 0. 1 . 2 } ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc:truc:truc: in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2:truc2:truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneUnaryKeywordSelectorByTwoUnaryKeywordSelectors [
	| initialBlock modifiedBlock k |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := { #truc: . #truc2: }.
	initialBlock:=[ 1 k:{1} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID: 'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc: in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2: in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-message-expand' }
PlainCodeVisitorTest >> testReplaceOneUnarySelectorByTwoUnarySelectors [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := { #truc . #truc2 }.
	initialBlock:=[ 1 u ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID: 'u' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'u' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc in: modifiedBlock) equals: 1.
	self assert: (self countID: #truc2 in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testRighSideAssignementVariableNodeExpand [
	| initialBlock modifiedBlock a b |
	"Both value should be assigned to the left hand side. I doubt it makes sense, but it should be possible"
	<expectedFailure>
	
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	b:=a. ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 0.
	self assert: (self countID: 'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID: 'waylander' in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-variables' }
PlainCodeVisitorTest >> testSetWithEmptyArrayForComplexMessage [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block
	Since the array is empty, it probably should remove the message alltogether"
	
	anInstanceVariable := {} .
	
	initialBlock := [	^ 1 + 1 anInstanceVariable ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	[
		self assert: anInstanceVariable isNotNil.
		self assert: (self countID: 'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
		self assert: modifiedBlock statements size equals: 0.
		self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
	] ensure: [
		anInstanceVariable := nil.
	]
]

{ #category : #'tests-mixte' }
PlainCodeVisitorTest >> testTempSetOnSelectorAndVariable [
	| initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'aValue'.
	initialBlock:=[ ^ t t].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: t isNotNil.
	self assert: (self countID: 't' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 't' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aValue in: modifiedBlock) equals: 2.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-mixte' }
PlainCodeVisitorTest >> testTempUnsetOnSelectorAndVariable [
	| initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	t := nil.
	initialBlock:=[ ^ t t].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: t isNil.
	self assert: (self countID: 't' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID: 't' in: modifiedBlock) equals: 2.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testTryExpandOnAReturn [
	| initialBlock a |
	"Cannot expand an array on a return, it would give the following code:
	^druss
	^ŵaylander
	which is obviously not valid"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	^ a ].
	self should: [ #aMethod asMethodWithBody: initialBlock ] raise: ExpandReturnError
]

{ #category : #'test-variable-expand' }
PlainCodeVisitorTest >> testTryExpandOneVariableOnAReturn [
	| initialBlock a modifiedBlock |
	"Cannot expand an array on a return, it would give the following code:
	^druss
	^ŵaylander
	which is obviously not valid"
	a := {'waylander'}.
	initialBlock := [ ^ a ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: a size equals: 1.
	self assert: (self countID: 'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'a' in: modifiedBlock) equals: 0. 
	self assert: (self countID: 'waylander' in: modifiedBlock) equals: 1.
	
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testUnarySelector [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := #truc.
	initialBlock:=[ ^ 1 u ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID: 'u' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'u' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]

{ #category : #'tests-messages' }
PlainCodeVisitorTest >> testUnarySelectorWithEmptyArguments [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := #truc.
	initialBlock:=[ ^ 1 u:{} ].
	modifiedBlock := #aMethod asMethodWithBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID: 'u:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID: 'u:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #truc in: modifiedBlock) equals: 1.
	self shouldnt: [ parser parseMethod: modifiedBlock asString ] raise: Error
]
