Extension { #name : #String }

{ #category : #'*Casino-Seaside-Exporter' }
String >> protectPharoQuote [
	^ self copyReplaceAll: '''' with: ''''''
]
