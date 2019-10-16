Class {
	#name : #PCBlock,
	#superclass : #Object,
	#instVars : [
		'block',
		'arguments',
		'variables'
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
	| tempNames receiver |
	variables := Dictionary new: aBlock outerContext numTemps.

	"get the temps values"
	tempNames := aBlock outerContext tempNames.
	tempNames do:[:aVarName|
		variables at: aVarName put: (aBlock outerContext lookupSymbol: aVarName ).
		].
	
	"get the instance variables values"
	receiver := aBlock outerContext receiver.
	receiver class allInstVarNames do:[:anIVName|
		variables at: anIVName put: (receiver instVarNamed: anIVName).
		].
	self halt.
	block := aBlock
]

{ #category : #accessing }
PCBlock >> doReplacementsWith: aDictionary [
	| visitor resAST |
	visitor := PlainCodeVisitor new
		context: variables ;
		argumentDictionary:
			(aDictionary
				addAll: arguments;
				yourself);
		yourself.
	resAST := block sourceNode copy.
	resAST acceptVisitor: visitor.
	^resAST
]

{ #category : #accessing }
PCBlock >> variables [
	^ variables
]

{ #category : #accessing }
PCBlock >> variables: aVariables [
	variables := aVariables
]
