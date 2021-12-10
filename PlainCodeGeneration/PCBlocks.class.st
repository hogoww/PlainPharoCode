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
	self add: aBlock
]

{ #category : #concatenation }
PCBlocks >> add: aBlock [
	self add: aBlock withArguments: Dictionary new
]

{ #category : #concatenation }
PCBlocks >> add: aBlock withArguments: args [
	blocks addLast: 
		(aBlock asPCBlock  
			arguments: args)
]

{ #category : #concatenation }
PCBlocks >> addFirst: aBlock [
	self addFirst: aBlock withArguments: Dictionary new
]

{ #category : #concatenation }
PCBlocks >> addFirst: aBlock withArguments: args [
	blocks addFirst: 
		(aBlock asPCBlock 
			arguments: args)
]

{ #category : #ast }
PCBlocks >> asBlock [
	^ self asBlock: Dictionary new
]

{ #category : #ast }
PCBlocks >> asBlock: aDictionary [
	| arguments temporaries statements |
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
	| blockAST |
	blockAST := self asBlock: aDictionary.
	
	^ RBMethodNode  selector: aSelector arguments: blockAST arguments body: blockAST body
]

{ #category : #ast }
PCBlocks >> asPlainCodeBC [
	^ self
]

{ #category : #ast }
PCBlocks >> blocks [
	^ blocks
]

{ #category : #ast }
PCBlocks >> blocks: aCollection [
	^ blocks := aCollection
]

{ #category : #concatenation }
PCBlocks >> initialize [
	blocks := OrderedCollection new.
]
