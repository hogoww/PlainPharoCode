"
A PCBlockClosureASTTest is a test class for testing the behavior of PCBlockClosureAST
"
Class {
	#name : #PCBlockClosureASTTest,
	#superclass : #TestCase,
	#category : #'PlainCodeGeneration-Tests-tests'
}

{ #category : #tests }
PCBlockClosureASTTest >> testBlockClosureConversion [
	|aPCBlocks|
	aPCBlocks := [ 3 ] asPlainCodeBC.
	self assert: aPCBlocks class equals: PCBlocks.
	self assert: (aPCBlocks blocks at: 1) class equals: BlockClosure.
	
	
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithArgumentsInBothBlock [
	| aPCBlock anotherPCBlock res resAst |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [:a| a ] asPlainCodeBC.
	anotherPCBlock := [:b| b ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	resAst := (res blocks at:1) sourceNode.
	self assert: res class equals: PCBlocks.
	self assert: resAst class equals: RBBlockNode.
	self assert: resAst statements size equals: 2.
	self assert: (resAst statements at: 1) name equals: 'a'.
	self assert: (resAst statements at: 2) name equals: 'b'.
	self assert: resAst arguments size equals: 2.
	self assert: (resAst arguments at: 1) name equals: 'a'.
	self assert: (resAst arguments at: 2) name equals: 'b'.
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithArgumentsInBothBlockWithSameName [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [:a| a ] asPlainCodeBC.
	anotherPCBlock := [:a| a ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlocks.
	self assert: res blocks class equals: RBBlockNode.
	self assert: res blocks statements size equals: 2.
	self assert: (res blocks statements at: 1) name equals: 'a'.
	self assert: (res blocks statements at: 2) name equals: 'a'.
	self assert: res blocks arguments size equals: 1.
	self assert: (res blocks arguments at: 1) name equals: 'a'.
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithArgumentsInOneBlock [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [:a| a ] asPlainCodeBC.
	anotherPCBlock := [ 4 ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlocks.
	self assert: res blocks class equals: RBBlockNode.
	self assert: res blocks statements size equals: 2.
	self assert: (res blocks statements at: 1) name equals: 'a'.
	self assert: (res blocks statements at: 2) value equals: 4.
	self assert: res blocks arguments size equals: 1.
	self assert: (res blocks arguments at: 1) name equals: 'a'.
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithoutArguments [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [ 3 ] asPlainCodeBC.
	anotherPCBlock := [ 4 ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlocks.
	self assert: res blocks class equals: RBBlockNode.
	self assert: res blocks statements size equals: 2.
	self assert: (res blocks statements at: 1) value equals: 3.
	self assert: (res blocks statements at: 2) value equals: 4.
	self assert: res blocks arguments size equals: 0
]
