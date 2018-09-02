Extension { #name : #SSCheckBox }

{ #category : #'*BL-Model-Exporter-Seaside' }
SSCheckBox >> exportCode [
	^ 'html mdlCheckboxContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlCheckbox
				value: true;
				id: html lastId.
			html mdlCheckboxLabel: ''Checkbox'' ].'
]
