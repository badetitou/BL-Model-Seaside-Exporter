*BL-Model-Exporter-Seaside
exportCode
	^ 'html mdlCheckboxContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlCheckbox
				value: true;
				id: html lastId.
			html mdlCheckboxLabel: ''Checkbox'' ].'