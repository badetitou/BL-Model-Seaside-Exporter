Class {
	#name : #CSNSeasideExporter,
	#superclass : #CSNModelExporter,
	#category : #'Casino-Seaside-Exporter'
}

{ #category : #visiting }
CSNSeasideExporter >> acceptedNameForPageMetier: aPageMetier [
	^ self prefix , ((aPageMetier name splitOn: ':') last)
]

{ #category : #visiting }
CSNSeasideExporter >> createSubPageMetierOf: aBLPhase. [
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
CSNSeasideExporter >> exportCodeOfMultiplePageMetier: aBLPhase [
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
CSNSeasideExporter >> exportCodeOfOnePageMetier: aBLPhase [
	^ '
		html mdlLayout
		fixedHeader;
		with: [ html
				mdlLayoutHeader: ['
		,
			(aBLPhase title
				ifNil: [ '' ]
				ifNotNil: [ ' html
						mdlLayoutHeaderRow: [ html mdlLayoutTitle: ''' , aBLPhase title protectPharoQuote , ''' ] ' ])
		,
			']. 
		html mdlLayoutContent: [
			' , (self visit: aBLPhase businessPage first)
		,
			'
			] ].'
]

{ #category : #visiting }
CSNSeasideExporter >> exportCodeOfPageMetierOf: aBLPhase [
	aBLPhase hasMultiplePageMetier
		ifTrue: [ ^ self exportCodeOfMultiplePageMetier: aBLPhase ].
	aBLPhase hasNoPageMetier
		ifTrue: [ ^ self exportCodeOfWithoutPageMetier: aBLPhase ].
	^ self exportCodeOfOnePageMetier: aBLPhase
]

{ #category : #visiting }
CSNSeasideExporter >> exportCodeOfWithoutPageMetier: aBLPhase [
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
CSNSeasideExporter >> generateCss [
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
CSNSeasideExporter >> getVisitSubWidgetOf: aWidget [
	^ (aWidget widgets flatCollect: [:widget |  (self visit: widget) , String crlf, String tab])
]

{ #category : #accessing }
CSNSeasideExporter >> postExport [
	(RPackageOrganizer default packageNamed: model name) classes do: #initialize
]

{ #category : #accessing }
CSNSeasideExporter >> prefix [
	^ 'Exported'
]

{ #category : #accessing }
CSNSeasideExporter >> prepareExport [
	
	RPackageOrganizer default createPackageNamed: model name
]

{ #category : #'private-accessing' }
CSNSeasideExporter >> styleForWidget: aWidget [
	^ 'style: '''
		,((aWidget attributes select: [ :attribute | attribute isKindOf: CSNUIWidth ])
				ifNotEmpty: [ :col | 'width: ',(self visit: (col at: 1)) , ';' ]),
			((aWidget attributes select: [ :attribute | attribute isKindOf: CSNUIHeight ])
				ifNotEmpty: [ :col | 'height: ',(self visit: (col at: 1)) , ';' ])
		,''';'
]

{ #category : #visiting }
CSNSeasideExporter >> visitBLUIFieldsetDynamic: aBLUIFieldsetDynamic [
	^ 'html mdlCard
		shadow: 2;
		mdlTypographyTextLeft;' , (self styleForWidget: aBLUIFieldsetDynamic)
		,
			'
		with: [ 
			html mdlCardTitleContainer
				style: ''background: #d2e9fb'';
				with: [ html mdlCardTitleText: '''
		,
			((aBLUIFieldsetDynamic attributes select: [ :attribute | attribute isKindOf: CSNUITitle ])
				ifNotEmpty: [ :col | self visit: (col at: 1) ])
		,
			''' ].
				
			html mdlCardTextContainer: [ 
				' , (self visitUIPanel: aBLUIFieldsetDynamic)
		,
			' 
				] ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitBLUIInputTextArea: aBLUIInputTextArea [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitBLWidget: aBLWidget [
	^ ''
]

{ #category : #visiting }
CSNSeasideExporter >> visitCell: aBLCell [
	^ aBLCell widget ifNil: [ '' ] ifNotNil: [ self visit: aBLCell widget ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitLayout: aBLLayout [
	^ aBLLayout cell flatCollect: [ :cell | self visit: cell ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitMooseModel: aMooseModel [
	self generateCss.
	aMooseModel allCSNPage do: [ :phase | self visit: phase ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitPage: aBLPage [
	| class |
	class := MDLApplication
		subclass: self prefix , aBLPage name
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
	(self registerToDeployment: ''' , aBLPage name , ''') addLibrary: WAFileLibrary'
				, self model name.
	class
		compile:
			'renderContentOn: html  
	' , (self exportCodeOfPageMetierOf: aBLPage)
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
CSNSeasideExporter >> visitPageMetier: aPageMetier [
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
CSNSeasideExporter >> visitUIButton: aBLUIButton [
	^ 'html mdlButton
		rippleEffect;
		' ,
		((aBLUIButton attributes select: [ :attribute | (attribute isKindOf: CSNUIDisabled) and: [ attribute attributeValue = 'true' ] ]) ifNotEmpty: [ :col | (self visit: (col at: 1)) , ';' ])
		,
			((aBLUIButton attributes select: [ :attribute | attribute isKindOf: CSNUITitle ]) ifNotEmpty: [ :col | 'title: ''' , (self visit: (col at: 1)) , ''';' , String crlf , String tab ])
		,
			'
		with: ''' , ((aBLUIButton attributes select: [ :attribute | attribute isKindOf: CSNUILabel ]) flatCollect: [ :attribute | self visit: attribute ]) , '''.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIClass: aBLUIClass [
	^ aBLUIClass attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIContainer: aBLUIContainer [
	^ aBLUIContainer widgets flatCollect: [ :widget | (self visit: widget), String crlf, String tab ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIDisabled: aBLUIDisabled [
	aBLUIDisabled disabled
		ifTrue: [ ^ 'disabled' ]
		ifFalse: [ ^ '' ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIFieldset: aBLUIFieldset [
	^ 'html mdlCard
		shadow: 2;
		mdlTypographyTextLeft;
		' , (self styleForWidget: aBLUIFieldset)
		,
			'
		with: [ 
			html mdlCardTitleContainer
				style: ''background: #d2e9fb'';
				with: [ html mdlCardTitleText: '''
		,
			((aBLUIFieldset attributes select: [ :attribute | attribute isKindOf: CSNUITitle ])
				ifNotEmpty: [ :col | self visit: (col at: 1) ])
		,
			'''].
				
			html mdlCardTextContainer: [ 
				' , (self
		visitUIPanel:
			aBLUIFieldset)
				,
					' 
				] ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIGridLayout: aBLUIGridLayout [
	^ 'html
		table
		with: [ '
		,
			((0 to: aBLUIGridLayout cell size)
				flatCollect: [ :number | 
					| subset |
					(aBLUIGridLayout atLevel: number)
						ifEmpty: [ subset := 12 ]
						ifNotEmpty: [ subset := 12 / (aBLUIGridLayout atLevel: number) size.
							subset := subset < 1
								ifTrue: [ 1 ]
								ifFalse: [ subset floor ] ].
					'html tableRow
				with: [ '
						,
							((aBLUIGridLayout atLevelSorted: number)
								flatCollect: [ :widget | 
									'html tableData' , (aBLUIGridLayout
										seasideTdAttributeForCell:
											widget)
												,
													'
				with: [ ' , (self visit: widget) , ' ].' , String crlf ]) , ' ].' , String crlf ]) , ' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIHeight: aBLUIHeight [
	^ aBLUIHeight attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIHorizontalLayout: aBLUIHorizontalLayout [
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
			with: [ ' , (self visit: cell) , ' ].' ])
		,
			' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputCheckbox: aBLUICheckbox [
	^ 'html mdlCheckboxContainer
		rippleEffect;'
		,
			((aBLUICheckbox attributes select: [ :attribute | attribute isKindOf: CSNUITitle ])
				ifNotEmpty: [ :col | 'title: ''' , (self visit: (col at: 1)) , ''';' , String crlf , String tab ])
		,
			'
		for: html nextId;
		with: [ html mdlCheckbox '
		,
			((aBLUICheckbox attributes select: [ :attribute | (attribute isKindOf: CSNUIDisabled) and: [ attribute attributeValue = 'true' ] ])
				ifNotEmpty: [ :col | (self visit: (col at: 1)) , ';' ])
		,
			'
				id: html lastId.
			html mdlCheckboxLabel: '''
		,
			((aBLUICheckbox attributes select: [ :attribute | attribute isKindOf: CSNUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , ''' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputColor: aBLUIInputColor [
	^ 'html colorInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputDate: aBLUIInputDate [
	^ 'html dateInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputDatetimeLocal: aBBLUIInputDatetimeLocal [
	^ 'html dateTimeLocalInput.'.
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputEmail: aBBLUIInputEmail [
	^ 'html emailInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputFile: aBLUIInputFile [
	^ 'html fileUpload.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputMonth: aBLUIInputMonth [
	^ 'html monthInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputNumber: aBLUIInputNumber [
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
CSNSeasideExporter >> visitUIInputRadio: aBLUIInputRadio [
	^ 'html mdlRadioContainer
		rippleEffect;
		for: html nextId;
		with: [ html mdlRadioButton
				attributeAt: ''name'' put: '''
		,
			((aBLUIInputRadio attributes select: [ :attribute | attribute isKindOf: CSNUIName ])
				flatCollect: [ :attribute | self visit: attribute ])
		,
			''';
				id: html lastId.
			html mdlRadioLabel: '''
		,
			((aBLUIInputRadio attributes select: [ :attribute | attribute isKindOf: CSNUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , ''' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputRange: aBLUIInputRange [
	^ '	html mdlSlider
		min: 0;
		max: 100;
		value: 0.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputSearch: aBLUIInputSearch [
	^ 'html searchInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputTel: aBLUIInputTel [
	^ 'html telephoneInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputText: aBLUIInputText [
	^ '	html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: '''
		,
			((aBLUIInputText attributes select: [ :attribute | attribute isKindOf: CSNUIPlaceholder ])
				flatCollect: [ :attribute | self visit: attribute ])
		,
			'''.
			html mdlTextFieldInput id: html lastId; value: '''
		,
			((aBLUIInputText attributes select: [ :attribute | attribute isKindOf: CSNUIValue ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''	'
		,
			((aBLUIInputText attributes select: [ :attribute | (attribute isKindOf: CSNUIDisabled) and: [ attribute disabled ] ])
				ifNotEmpty: [ :col | ';' , String crlf , String tab , (self visit: (col at: 1)) ])
		, ' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputTime: aBLUIInputTime [
	^ 'html timeInput5.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputUrl: aBLUIInputUrl [
	^ 'html urlInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIInputWeek: aBLUIInputWeek [
	^ 'html weekInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUILabel: aBLUILabel [
	^ ((aBLUILabel attributeValue withoutPrefix: '''') withoutSuffix: '''') protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitUILeaf: aBLUILeaf [
	^ ''"'html text: ''', aBLUILeaf text protectPharoQuote, '''.'"
]

{ #category : #visiting }
CSNSeasideExporter >> visitUILink: aBLUILink [
	^ 'html anchor'
		,
			((aBLUILink actions select: #isActionAppel)
				ifNotEmpty: [ :actions | 
					'
			url: ''/', ((actions at: 1) call name),''';' ])
		,
			'
		with: ''' , ((aBLUILink attributes select: [ :attribute | attribute isKindOf: CSNUILabel ]) first attributeValue) protectPharoQuote , '''.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIList: aBLUIList [
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
CSNSeasideExporter >> visitUIName: aBLUIName [
	^ aBLUIName attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIPanel: aBLUIPanel [
	^ aBLUIPanel layout ifNotNil: [ self visit: aBLUIPanel layout ] ifNil: [ '' ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIParagraph: aBLUIParagraph [
	^ 'html paragraph ',
	((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: BLUIClass ]) ifNotEmpty: [ :collectionOfClass | 'class: ''', (collectionOfClass flatCollect: [ :attribute | self visit: attribute ]) , ''';', String crlf, String tab ] )
	,'with: [ html text: '''
		,
			((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: BLUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIPlaceholder: aBLUIPlaceholder [
	^ ((aBLUIPlaceholder attributeValue withoutPrefix: '''') withoutSuffix: '''') protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitUITabManager: aBLUITabManager [
	^ ''
]

{ #category : #visiting }
CSNSeasideExporter >> visitUITextarea: aBLUITextarea [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUITitle: aBLUITitle [
	^ aBLUITitle attributeValue protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitUITree: aBLUITree [
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
CSNSeasideExporter >> visitUIValue: aBLUIValue [
	^ aBLUIValue attributeValue protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIVerticalLayout: aBLUIVerticalLayout [
	^ 'html
		mdlGrid noSpacing;
		with: ['
		,
			(aBLUIVerticalLayout cell
				flatCollect: [ :cell | 
					'html mdlCell size: ''12'';
			with: [ ' , (self visit: cell widget) , ' ].' ]) , ' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitUIWidth: aBLUIWidth [
	^ aBLUIWidth attributeValue
]
