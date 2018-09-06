Extension { #name : #BLUIInputText }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLUIInputText >> exportCode [
	^ '	html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text...''.
			html mdlTextFieldInput id: html lastId ]'
]
