Class {
	#name : #BLModelExporterSeaside,
	#superclass : #BLModelExporter,
	#category : 'BL-Model-Exporter-Seaside'
}

{ #category : #visiting }
BLModelExporterSeaside >> acceptedNameForPageMetier: aPageMetier [
	^ self prefix , ((aPageMetier name splitOn: ':') last)
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
BLModelExporterSeaside >> visitBLUIContainer: aBLUIContainer [
	^ aBLUIContainer widgets flatCollect: [ :widget | (self visit: widget), String crlf, String tab ]
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIDisabled: aBLUIDisabled [
	aBLUIDisabled disabled
		ifTrue: [ ^ 'disabled' ]
		ifFalse: [ ^ '' ]
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
		rippleEffect;
		'
		,
			((aBLUIInputButton attributes select: [ :attribute | (attribute isKindOf: BLUIDisabled) and: [ attribute disabled ] ])
				ifNotEmpty: [ :col | (self visit: (col at: 1)) , ';' ])
		,
			((aBLUIInputButton attributes select: [ :attribute | attribute isKindOf: BLUITitle ])
				ifNotEmpty: [ :col | 'title: ''' , (self visit: (col at: 1)) , ''';' , String crlf , String tab ])
		,
			'
		with: '''
		,
			((aBLUIInputButton attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputCheckbox: aBLUICheckbox [
	^ 'html mdlCheckboxContainer
		rippleEffect;'
		,
			((aBLUICheckbox attributes select: [ :attribute | attribute isKindOf: BLUITitle ])
				ifNotEmpty: [ :col | 'title: ''' , (self visit: (col at: 1)) , ''';' , String crlf , String tab ])
		,
			'
		for: html nextId;
		with: [ html mdlCheckbox '
		,
			((aBLUICheckbox attributes select: [ :attribute | (attribute isKindOf: BLUIDisabled) and: [ attribute disabled ] ])
				ifNotEmpty: [ :col | (self visit: (col at: 1)) , ';' ])
		,
			'
				id: html lastId.
			html mdlCheckboxLabel: '''
		,
			((aBLUICheckbox attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , ''' ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputColor: aBLUIInputColor [
	^ 'html colorInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputDate: aBLUIInputDate [
	^ 'html dateInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputDatetimeLocal: aBBLUIInputDatetimeLocal [
	^ 'html dateTimeLocalInput.'.
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputEmail: aBBLUIInputEmail [
	^ 'html emailInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputMonth: aBLUIInputMonth [
	^ 'html monthInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputNumber: aBLUIInputNumber [
	^  'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Number...''.
			html mdlTextFieldInput
				id: html lastId;
				pattern: ''-?[0-9]*(\.[0-9]+)?''.
			html mdlTextFieldError: ''Input is not a number !'' ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputRadio: aBLUIInputRadio [
	^ 'html mdlRadioContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlRadioButton
				beChecked;
				attributeAt: ''name'' put: ''options'';
				id: html lastId.
			html mdlRadioLabel: ''',
			((aBLUIInputRadio attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , ''' ]'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputRange: aBLUIInputRange [
	^ '	html mdlSlider
		min: 0;
		max: 100;
		value: 0.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputSearch: aBLUIInputSearch [
	^ 'html searchInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputTel: aBLUIInputTel [
	^ 'html telephoneInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputText: aBLUIInputText [
	^ '	html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: '''
		,
			((aBLUIInputText attributes select: [ :attribute | attribute isKindOf: BLUIPlaceholder ])
				flatCollect: [ :attribute | self visit: attribute ])
		,
			'''.
			html mdlTextFieldInput id: html lastId; value: '''
		,
			((aBLUIInputText attributes select: [ :attribute | attribute isKindOf: BLUIValue ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''	'
		,
			((aBLUIInputText attributes select: [ :attribute | (attribute isKindOf: BLUIDisabled) and: [ attribute disabled ] ])
				ifNotEmpty: [ :col | ';' , String crlf , String tab , (self visit: (col at: 1)) ])
		, ' ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputTextArea: aBLUIInputTextArea [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputTime: aBLUIInputTime [
	^ 'html timeInput5.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputUrl: aBLUIInputUrl [
	^ 'html urlInput.'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIInputWeek: aBLUIInputWeek [
	^ 'html weekInput.'
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
BLModelExporterSeaside >> visitBLUIList: aBLUIList [
	^ '
	html mdlTable
		shadow: 2;
		selectable;
		with: [ html
				tableHead: [ html
						tableRow: [ html mdlTableHeading: ''Head1''.
							html tableHeading: ''Head2''. ] ].
			 ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIPanel: aBLUIBLUIPanel [
	^ aBLUIBLUIPanel widgets
		flatCollect: [ :widget | 'html mdlDiv with: [ ' , (self visit: widget) , ' ].' ]
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIParagraph: aBLUIParagraph [
	^ 'html paragraph: [ html text: '''
		,
			((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIPlaceholder: aBLUIPlaceholder [
	^ aBLUIPlaceholder text protectPharoQuote 
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUITitle: aBLUITitle [
	^ aBLUITitle
		text
		protectPharoQuote
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIValue: aBLUIValue [
	^ aBLUIValue text protectPharoQuote 
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLWidget: aBLWidget [
	^ ''
]

{ #category : #visiting }
BLModelExporterSeaside >> visitMooseModel: aMooseModel [
	self generateCss.
	aMooseModel allBLPhase do: [ :phase | self visit: phase ]
	"aMooseModel allBLPageMetier do: [ :pageMetier | self visit: pageMetier ]."
]
