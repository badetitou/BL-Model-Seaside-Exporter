*BL-Model-Exporter-Seaside
exportCode
	^ 'html mdlRadioContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlRadioButton
				value: ''' , (self parameters at: 'label')
		,
			''';
				attributeAt: ''name'' put: ''' , (self parameters at: 'name')
		,
			''';
				id: html lastId.
			html mdlRadioLabel: ''Radio'' ]'