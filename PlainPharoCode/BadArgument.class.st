Class {
	#name : #BadArgument,
	#superclass : #Error,
	#instVars : [
		'expected',
		'result'
	],
	#category : #'PlainPharoCode-error'
}

{ #category : #accessing }
BadArgument >> description [
	^ String streamContents:[:s|
		s << 'Got an instance of '
			print: expected;
			<< ' instead of an instance of: ';
			print: result
		]
]

{ #category : #accessing }
BadArgument >> expected [
	^ expected
]

{ #category : #accessing }
BadArgument >> expected: aClass [
	expected := aClass
]

{ #category : #accessing }
BadArgument >> result [
	^ result
]

{ #category : #accessing }
BadArgument >> result: aClass [
	result := aClass
]
