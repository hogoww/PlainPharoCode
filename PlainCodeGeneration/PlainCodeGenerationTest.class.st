Class {
	#name : #PlainCodeGenerationTest,
	#superclass : #TestCase,
	#instVars : [
		'anInstanceVariable',
		'parser'
	],
	#category : #'PlainCodeGeneration-tests'
}

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> aTestExternargumentSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: anArg isNotNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1. 
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> aTestExternargumentUnSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: anArg isNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 1. 
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #running }
PlainCodeGenerationTest >> countID: anID in: aNode [
	| visitor |
	visitor:= RBIDCounterVisitor new 
		anID: anID;
		yourself.
	aNode acceptVisitor: visitor.
	^visitor count.
]

{ #category : #running }
PlainCodeGenerationTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."
	parser := RBParser.
]

{ #category : #'tests-messages' }
PlainCodeGenerationTest >> testBinarySelectors [
	| b initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	b := #- .
	initialBlock:=[ ^ 1 b:{ 1} ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: b isNotNil.
	self assert: (self countID:'b:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'b:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #- in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testExternArgumentSet [
	self aTestExternargumentSet: 'truc'.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testExternArgumentUnSet [
	self aTestExternargumentUnSet: nil.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testExternTemporarySet [
	| t initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'truc'.
	initialBlock:=[ ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNotNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'t' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
	
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testExternTemporaryUnset [
	| t initialBlock modifiedBlock|
	"There should be no replacement if the block's outer environment's variable equals nil"
	initialBlock:=[ ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'t' in: modifiedBlock) equals: 1. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testInnerArgument [
	| initialBlock modifiedBlock |
	"Nothing in the outer environnement, nothing changes"
	initialBlock:=[:anArg | ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod: withBody: initialBlock.
	
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testInnerTemporary [
	| initialBlock modifiedBlock|
	"The outerContext doesn't affect the inner conntext, so nothing should move."
	initialBlock:=[ |t| ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 2. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testInstanceVariableSet [
	| initialBlock modifiedBlock |
	"The instance variable is set, therefore should be replaced in the block"
	
	anInstanceVariable := 'truc' .
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: anInstanceVariable isNotNil.
	self assert: (self countID:'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anInstanceVariable' in: modifiedBlock) equals: 0. 
	self assert: (self countID:'truc' in: modifiedBlock) equals: 1.
	anInstanceVariable := nil.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testInstanceVariableUnset [
	| initialBlock modifiedBlock |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	anInstanceVariable := nil.
	
	initialBlock := [	^ anInstanceVariable ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: anInstanceVariable isNil.
	self assert: (self countID:'anInstanceVariable' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anInstanceVariable' in: modifiedBlock) equals: 1. 
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeGenerationTest >> testKeywordMessageOneArg [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:.
	initialBlock:=[ ^ 1 k:{ 1 } ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#aSelector: in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeGenerationTest >> testKeywordMessageTwoArgs [
	| k initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:withAnotherArg:.
	initialBlock:=[ ^ 1 k:{ 1 . 2 } ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: k isNotNil.
	self assert: (self countID:'k:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'k:' in: modifiedBlock) equals: 0.
	self assert: (self countID: #aSelector:withAnotherArg: in: modifiedBlock) equals: 1.
	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-mixte' }
PlainCodeGenerationTest >> testKeywordMessageWithTempSet [
	| k initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	k := #aSelector:.
	t := 'aValue'.
	initialBlock:=[ ^ t k:{ t } ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
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

{ #category : #'tests-mixte' }
PlainCodeGenerationTest >> testTempSetOnSelectorAndVariable [
	| initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'aValue'.
	initialBlock:=[ ^ t t].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNotNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 0.
	self assert: (self countID:#aValue in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-mixte' }
PlainCodeGenerationTest >> testTempUnsetOnSelectorAndVariable [
	| initialBlock modifiedBlock t |
	"The variable is instanciated with a value, it should therefore be replaced"
	t := nil.
	initialBlock:=[ ^ t t].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: t isNil.
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testTryExpandOnAReturn [
	| initialBlock modifiedBlock a |
	"Cannot expand an array on a return, it would give the following code:
	^druss
	^ŵaylander
	which is obviously not valid"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	^ a aMessage ].
	self should: [PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock ] raise:Error.	
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeGenerationTest >> testUnarySelector [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := #truc.
	initialBlock:=[ ^ 1 u ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID:'u' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'u' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-messages' }
PlainCodeGenerationTest >> testUnarySelectorWithEmptyArguments [
	| u initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	u := #truc.
	initialBlock:=[ ^ 1 u:{} ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: u isNotNil.
	self assert: (self countID:'u:' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'u:' in: modifiedBlock) equals: 0.
	self assert: (self countID:#truc in: modifiedBlock) equals: 1.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testVariableNodeIsArray [
	| initialBlock modifiedBlock a |
	"The instanceVariable is set to nil, so it shouldn't replace anything"
	
	a:={ 'druss' . 'waylander' }.
	
	initialBlock := [	a aMessage ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: a isArray.
	self assert: (self countID:'a' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'druss' in: modifiedBlock) equals: 1.
	self assert: (self countID:'waylander' in: modifiedBlock) equals: 1.
	self assert: (self countID: #aMessage in: modifiedBlock) equals: 2.
	self shouldnt: [parser parseMethod: modifiedBlock asString] raise:Error.
]
