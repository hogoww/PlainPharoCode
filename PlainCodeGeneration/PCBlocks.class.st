Class {
	#name : #PCBlocks,
	#superclass : #Object,
	#instVars : [
		'blocks',
		'asts'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #concatenation }
PCBlocks >> + aBlock [
	blocks add: aBlock copy
]

{ #category : #ast }
PCBlocks >> asBlock [
	self replaceWithContextAndArguments: Dictionary new.
	^ self concatenationResult 
]

{ #category : #ast }
PCBlocks >> asMethod: aSelector [
	^ self asMethod: aSelector withArgs: Dictionary new
]

{ #category : #ast }
PCBlocks >> asMethod: aSelector withArgs: aDictionary [
	^ PlainCodeVisitor new generateCode: aSelector withBody: self andArguments: aDictionary
]

{ #category : #ast }
PCBlocks >> asPlainCodeBC [
	^ self
]

{ #category : #ast }
PCBlocks >> blocks [
	^blocks
]

{ #category : #ast }
PCBlocks >> blocks: aCollection [
	^ blocks := aCollection
]

{ #category : #concatenation }
PCBlocks >> concatenationResult [
	| arguments statements temporaries |
	arguments := Set new.
	statements := OrderedCollection new.
	temporaries := Set new.
	asts
		do: [ :anAst |
			arguments addAll: anAst arguments.
			statements addAll: anAst body statements.
			temporaries addAll: anAst body temporaries ].
	^ RBBlockNode
		arguments: arguments asOrderedCollection
		body: (RBSequenceNode temporaries: temporaries  statements: statements )
]

{ #category : #concatenation }
PCBlocks >> initialize [
	blocks := OrderedCollection new.
	asts := OrderedCollection new.
]

{ #category : #ast }
PCBlocks >> replaceWithContextAndArguments: aDictionaryForArguments [
	| visitor resAst |
	blocks
		do: [ :aBlock | 
			visitor := PlainCodeVisitor new
				context: aBlock outerContext;
				argumentDictionary: aDictionaryForArguments;
				yourself.
			resAst := aBlock sourceNode copy.
			resAst acceptVisitor: visitor.
			asts add: resAst ]
]
