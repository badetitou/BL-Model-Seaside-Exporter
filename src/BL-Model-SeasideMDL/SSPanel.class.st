Class {
	#name : #SSPanel,
	#superclass : #BLUIContainer,
	#category : 'BL-Model-SeasideMDL-Widget'
}

{ #category : #meta }
SSPanel class >> annotation [
	<MSEClass: #SSPanel super: #BLWidget>
	<package: #BLModelSeaside>
	^ self
]

{ #category : #meta }
SSPanel class >> canHandle: anInvocation [
	^ '*Panel' match: anInvocation invokedClassName
]

{ #category : #'as yet unclassified' }
SSPanel >> exportCode [
	^ 'html div with: [ 
		', (self widgets flatCollect: #exportCode),'
		].'
]
