Extension { #name : #String }

{ #category : #'*BL-Model-Exporter-Seaside' }
String >> protectPharoQuote [
	^ self copyReplaceAll: '''' with: ''''''
]
