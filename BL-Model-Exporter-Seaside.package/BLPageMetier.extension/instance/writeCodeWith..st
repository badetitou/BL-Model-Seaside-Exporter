*BL-Model-Exporter-Seaside
writeCodeWith: anExporter
	^ (self container isKindOf: BLPhase)
		ifFalse: [ ^ '' ]
		ifTrue: [ | class |
			class := SmalltalkImage current classNamed: self container name.
			class
				compile:
					'renderContentOn: html
	'
						,
							(self widgets
								flatCollect: [ :widget | widget | widget exportCode , String crlf , String tab ]) ]