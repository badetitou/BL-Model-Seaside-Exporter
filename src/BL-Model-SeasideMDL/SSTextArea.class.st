Class {
	#name : #SSTextArea,
	#superclass : #SSInput,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #testing }
SSTextArea class >> annotation [
	<MSEClass: #SSTextArea super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #testing }
SSTextArea class >> canHandle: anInvocation [
		^ 'BLTextArea|TextArea' matches: anInvocation invokedClassName
]
