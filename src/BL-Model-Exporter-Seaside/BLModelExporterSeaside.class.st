Class {
	#name : #BLModelExporterSeaside,
	#superclass : #BLModelExporter,
	#category : 'BL-Model-Exporter-Seaside'
}

{ #category : #visiting }
BLModelExporterSeaside >> acceptedNameForPageMetier: aPageMetier [
	^ (aPageMetier name splitOn: ':') last
]

{ #category : #visiting }
BLModelExporterSeaside >> createSubPageMetierOf: aBLPhase. [
	aBLPhase pageMetiers do: [ :metier |
		| class | 
		class := MDLApplication
		subclass: (self acceptedNameForPageMetier: metier)
		instanceVariableNames: ''
		classVariableNames: ''
		package: self model name.
			class
		compile:
			'initialize
    super initialize.'.
	class
		compile:
			('renderContentOn: html
			', (self visit: metier) )
		 ]
]

{ #category : #visiting }
BLModelExporterSeaside >> exportCodeOfMultiplePageMetier: aBLPhase [
	self createSubPageMetierOf: aBLPhase.
	^  '
		| metiers |
		metiers := OrderedDictionary new.',
		(aBLPhase pageMetiers flatCollect: [ :metier | String crlf, 'metiers add: ''', (metier title),''' -> ', (self acceptedNameForPageMetier: metier), ' new.'   ]),' 
		html mdlLayout
		fixedHeader;
		with: [ html
				mdlLayoutHeader: [ html
						mdlLayoutHeaderRow: [ html mdlLayoutTitle: ''' , aBLPhase title protectPharoQuote ,	 ''' ].
					html mdlLayoutTabBar
						rippleEffect;
						with: [ metiers
								keysDo: [ :metier | 
									html mdlLayoutTab
										isActiveIf: metier = ''', (aBLPhase pageMetiers at: 1) title,''';
										url: ''#tab-'' , (metier replaceAllRegex: '' '' with: '''');
										with: metier ] ] ].
			html
				mdlLayoutContent: [ metiers
						keysAndValuesDo: [ :metier :content | 
							html mdlLayoutTabPanel
								isActiveIf: metier = ''', (aBLPhase pageMetiers at: 1) title,''';
								id: ''tab-'' , (metier replaceAllRegex: '' '' with: '''');
								with: [ content renderContentOn: html ] ] ] ].'.
]

{ #category : #visiting }
BLModelExporterSeaside >> exportCodeOfOnePageMetier: aBLPhase [
	^ '
		html mdlLayout
		fixedHeader;
		with: [ html
				mdlLayoutHeader: [ html
						mdlLayoutHeaderRow: [ html mdlLayoutTitle: ''' , aBLPhase title protectPharoQuote
		,
			''' ] ]. 
		html mdlLayoutContent: [
			' , (self visit: (aBLPhase pageMetiers at: 1)) , '
			] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> exportCodeOfPageMetierOf: aBLPhase [
	aBLPhase hasMultiplePageMetier
		ifTrue: [ ^ self exportCodeOfMultiplePageMetier: aBLPhase ].
	aBLPhase hasNoPageMetier
		ifTrue: [ ^ '' ].
	^ self exportCodeOfOnePageMetier: aBLPhase
]

{ #category : #visiting }
BLModelExporterSeaside >> getVisitSubWidgetOf: aWidget [
	^ (aWidget widgets flatCollect: [:widget |  (self visit: widget) , String crlf, String tab])
]

{ #category : #accessing }
BLModelExporterSeaside >> postExport [
	(RPackageOrganizer default packageNamed: model name) classes do: #initialize
]

{ #category : #accessing }
BLModelExporterSeaside >> prepareExport [
	
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
	self registerToDeployment: ''' , aBLPhase name , ''''.
	class
		compile:
			'renderContentOn: html  
	' , (self exportCodeOfPageMetierOf: aBLPhase)
				,
					'
	html
		mdlMiniFooter: [ html
				mdlMiniFooterLeftSection: [ html mdlLogo: ''Berger-Levrault''.
					html
						mdlMiniFooterLinkList: [ html listItem: [ html anchor: ''By Benoît "Badetitou" Verhaeghe'' ] ] ] ]'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIFieldset: aBLUIFieldset [
	^ 'html mdlCard
		shadow: 2;
		mdlTypographyTextLeft;
		with: [ 
			html mdlCardTitle
				with: [ html mdlCardTitleText: ''' , (aBLUIFieldset parameters at: #title) protectPharoQuote
		,
			''' ].
				
			html mdlCardTextContainer: [ 
				' , (aBLUIFieldset widgets flatCollect: [ :widget | self visit: widget ]) , ' 
				] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIFieldsetDynamic: aBLUIFieldsetDynamic [
	^ 'html mdlCard
		shadow: 2;
		mdlTypographyTextLeft;
		with: [ 
			html mdlCardTitle
				with: [ html mdlCardTitleText: ''' , (aBLUIFieldsetDynamic parameters at: #legend) protectPharoQuote
		,
			''' ].
				
			html mdlCardTextContainer: [ 
				' , (aBLUIFieldsetDynamic widgets flatCollect: [ :widget | self visit: widget ]) , ' 
				] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIGrid: aBLUIGrid [
	^ 'html
		mdlGrid: [ ', (aBLUIGrid widgets flatCollect: [:widget | 'html mdlCell
				class: ''grid'';
				size: 12;
				with: [ ', (self visit: widget),' ].
				' ]), '].'.
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputText: aBLUIInputText [
	^ '	html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text...''.
			html mdlTextFieldInput id: html lastId ]'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUILeaf: aBLUILeaf [
	^ 'html text: ''', aBLUILeaf text protectPharoQuote, '''.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUILink: aBLUILink [ 
	^ 'html mdlButton
		rippleEffect;
		with: ''',(aBLUILink parameters
		at: #label) protectPharoQuote,'''.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIPanel: aBLUIBLUIPanel [
	^ (aBLUIBLUIPanel widgets flatCollect: [ :widget | self visit: widget ])
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIParagraph: aBLUIParagraph [
	^ 'html paragraph: [ ', (self getVisitSubWidgetOf: aBLUIParagraph ), '].'
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
