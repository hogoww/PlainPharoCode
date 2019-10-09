Class {
	#name : #PCBlock,
	#superclass : #Object,
	#instVars : [
		'block',
		'arguments'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #accessing }
PCBlock >> arguments [
	^ arguments
]

{ #category : #accessing }
PCBlock >> arguments: aDictionary [
	arguments := aDictionary
]

{ #category : #accessing }
PCBlock >> block [
	^ block
]

{ #category : #accessing }
PCBlock >> block: aBlock [
	block := aBlock
]

{ #category : #accessing }
PCBlock >> doReplacementsWith: aDictionary [
	| visitor resAST |
	visitor := PlainCodeVisitor new
		context: block outerContext;
		argumentDictionary:
			(aDictionary
				addAll: arguments;
				yourself);
		yourself.
	resAST := block sourceNode copy.
	resAST acceptVisitor: visitor.
	^resAST
]
