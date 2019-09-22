Class {
	#name : #PCBlockClosureAST,
	#superclass : #Object,
	#instVars : [
		'blockNode'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #concatenation }
PCBlockClosureAST >> + aBlockClosureAST [
	blockNode body addNodes: aBlockClosureAST blockNode body statements.
	blockNode arguments addAll: aBlockClosureAST blockNode arguments.
	blockNode arguments: blockNode arguments asSet asOrderedCollection
]

{ #category : #ast }
PCBlockClosureAST >> asMethod: aSelector [
	^ self asMethod: aSelector withArgs: Dictionary new
]

{ #category : #ast }
PCBlockClosureAST >> asMethod: aSelector withArgs: aDictionary [
	^ PlainCodeVisitor new generateCode: aSelector withBody: self andArguments: aDictionary
]

{ #category : #ast }
PCBlockClosureAST >> asPlainCodeBC [
	^ self
]

{ #category : #accessors }
PCBlockClosureAST >> blockNode [
	^ blockNode
]

{ #category : #accessors }
PCBlockClosureAST >> blockNode: aBlockNode [
	^ blockNode := aBlockNode
]

{ #category : #ast }
PCBlockClosureAST >> sourceNode [
	^ blockNode
]
