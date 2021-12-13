"
I'm a visitor for the RB AST, that just count the number of time I encounter a specific ID in a selector or a variable

I was created for the PlainCodeVisitorTest class, as a way to check that the replacement were effective.

- #anID: >> anID has to be set before the visit with the ID you want to count the occurences of in the AST
- #count >> Will contain the number of time I encountered anID

Try me in the playground!

visitor := RBIDCounterVisitor new anID: 'b' ; yourself.
[|b| ^b ] sourceNode acceptVisitor: visitor.
visitor count >>> 2.

 
    Instance Variables
	anID:		<Object> The ID we're searching in the AST.
	count:		<Object> anID occurences number.

"
Class {
	#name : #RBIDCounterVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'count',
		'anID'
	],
	#category : #'PlainCodeGeneration-Tests-support'
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
	count:=0
]

{ #category : #visiting }
RBIDCounterVisitor >> visitLiteralNode: aLiteralNode [
	super visitLiteralNode: aLiteralNode.
	aLiteralNode value = anID
	ifTrue:[count :=count + 1].
	
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
