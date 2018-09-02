*BL-Model-Exporter-Seaside
prepareAcceptFor: anExporter
	| class |
	class := MDLApplication
		subclass: self name
		instanceVariableNames: ''
		classVariableNames: ''
		package: anExporter model name