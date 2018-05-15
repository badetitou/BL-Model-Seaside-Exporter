*BL-Model-Exporter-Seaside
exportCode
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text...''.
			html mdlTextFieldInput id: html lastId ].'