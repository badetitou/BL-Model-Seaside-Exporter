Extension { #name : #Dictionary }

{ #category : #'*BL-Model-Exporter-Seaside' }
Dictionary >> associationsFlatCollect: aBlock [
	^ self associations flatCollect: aBlock 
]
