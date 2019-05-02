Class {
	#name : #RBIDCounterVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'name',
		'count',
		'anID'
	],
	#category : #'PlainCodeGeneration-tests'
}

{ #category : #accessing }
RBIDCounterVisitor >> anID [
	^ anID
]

{ #category : #accessing }
RBIDCounterVisitor >> anID: aString [
	^ anID := aString
]

{ #category : #accessing }
RBIDCounterVisitor >> count [
	^ count
]

{ #category : #initialization }
RBIDCounterVisitor >> initialize [
	count:=0.
]

{ #category : #visiting }
RBIDCounterVisitor >> visitMessageNode: aMessageNode [
	aMessageNode selector = anID
		ifTrue: [ count := count + 1 ].
	^ super visitMessageNode: aMessageNode
]

{ #category : #visiting }
RBIDCounterVisitor >> visitVariableNode: aVariableNode [
	aVariableNode name = anID
		ifTrue: [ count := count + 1 ].
	^ super visitVariableNode: aVariableNode
]
