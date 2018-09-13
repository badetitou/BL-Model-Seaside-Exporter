Extension { #name : #BLUIInputButton }

{ #category : #'*BL-Model-Exporter-Seaside' }
BLUIInputButton >> exportCode [
	^ 'html mdlButton
		raised;
		primaryColor;
		with: ''Button''.'
]
