Class {
	#name : #PCBlocks,
	#superclass : #Object,
	#instVars : [
		'blocks'
	],
	#category : #'PlainCodeGeneration-format'
}

{ #category : #concatenation }
PCBlocks >> + aBlock [
	blocks add: aBlock copy
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
	blocks
		do: [ :aBlock | |ast|
			ast := aBlock sourceNode.
			arguments addAll: ast arguments.
			statements addAll: ast body statements.
			temporaries addAll: ast body temporaries ].
	^ RBBlockNode
		arguments: arguments asOrderedCollection
		body: (RBSequenceNode temporaries: temporaries statements: statements)
]

{ #category : #concatenation }
PCBlocks >> initialize [
	blocks := OrderedCollection new
]

{ #category : #ast }
PCBlocks >> replaceWithContextAndArguments: aDictionaryForArguments [
	|  visitor |
	blocks
		do: [ :aBlock | 
			visitor := PlainCodeVisitor new
				context: aBlock outerContext;
				argumentDictionary: aDictionaryForArguments;
				yourself.
			aBlock sourceNode acceptVisitor: visitor ].
]
