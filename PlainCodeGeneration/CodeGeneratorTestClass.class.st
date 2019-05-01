Class {
	#name : #CodeGeneratorTestClass,
	#superclass : #Object,
	#instVars : [
		'context',
		'initialMethod'
	],
	#category : #PlainCodeGeneration
}

{ #category : #'as yet unclassified' }
CodeGeneratorTestClass >> aMethodThatGenerateCodeWithAnExternArgument: anArg [
	^ PlainCodeGeneration new
		generateCode: #aMethod
		withBody: [ ^ anArg ]
]

{ #category : #'as yet unclassified' }
CodeGeneratorTestClass >> aMethodThatGenerateCodeWithAnExternTemporary [
	| t |
	t := 3.
	^ PlainCodeGeneration new generateCode: #aMethod withBody: [ ^ t ]
]

{ #category : #'as yet unclassified' }
CodeGeneratorTestClass >> aMethodThatGenerateCodeWithAnExternTemporarySet [
	| t |
	t := 3.
	^ PlainCodeGeneration new generateCode: #aMethod withBody: [ ^ t ]
]

{ #category : #'as yet unclassified' }
CodeGeneratorTestClass >> aMethodThatGenerateCodeWithAnExternTemporaryUnset [
	| t |
	^ PlainCodeGeneration new generateCode: #aMethod withBody: [ ^ t ]
]

{ #category : #'as yet unclassified' }
CodeGeneratorTestClass >> aMethodThatGenerateCodeWithAnInternArgument [
	^ PlainCodeGeneration new
		generateCode: #aMethod
		withBody: [ :b |
			^ b ]
]

{ #category : #'as yet unclassified' }
CodeGeneratorTestClass >> aMethodThatGenerateCodeWithAnInternTemporary [
	^ PlainCodeGeneration new
		generateCode: #aMethod
		withBody: [ | t |
			t:=3.
			^ t ]
]
