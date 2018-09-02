Extension { #name : #BLPhase }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLPhase >> prepareAcceptFor: anExporter [
	| class |
	class := MDLApplication
		subclass: self name
		instanceVariableNames: ''
		classVariableNames: ''
		package: anExporter model name
]

{ #category : #'*BL-Model-Exporter-Seaside' }
BLPhase >> writeCodeWith: anExporter [
	"to override"

	| class |
	class := SmalltalkImage current classNamed: self name.
	class
		compile:
			'initialize
    super initialize.'.
	class class
		compile:
			'initialize
	self registerToDeployment: ''' , self name, ''''
]
