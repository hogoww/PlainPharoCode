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
	|aPCBlock|
	aPCBlock := [ 3 ] asPlainCodeBC.
	self assert: aPCBlock class equals: PCBlockClosureAST.
	self assert: aPCBlock blockNode class equals: RBBlockNode.
	
	
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithArgumentsInBothBlock [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [:a| a ] asPlainCodeBC.
	anotherPCBlock := [:b| b ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlockClosureAST.
	self assert: res blockNode class equals: RBBlockNode.
	self assert: res blockNode statements size equals: 2.
	self assert: (res blockNode statements at: 1) name equals: 'a'.
	self assert: (res blockNode statements at: 2) name equals: 'b'.
	self assert: res blockNode arguments size equals: 2.
	self assert: (res blockNode arguments at: 1) name equals: 'a'.
	self assert: (res blockNode arguments at: 2) name equals: 'b'.
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithArgumentsInBothBlockWithSameName [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [:a| a ] asPlainCodeBC.
	anotherPCBlock := [:a| a ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlockClosureAST.
	self assert: res blockNode class equals: RBBlockNode.
	self assert: res blockNode statements size equals: 2.
	self assert: (res blockNode statements at: 1) name equals: 'a'.
	self assert: (res blockNode statements at: 2) name equals: 'a'.
	self assert: res blockNode arguments size equals: 1.
	self assert: (res blockNode arguments at: 1) name equals: 'a'.
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithArgumentsInOneBlock [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [:a| a ] asPlainCodeBC.
	anotherPCBlock := [ 4 ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlockClosureAST.
	self assert: res blockNode class equals: RBBlockNode.
	self assert: res blockNode statements size equals: 2.
	self assert: (res blockNode statements at: 1) name equals: 'a'.
	self assert: (res blockNode statements at: 2) value equals: 4.
	self assert: res blockNode arguments size equals: 1.
	self assert: (res blockNode arguments at: 1) name equals: 'a'.
]

{ #category : #tests }
PCBlockClosureASTTest >> testPCBlockClosureAdditionWithoutArguments [
	| aPCBlock anotherPCBlock res |
	"test concanating two simple blocks, without arguments."
	aPCBlock := [ 3 ] asPlainCodeBC.
	anotherPCBlock := [ 4 ] asPlainCodeBC.
	res := aPCBlock + anotherPCBlock.
	self assert: res class equals: PCBlockClosureAST.
	self assert: res blockNode class equals: RBBlockNode.
	self assert: res blockNode statements size equals: 2.
	self assert: (res blockNode statements at: 1) value equals: 3.
	self assert: (res blockNode statements at: 2) value equals: 4.
	self assert: res blockNode arguments size equals: 0
]
