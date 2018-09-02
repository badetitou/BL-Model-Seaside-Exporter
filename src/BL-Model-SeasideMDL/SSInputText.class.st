Class {
	#name : #SSInputText,
	#superclass : #SSInput,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #testing }
SSInputText class >> annotation [
	<MSEClass: #SSInpuText super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #testing }
SSInputText class >> canHandle: anInvocation [
	^ 'BLTextBox' match: anInvocation invokedClassName
]
