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
				package: 'PlainPharoCode';
				package: 'PlainPharoCode-Tests' with:[ spec requires:#('PlainPharoCode') ]
		].
]

{ #category : #accessing }
BaselineOfPlainPharoCode >> projectClass [
	^ MetacelloCypressBaselineProject
]
