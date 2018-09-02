Class {
	#name : #SSCheckBox,
	#superclass : #SSInput,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #testing }
SSCheckBox class >> annotation [
	<MSEClass: #SSCheckBox super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #testing }
SSCheckBox class >> canHandle: anInvocation [
	^ 'BLCheckBox' match: anInvocation invokedClassName
]
