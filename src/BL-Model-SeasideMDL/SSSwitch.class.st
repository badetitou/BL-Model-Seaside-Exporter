Class {
	#name : #SSSwitch,
	#superclass : #SSInput,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #testing }
SSSwitch class >> annotation [
	<MSEClass: #SSSwitch super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #testing }
SSSwitch class >> canHandle: anInvocation [
	^ 'BLToggleButton' matches: anInvocation invokedClassName
]
