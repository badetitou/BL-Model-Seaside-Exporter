Extension { #name : #SSTextArea }

{ #category : #'*BL-Model-Exporter-Seaside' }
SSTextArea >> exportCode [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]
