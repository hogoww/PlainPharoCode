Class {
	#name : #PlainCodeGenerationTest,
	#superclass : #TestCase,
	#instVars : [
		'anInstanceVariable'
	],
	#category : #PlainCodeGeneration
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
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> aTestExternargumentUnSet:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: anArg isNil.
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 1.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 1. 
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
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testInnerArgument [
	| initialBlock modifiedBlock |
	"Nothing in the outer environnement, nothing changes"
	initialBlock:=[:anArg | ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (self countID:'anArg' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'anArg' in: modifiedBlock) equals: 2. 
]

{ #category : #'tests-variables' }
PlainCodeGenerationTest >> testInnerTemporary [
	| initialBlock modifiedBlock|
	"The outerContext doesn't affect the inner conntext, so nothing should move."
	initialBlock:=[ |t| ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (self countID:'t' in: initialBlock sourceNode) equals: 2.
	self assert: (self countID:'t' in: modifiedBlock) equals: 2. 
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
]
