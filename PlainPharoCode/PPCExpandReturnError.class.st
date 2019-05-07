"
I represent an Error.

I occur when someone's trying to expand a return in PlainCodeVisitor.

a:={ b c }
[ ^a ]
should be expanded as:
[
	^b
	^c
]
which is not possible.
"
Class {
	#name : #PPCExpandReturnError,
	#superclass : #Error,
	#category : #'PlainPharoCode-format'
}
