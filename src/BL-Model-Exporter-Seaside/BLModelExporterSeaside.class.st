Class {
	#name : #BLModelExporterSeaside,
	#superclass : #BLModelExporter,
	#category : 'BL-Model-Exporter-Seaside'
}

{ #category : #visiting }
BLModelExporterSeaside >> exportCodeOfPageMetierOf: aBLPhase [
	aBLPhase hasMultiplePageMetier ifTrue: [ ^ '"multiple"' ].
	aBLPhase hasNoPageMetier ifTrue: [ ^ '' ].
	^ self visit: (aBLPhase pageMetiers at: 1).
]

{ #category : #accessing }
BLModelExporterSeaside >> postExport [
	(RPackageOrganizer default packageNamed: model name) classes do: #initialize
]

{ #category : #accessing }
BLModelExporterSeaside >> prepareExport [
	RPackageOrganizer default unregisterPackageNamed: model name.
	RPackageOrganizer default createPackageNamed: model name
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLPageMetier: aPageMetier [
	^ aPageMetier widgets flatCollect: [ :widget | (self visit: widget), String crlf, String tab ]
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLPhase: aBLPhase [
	| class |
	class := MDLApplication
		subclass: aBLPhase name
		instanceVariableNames: ''
		classVariableNames: ''
		package: self model name.
	class
		compile:
			'initialize
    super initialize.'.
	class class
		compile:
			'initialize
	self registerToDeployment: ''' , aBLPhase name, ''''.
	class compile: 
		'renderContentOn: html 
		html mdlLayout
		fixedHeader;
		with: [ html
				mdlLayoutHeader: [ html
						mdlLayoutHeaderRow: [ html mdlLayoutTitle: ''', aBLPhase title protectPharoQuote ,'''. ] ] ].
	', (self exportCodeOfPageMetierOf: aBLPhase),
	'html
		mdlMiniFooter: [ html
				mdlMiniFooterLeftSection: [ html mdlLogo: ''Berger-Levrault''.
					html
						mdlMiniFooterLinkList: [ html listItem: [ html anchor: ''By Benoît "Badetitou" Verhaeghe'' ] ] ] ]' 
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLWidget: aBLWidget [
	^ aBLWidget exportCode
]

{ #category : #visiting }
BLModelExporterSeaside >> visitMooseModel: aMooseModel [
	aMooseModel allBLPhase do: [ :phase | self visit: phase ].
	"aMooseModel allBLPageMetier do: [ :pageMetier | self visit: pageMetier ]."
]
