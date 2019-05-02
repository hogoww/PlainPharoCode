Class {
	#name : #PlainCodeGenerationTest,
	#superclass : #TestCase,
	#instVars : [
		'context',
		'initialMethod'
	],
	#category : #PlainCodeGeneration
}

{ #category : #'as yet unclassified' }
PlainCodeGenerationTest >> aTestExternargument:anArg [
	| initialBlock modifiedBlock|
	initialBlock:=[ ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (initialBlock sourceNode allChildren count:[:aNode | aNode isVariable and:[ aNode name = 'anArg' ]]) equals: 1.
	self deny: (modifiedBlock allChildren anySatisfy: [:aNode | aNode isVariable and:[ aNode name = 'anArg' ]	]) equals: 1. 
	self assert: (modifiedBlock allChildren count: [:aNode | aNode isVariable and:[ aNode name = 'truc' ]	]) equals: 1. 
]

{ #category : #'as yet unclassified' }
PlainCodeGenerationTest >> testAnExternTemporarySet [
	| t initialBlock modifiedBlock|
	"The variable is instanciated with a value, it should therefore be replaced"
	t := 'truc'.
	initialBlock:=[ ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (initialBlock sourceNode allChildren count:[:aNode | aNode isVariable and:[ aNode name = 't' ]	]) equals: 1.
	self deny: (modifiedBlock allChildren anySatisfy: [:aNode | aNode isVariable and:[ aNode name = 't' ]	]). 
	self assert: (modifiedBlock allChildren count:[:aNode | aNode isVariable and:[ aNode name = 'truc' ]	]) equals: 1.
	
	
]

{ #category : #'as yet unclassified' }
PlainCodeGenerationTest >> testExternArgument [
	self aTestExternargument: 'truc'.
]

{ #category : #'as yet unclassified' }
PlainCodeGenerationTest >> testExternTemporaryUnset [
	| t initialBlock modifiedBlock|
	"There should be no replacement if the block's outer environment's variable equals nil"
	initialBlock:=[ ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (initialBlock sourceNode allChildren count: [:aNode | aNode isVariable and:[ aNode name = 't' ]	]) equals: 1.
	self assert: (modifiedBlock allChildren count: [:aNode | aNode isVariable and:[ aNode name = 't' ]	]) equals: 1. 
]

{ #category : #'as yet unclassified' }
PlainCodeGenerationTest >> testInnerTemporary [
	| initialBlock modifiedBlock|
	"The outerContext doesn't affect the inner conntext, so nothing should move."
	initialBlock:=[ |t| ^ t ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (initialBlock sourceNode allChildren count:[:aNode | aNode isVariable and:[ aNode name = 't' ]	]) equals: 2.
	self assert: (modifiedBlock allChildren count: [:aNode | aNode isVariable and:[ aNode name = 't' ]	]) equals: 2. 
]

{ #category : #'as yet unclassified' }
PlainCodeGenerationTest >> testInnerargument [
	| initialBlock modifiedBlock |
	"Nothing in the outer environnement, nothing changes"
	initialBlock:=[:anArg | ^ anArg ].
	modifiedBlock := PlainCodeGeneration new generateCode: #aMethod withBody: initialBlock.
	
	self assert: (initialBlock sourceNode allChildren count:[:aNode | aNode isVariable and:[ aNode name = 'anArg' ]]) equals: 2.
	self assert: (modifiedBlock allChildren count: [:aNode | aNode isVariable and:[ aNode name = 'anArg' ]]) equals: 2. 
]
