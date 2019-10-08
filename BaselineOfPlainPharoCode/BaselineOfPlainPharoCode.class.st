Class {
	#name : #BaselineOfPlainPharoCode,
	#superclass : #BaselineOf,
	#category : #BaselineOfPlainPharoCode
}

{ #category : #baselines }
BaselineOfPlainPharoCode >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec
				package: 'PlainCodeGeneration';
				package: 'PlainCodeGeneration-Tests' with:[ spec requires:#('PlainCodeGeneration') ]
		].
]

{ #category : #accessing }
BaselineOfPlainPharoCode >> projectClass [
	^ MetacelloCypressBaselineProject
]
