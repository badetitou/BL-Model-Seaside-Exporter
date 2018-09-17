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
		subclass: (self prefix, (self acceptedNameForPageMetier: metier))
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
		ifTrue: [ ^ self exportCodeOfWithoutPageMetier: aBLPhase ].
	^ self exportCodeOfOnePageMetier: aBLPhase
]

{ #category : #visiting }
BLModelExporterSeaside >> exportCodeOfWithoutPageMetier: aBLPhase [
	^ '
		html mdlLayout
		fixedHeader;
		with: [ html
				mdlLayoutHeader: [ html
						mdlLayoutHeaderRow: [ html mdlLayoutTitle: ''No title'' ] ]. 
		html mdlLayoutContent: [
			' , (aBLPhase widgets flatCollect: [:widget | self visit: widget ]) , '
			] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> generateCss [
	| class |
	class := WAFileLibrary
		subclass: WAFileLibrary name , self model name
		instanceVariableNames: ''
		classVariableNames: ''
		package: self model name , '-Config'.
	class
		compile:
			'mainCss
    ^ ''
body {
  font-family: "Open Sans", sans-serif;
}

.mdl-card__title-text {
    color: #1D417D;
    cursor: default;
    font-family: "Arial";
    font-size: 11px;
    font-weight: bold;
    padding-left: 5px;
    text-align: left;
    vertical-align: middle;
    height: 16px;
}

.mdl-card__title {
	padding: 0px 0px 0px 5px;
}

'' '
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
BLModelExporterSeaside >> prefix [
	^ 'Exported'
]

{ #category : #accessing }
BLModelExporterSeaside >> prepareExport [
	
	RPackageOrganizer default createPackageNamed: model name
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLPageMetier: aPageMetier [
	aPageMetier metiers
		ifNotEmpty: [ :metiers | 
			^ 'html render: (MDLTabWidget new '
				,
					(metiers
						flatCollect: [ :metier | 
							'addTabNamed: ''' , metier title protectPharoQuote , ''' content: [' , (self visit: metier) , '];'
								, String crlf , String tab ]) , 'yourself).' ]
		ifEmpty: [ ^ aPageMetier widgets
				flatCollect: [ :widget | (self visit: widget) , String crlf , String tab ] ]
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLPhase: aBLPhase [
	| class |
	class := MDLApplication
		subclass: (self prefix, aBLPhase name)
		instanceVariableNames: ''
		classVariableNames: ''
		package: self model name.
	class
		compile:
			'initialize
    super initialize.'.
	class
		compile:
			'updateRoot: anHtmlRoot
		super updateRoot: anHtmlRoot.
		anHtmlRoot stylesheet url: WAFileLibrary' , self model name , ' / #mainCss'.
	class class
		compile:
			'initialize
	(self registerToDeployment: ''' , aBLPhase name , ''') addLibrary: WAFileLibrary' , self model name.
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
		style: ''width: 100%; height: 100%; min-height: 100%'';
		with: [ 
			html mdlCardTitle
			style: ''background: #d2e9fb'';
				with: [ html mdlCardTitleText: '''
		, (aBLUIFieldset parameters at: #title) protectPharoQuote
		,
			'''].
				
			html mdlCardTextContainer: [ 
				' , (aBLUIFieldset widgets flatCollect: [ :widget | self visit: widget ])
		,
			' 
				] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIFieldsetDynamic: aBLUIFieldsetDynamic [
	^ 'html mdlCard
		shadow: 2;
		mdlTypographyTextLeft;
		style: ''width: 100%; height: 100%; min-height: 100%'';
		with: [ 
			html mdlCardTitle
				with: [ html mdlCardTitleText: '''
		, (aBLUIFieldsetDynamic parameters at: #legend) protectPharoQuote
		,
			''' ].
				
			html mdlCardTextContainer: [ 
				' , (aBLUIFieldsetDynamic widgets flatCollect: [ :widget | self visit: widget ])
		,
			' 
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
BLModelExporterSeaside >> visitBLUIHorizontalPanel: aBLUIHorizontalPanel [
	| subset |
	aBLUIHorizontalPanel widgets
		ifEmpty: [ subset := 12 ]
		ifNotEmpty: [ subset := 12 / aBLUIHorizontalPanel widgets size.
			subset := subset < 1
				ifTrue: [ 1 ]
				ifFalse: [ subset floor ] ].
	^ 'html
		mdlGrid noSpacing;
		with: ['
		,
			(aBLUIHorizontalPanel widgets
				flatCollect: [ :widget | 
					'html mdlCell size: ''' , subset asString
						,
							''';
			with: [ ' , (self visit: widget) , ' ].' ])
		,
			' ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputButton: aBLUIInputButton [
	^ 'html mdlButton
		raised;
		primaryColor;
		with: '''
		, ((aBLUIInputButton attributes select: [:attribute | attribute isKindOf: BLUILabel ]) flatCollect: [ :attribute | self visit: attribute ])
		, '''.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputCheckbox: aBLUICheckbox [
	^ 'html mdlCheckboxContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlCheckbox
				value: true;
				id: html lastId.
			html mdlCheckboxLabel: ''' , (aBLUICheckbox parameters at: #label) protectPharoQuote , ''' ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputText: aBLUIInputText [
	^ '	html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text...''.
			html mdlTextFieldInput id: html lastId ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUILabel: aBLUILabel [
	^ aBLUILabel text protectPharoQuote 
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUILeaf: aBLUILeaf [
	^ 'html text: ''', aBLUILeaf text protectPharoQuote, '''.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUILink: aBLUILink [
	^ 'html anchor'
		,
			(aBLUILink actions
				ifNotEmpty: [ :actions | 
					'
			url: ''/', ((actions at: 1) call name),''';' ])
		,
			'
		with: ''' , (aBLUILink parameters at: #label) protectPharoQuote , '''.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIPanel: aBLUIBLUIPanel [
	^ aBLUIBLUIPanel widgets
		flatCollect: [ :widget | 'html mdlDiv with: [ ' , (self visit: widget) , ' ].' ]
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
	self generateCss.
	aMooseModel allBLPhase do: [ :phase | self visit: phase ]
	"aMooseModel allBLPageMetier do: [ :pageMetier | self visit: pageMetier ]."
]
