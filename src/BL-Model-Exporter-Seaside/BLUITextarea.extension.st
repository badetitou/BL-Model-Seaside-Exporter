Extension { #name : #BLUITextarea }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLUITextarea >> exportCode [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]
