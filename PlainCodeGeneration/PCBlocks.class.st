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
	blocks add: aBlock
]

{ #category : #concatenation }
PCBlocks >> add: aBlock [
	self add: aBlock withArguments: Dictionary new
]

{ #category : #concatenation }
PCBlocks >> add: aBlock withArguments: args [
	blocks
		add:
			(PCBlock new
				block: aBlock;
				arguments: args;
				yourself)
]

{ #category : #ast }
PCBlocks >> asBlock [
	^ self asBlock: Dictionary new
]

{ #category : #ast }
PCBlocks >> asBlock: aDictionary [
	| arguments temporaries statements |
	asts := OrderedCollection new.
	asts := blocks collect: [ :aPcBlocks | aPcBlocks doReplacementsWith: aDictionary ].
	
	arguments := Set new.
	temporaries := Set new.
	statements := OrderedCollection new.
	asts do: [ :anAST | 
			arguments addAll: anAST arguments.
			temporaries addAll: anAST temporaries.
			statements addAll: anAST statements ].
		
	^ RBBlockNode
		arguments: arguments asOrderedCollection
		body: (RBSequenceNode temporaries: temporaries statements: statements)
]

{ #category : #ast }
PCBlocks >> asMethod: aSelector [
	^ self asMethod: aSelector withArguments: Dictionary new
]

{ #category : #ast }
PCBlocks >> asMethod: aSelector withArguments: aDictionary [
	^ self asBlock: aDictionary.
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
PCBlocks >> initialize [
	blocks := OrderedCollection new.
]
