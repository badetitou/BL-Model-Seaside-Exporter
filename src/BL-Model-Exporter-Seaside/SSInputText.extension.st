Extension { #name : #SSInputText }

{ #category : #'*BL-Model-Exporter-Seaside' }
SSInputText >> exportCode [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text...''.
			html mdlTextFieldInput id: html lastId ].'
]
