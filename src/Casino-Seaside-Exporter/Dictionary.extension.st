Extension { #name : #Dictionary }

{ #category : #'*Casino-Seaside-Exporter' }
Dictionary >> associationsFlatCollect: aBlock [
	^ self associations flatCollect: aBlock 
]
