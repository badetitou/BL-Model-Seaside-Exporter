Class {
	#name : #SSLabel,
	#superclass : #BLUIContainer,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #meta }
SSLabel class >> annotation [
	<MSEClass: #SSLabel super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #meta }
SSLabel class >> canHandle: anInvocation [
	^  'BLLabel|Label' matches: anInvocation invokedClassName
]
