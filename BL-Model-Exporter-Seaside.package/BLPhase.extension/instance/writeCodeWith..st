*BL-Model-Exporter-Seaside
writeCodeWith: anExporter
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