Extension { #name : #BLPage }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLPage >> writeCodeWith: anExporter [
	^ (self container isKindOf: BLPage)
		ifFalse: [ ^ '' ]
		ifTrue: [ | class |
			class := SmalltalkImage current classNamed: self container name.
			class
				compile:
					'renderContentOn: html
	' ,
						(self widgets flatCollect: [ :widget | (anExporter visit: widget) , String crlf , String tab ]) ]
]
