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
	aBLPhase businessPage do: [ :metier |
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
	^ '
		| metiers |
		metiers := OrderedDictionary new.'
		,
			(aBLPhase businessPage
				flatCollect: [ :metier | 
					String crlf , 'metiers add: ''' , metier title , ''' -> '
						, (self acceptedNameForPageMetier: metier) , ' new.' ])
		,
			' 
		html mdlLayout
		fixedHeader;
		with: [ html
				mdlLayoutHeader: [ html
						mdlLayoutHeaderRow: [ html mdlLayoutTitle: '''
		, aBLPhase title protectPharoQuote
		,
			''' ].
					html mdlLayoutTabBar
						rippleEffect;
						with: [ metiers
								keysDo: [ :metier | 
									html mdlLayoutTab
										isActiveIf: metier = ''' , aBLPhase businessPage first title
		,
			''';
										url: ''#tab-'' , (metier replaceAllRegex: '' '' with: '''');
										with: metier ] ] ].
			html
				mdlLayoutContent: [ metiers
						keysAndValuesDo: [ :metier :content | 
							html mdlLayoutTabPanel
								isActiveIf: metier = ''' , (aBLPhase businessPage first) title
		,
			''';
								id: ''tab-'' , (metier replaceAllRegex: '' '' with: '''');
								with: [ content renderContentOn: html ] ] ] ].'
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
			' , (self visit: aBLPhase businessPage first) , '
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
    ^ '''''
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

{ #category : #'private-accessing' }
BLModelExporterSeaside >> styleForWidget: aWidget [
	^ 'style: '''
		,((aWidget attributes select: [ :attribute | attribute isKindOf: BLUIWidth ])
				ifNotEmpty: [ :col | 'width: ',(self visit: (col at: 1)) , ';' ]),
			((aWidget attributes select: [ :attribute | attribute isKindOf: BLUIHeight ])
				ifNotEmpty: [ :col | 'height: ',(self visit: (col at: 1)) , ';' ])
		,''';'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLCell: aBLCell [
	^ self visit: aBLCell widget
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLLayout: aBLLayout [
	^ aBLLayout cell flatCollect: [ :cell | self visit: cell ]
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLPage: aBLPhase [
	| class |
	class := MDLApplication
		subclass: self prefix , aBLPhase name
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
						mdlMiniFooterLinkList: [ html listItem: [ html anchor url: ''https://badetitou.github.io''; 
								with: ''By Benoît "Badetitou" Verhaeghe'' ] ] ] ]'
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
		subclass: self prefix , aBLPhase name
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
						mdlMiniFooterLinkList: [ html listItem: [ html anchor url: ''https://badetitou.github.io''; 
								with: ''By Benoît "Badetitou" Verhaeghe'' ] ] ] ]'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIClass: aBLUIClass [
	^ aBLUIClass text
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
		' , (self styleForWidget: aBLUIFieldset)
		,
			'
		with: [ 
			html mdlCardTitle
				style: ''background: #d2e9fb'';
				with: [ html mdlCardTitleText: '''
		,
			((aBLUIFieldset attributes select: [ :attribute | attribute isKindOf: BLUITitle ])
				ifNotEmpty: [ :col | self visit: (col at: 1) ])
		,
			'''].
				
			html mdlCardTextContainer: [ 
				' , (self
		visitBLUIPanel:
			aBLUIFieldset)
				,
					' 
				] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIFieldsetDynamic: aBLUIFieldsetDynamic [
	^ 'html mdlCard
		shadow: 2;
		mdlTypographyTextLeft;' , (self styleForWidget: aBLUIFieldsetDynamic)
		,
			'
		with: [ 
			html mdlCardTitle
				style: ''background: #d2e9fb'';
				with: [ html mdlCardTitleText: '''
		,
			((aBLUIFieldsetDynamic attributes select: [ :attribute | attribute isKindOf: BLUITitle ])
				ifNotEmpty: [ :col | self visit: (col at: 1) ])
		,
			''' ].
				
			html mdlCardTextContainer: [ 
				' , (self visitBLUIPanel: aBLUIFieldsetDynamic)
		,
			' 
				] ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIGridLayout: aBLUIGridLayout [
	| text |
	text := ''.
	0 to: aBLUIGridLayout cell size do: [ :number | 
		| subset |
		(aBLUIGridLayout atLevel: number)
			ifEmpty: [ subset := 12 ]
			ifNotEmpty: [ subset := 12 / (aBLUIGridLayout atLevel: number) size.
				subset := subset < 1
					ifTrue: [ 1 ]
					ifFalse: [ subset floor ] ].
		text := text
			,
				((aBLUIGridLayout atLevelSorted: number)
					flatCollect: [ :widget | 
						'html mdlCell
				class: ''grid'';
				size: ' , subset asString
							,
								';
				with: [ ' , (self visit: widget) , ' ].' , String crlf ]) ].
	^ 'html
		mdlGrid
		with: [ ' , text , ' ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIHeight: aBLUIHeight [
	^ aBLUIHeight text
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIHorizontalLayout: aBLUIHorizontalLayout [
	| subset |
	aBLUIHorizontalLayout cell
		ifEmpty: [ subset := 12 ]
		ifNotEmpty: [ subset := 12 / aBLUIHorizontalLayout cell size.
			subset := subset < 1
				ifTrue: [ 1 ]
				ifFalse: [ subset floor ] ].
	^ 'html
		mdlGrid noSpacing;
		with: ['
		,
			(aBLUIHorizontalLayout cell
				flatCollect: [ :cell | 
					'html mdlCell size: ''' , subset asString
						,
							''';
			with: [ ' , (self visit: cell widget) , ' ].' ])
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
BLModelExporterSeaside >> visitBLUIInputFile: aBLUIInputFile [
	^ 'html fileUpload.'
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
				attributeAt: ''name'' put: '''
		,
			((aBLUIInputRadio attributes select: [ :attribute | attribute isKindOf: BLUIName ])
				flatCollect: [ :attribute | self visit: attribute ])
		,
			''';
				id: html lastId.
			html mdlRadioLabel: '''
		,
			((aBLUIInputRadio attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , ''' ].'
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
	^ ((aBLUILabel text  withoutPrefix: '''') withoutSuffix: '''') protectPharoQuote
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUILeaf: aBLUILeaf [
	^ ''"'html text: ''', aBLUILeaf text protectPharoQuote, '''.'"
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
BLModelExporterSeaside >> visitBLUIName: aBLUIName [
	^ aBLUIName nameValue
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIPanel: aBLUIPanel [
	^ aBLUIPanel layout ifNotNil: [ self visit: aBLUIPanel layout ] ifNil: [ '' ]
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIParagraph: aBLUIParagraph [
	^ 'html paragraph ',
	((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: BLUIClass ]) ifNotEmpty: [ :collectionOfClass | 'class: ''', (collectionOfClass flatCollect: [ :attribute | self visit: attribute ]) , ''';', String crlf, String tab ] )
	,'with: [ html text: '''
		,
			((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIPlaceholder: aBLUIPlaceholder [
	^ ((aBLUIPlaceholder text  withoutPrefix: '''') withoutSuffix: '''') protectPharoQuote
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUITabManager: aBLUITabManager [
	^ ''
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUITextarea: aBLUITextarea [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUITitle: aBLUITitle [
	^ aBLUITitle
		text
		protectPharoQuote
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUITree: aBLUITree [
	^ 'html div
		', (self styleForWidget: aBLUITree) ,' 
		shadow: 2;
		with:
			((MDLNestedList
				elements: #(1 2 3)
				children: [ :classOrMethod | #()] )
				format: #asString;
				yourself).'
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIValue: aBLUIValue [
	^ aBLUIValue text protectPharoQuote 
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLUIWidth: aBLUIWidth [
	^ aBLUIWidth text
]

{ #category : #visiting }
BLModelExporterSeaside >> visitBLWidget: aBLWidget [
	^ ''
]

{ #category : #visiting }
BLModelExporterSeaside >> visitMooseModel: aMooseModel [
	self generateCss.
	aMooseModel allBLPhase do: [ :phase | self visit: phase ]
]
