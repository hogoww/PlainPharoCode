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
PCBlock >> + anotherBlock [
	^ self add: anotherBlock
]

{ #category : #accessing }
PCBlock >> add: anotherBlock [
	^ self add: anotherBlock withArguments: {}
]

{ #category : #accessing }
PCBlock >> add: aBlock withArguments: argumentsDictionnary [
	^ PCBlocks new
		add: self;
		add: aBlock withArguments: argumentsDictionnary;
		yourself
]

{ #category : #accessing }
PCBlock >> arguments [
	^ arguments
]

{ #category : #accessing }
PCBlock >> arguments: aDictionary [
	arguments := aDictionary
]

{ #category : #accessing }
PCBlock >> asPCBlock [
	^ self
]

{ #category : #accessing }
PCBlock >> asPlainCodeBC [
	^ PCBlocks new
		add: self;
		yourself
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
	tempNames do: [ :aVarName | 
		variables
			at: aVarName
			put: (aBlock outerContext readVariableNamed: aVarName) ].

	"get the instance variables values"
	receiver := aBlock outerContext receiver.
	receiver class allInstVarNames do: [ :anIVName | 
		variables at: anIVName put: (receiver instVarNamed: anIVName) ].

	block := aBlock
]

{ #category : #accessing }
PCBlock >> doReplacementsWith: aDictionary [
	| visitor resAST |
	visitor := PlainCodeVisitor new
		explicitReplacements:
			(aDictionary asDictionary
				addAll: arguments;
				yourself);
		context: variables;
		yourself.
	resAST := block sourceNode copy.
	resAST acceptVisitor: visitor.
	^resAST
]

{ #category : #accessing }
PCBlock >> initialize [
	arguments := {}
]

{ #category : #accessing }
PCBlock >> variables [
	^ variables
]

{ #category : #accessing }
PCBlock >> variables: aCollectionOfBindings [
	variables := aCollectionOfBindings
]
