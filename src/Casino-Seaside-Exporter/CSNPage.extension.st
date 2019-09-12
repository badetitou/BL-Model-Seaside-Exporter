Extension { #name : #CSNPage }

{ #category : #'*Casino-Seaside-Exporter' }
CSNPage >> writeCodeWith: anExporter [
	^ (self container isKindOf: CSNPage)
		ifFalse: [ ^ '' ]
		ifTrue: [ | class |
			class := SmalltalkImage current classNamed: self container name.
			class
				compile:
					'renderContentOn: html
	' ,
						(self widgets flatCollect: [ :widget | (anExporter visit: widget) , String crlf , String tab ]) ]
]
