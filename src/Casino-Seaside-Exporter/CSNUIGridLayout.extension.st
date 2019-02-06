Extension { #name : #CSNUIGridLayout }

{ #category : #'*Casino-Seaside-Exporter' }
CSNUIGridLayout >> seasideTdAttributeForCell: aCell [
	"return as String because it is super specific to Grid"

	| cellPosition |
	cellPosition := (self privateState
		attributeAt: #cellPosition
		ifAbsentPut: [ Dictionary new ]) at: aCell.
	^ ''
		,
			(((self privateState attributeAt: #cellVerticalSpan ifAbsentPut: [ Dictionary new ])
				select: [ :param | param first = cellPosition first and: [ param second = cellPosition second ] ])
				keys
				flatCollect: [ :verticalSpan | ' rowSpan: ' , verticalSpan parameters third , '; ' ])
		,
			(((self privateState attributeAt: #cellHorizontalSpan ifAbsentPut: [ Dictionary new ])
				select: [ :param | param first = cellPosition first and: [ param second = cellPosition second ] ])
				keys
				flatCollect: [ :verticalSpan | ' colSpan: ' , verticalSpan parameters third , '; ' ])
]
