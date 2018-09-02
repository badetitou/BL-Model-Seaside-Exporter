Class {
	#name : #SSRadioButton,
	#superclass : #SSInput,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #testing }
SSRadioButton class >> annotation [
	<MSEClass: #SSRadioButton super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #testing }
SSRadioButton class >> canHandle: anInvocation [
	^ 'BLRadioButton' match: anInvocation invokedClassName
]

{ #category : #testing }
SSRadioButton class >> createWidgetFor: anInvocation [
	| widget |
	widget := super createWidgetFor: anInvocation.
	widget parameters
		at: #name
		put:
			(anInvocation parameters
				at: 1
				ifAbsent: [ self flag: #todo.
					'todo' ]).
	widget parameters
		at: #label
		put:
			(anInvocation parameters
				at: 2
				ifAbsent: [ self flag: #todo.
					'todo' ]).
	^ widget
]
