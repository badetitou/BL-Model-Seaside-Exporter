Extension { #name : #BLUIInputCheckbox }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLUIInputCheckbox >> exportCode [
	^ 'html mdlCheckboxContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlCheckbox
				value: true;
				id: html lastId.
			html mdlCheckboxLabel: ''Checkbox'' ].'
]
