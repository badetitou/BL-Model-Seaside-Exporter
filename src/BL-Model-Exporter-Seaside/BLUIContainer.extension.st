Extension { #name : #BLUIContainer }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLUIContainer >> exportCode [
	"this can be useless but it also can help to follow some rule of programming"
	
	^ self widgets flatCollect: [ :widget | widget exportCode, String crlf, String tab ]

	
]
