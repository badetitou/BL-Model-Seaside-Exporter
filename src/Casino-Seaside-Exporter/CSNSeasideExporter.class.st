"
I export a CSNUIModel in a Seaside Application.


example: 
CSNSeasideExporter export: modelToExport.
"
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
CSNSeasideExporter >> createSubPageMetierOf: aBLPhase [.
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
CSNSeasideExporter >> exportOpenOnSeasideForClass: aClass [
	aClass class
		compile:
			'
open
	<script>
	| port url |
	WAServerManager default adaptors
		ifEmpty: [ (ZnZincServerAdaptor port: (port := 8085)) start ]
		ifNotEmpty: [ :adaptors | 
			adaptors
				detect: #isRunning
				ifFound: [ :anAdaptor | port := anAdaptor server port ]
				ifNone: [ (ZnZincServerAdaptor port: (port := 8085)) start ] ].
	url := ''http://localhost:'' , port asString , ''/', aClass name, '''.
	self flag: #pharo6.
	SystemVersion current major < 7
		ifTrue: [ self class environment
				at: #OSProcess
				ifPresent: [ :class | class command: ''open '' , url ]
				ifAbsent: [ self inform: ''Open '' , url , '' or install OSProcess.'' ] ]
		ifFalse: [ WebBrowser openOn: url ]'
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
	
	"RPackageOrganizer default createPackageNamed: model name"
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
CSNSeasideExporter >> visitCSNBusinessPage: aPageMetier [
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
CSNSeasideExporter >> visitCSNContainer: aBLUIContainer [
	^ aBLUIContainer widgets flatCollect: [ :widget | (self visit: widget), String crlf, String tab ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNDynamicFieldset: aBLUIFieldsetDynamic [
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
				' , (self visitCSNUIPanel: aBLUIFieldsetDynamic)
		,
			' 
				] ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNLCell: aBLCell [
	^ aBLCell widget ifNil: [ '' ] ifNotNil: [ self visit: aBLCell widget ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNLGridLayout: aBLUIGridLayout [
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
CSNSeasideExporter >> visitCSNLHorizontalLayout: aBLUIHorizontalLayout [
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
CSNSeasideExporter >> visitCSNLLayout: aBLLayout [
	^ aBLLayout cell flatCollect: [ :cell | self visit: cell ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNLVerticalLayout: aBLUIVerticalLayout [
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
CSNSeasideExporter >> visitCSNLeaf: aBLUILeaf [
	^ ''"'html text: ''', aBLUILeaf text protectPharoQuote, '''.'"
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNPage: aBLPage [
	| class |
	class := MDLApplication
		subclass: self prefix , aBLPage name
		instanceVariableNames: ''
		classVariableNames: ''
		package: self model name.
	self exportOpenOnSeasideForClass: class.
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
	(self registerToDeployment: ''' , class name , ''') addLibrary: WAFileLibrary' , self model name.
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
CSNSeasideExporter >> visitCSNUIButton: aBLUIButton [
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
CSNSeasideExporter >> visitCSNUIClass: aBLUIClass [
	^ aBLUIClass attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUICustomWidget: aCSNUICustomWidget [
	| class |
	class := MDLApplication
		subclass: self prefix , aCSNUICustomWidget name
		instanceVariableNames: ''
		classVariableNames: ''
		package: self model name.
	self exportOpenOnSeasideForClass: class.
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
	(self registerToDeployment: ''' , class name , ''') addLibrary: WAFileLibrary' , self model name.
	class
		compile:
			'renderContentOn: html  
	' , (aCSNUICustomWidget widgets flatCollect: [ :widget | widget accept: self ])
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIDisabled: aBLUIDisabled [
	aBLUIDisabled disabled
		ifTrue: [ ^ 'disabled' ]
		ifFalse: [ ^ '' ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIFieldset: aBLUIFieldset [
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
		visitCSNUIPanel:
			aBLUIFieldset)
				,
					' 
				] ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIHeight: aBLUIHeight [
	^ aBLUIHeight attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputCheckbox: aBLUICheckbox [
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
CSNSeasideExporter >> visitCSNUIInputColor: aBLUIInputColor [
	^ 'html colorInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputDate: aBLUIInputDate [
	^ 'html dateInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputDatetimeLocal: aBBLUIInputDatetimeLocal [
	^ 'html dateTimeLocalInput.'.
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputEmail: aBBLUIInputEmail [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Email''.
			html mdlTextFieldInput
				id: html lastId.
			html mdlTextFieldError: ''Input is not an email!'' ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputFile: aBLUIInputFile [
	^ 'html fileUpload.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputMonth: aBLUIInputMonth [
	^ 'html monthInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputNumber: aBLUIInputNumber [
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
CSNSeasideExporter >> visitCSNUIInputRadio: aBLUIInputRadio [
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
CSNSeasideExporter >> visitCSNUIInputRange: aBLUIInputRange [
	^ '	html mdlSlider
		min: 0;
		max: 100;
		value: 0.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputSearch: aBLUIInputSearch [
	^ 'html searchInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputTel: aBLUIInputTel [
	^ 'html telephoneInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputText: aBLUIInputText [
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
CSNSeasideExporter >> visitCSNUIInputTime: aBLUIInputTime [
	^ 'html timeInput5.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputUrl: aBLUIInputUrl [
	^ 'html urlInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIInputWeek: aBLUIInputWeek [
	^ 'html weekInput.'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUILabel: aBLUILabel [
	^ ((aBLUILabel attributeValue withoutPrefix: '''') withoutSuffix: '''') protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUILink: aBLUILink [
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
CSNSeasideExporter >> visitCSNUIList: aBLUIList [
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
CSNSeasideExporter >> visitCSNUIName: aBLUIName [
	^ aBLUIName attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIPanel: aBLUIPanel [
	^ aBLUIPanel layout ifNotNil: [ self visit: aBLUIPanel layout ] ifNil: [ self visitCSNContainer: aBLUIPanel ]
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIParagraph: aBLUIParagraph [
	^ 'html paragraph ',
	((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: CSNUIClass ]) ifNotEmpty: [ :collectionOfClass | 'class: ''', (collectionOfClass flatCollect: [ :attribute | self visit: attribute ]) , ''';', String crlf, String tab ] )
	,'with: [ html text: '''
		,
			((aBLUIParagraph attributes select: [ :attribute | attribute isKindOf: CSNUILabel ])
				flatCollect: [ :attribute | self visit: attribute ]) , '''].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIPlaceholder: aBLUIPlaceholder [
	^ ((aBLUIPlaceholder attributeValue withoutPrefix: '''') withoutSuffix: '''') protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUISelect: aCSNUISelect [
	^ 'html
    render:
        (MDLSelectWidget new).'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUITabManager: aBLUITabManager [
	^ ''
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUITextarea: aBLUIInputTextArea [
	^ 'html
		mdlTextFieldContainer: [ html mdlTextFieldLabel
				for: html nextId;
				with: ''Text lines...''.
			html mdlTextArea
				id: html lastId;
				rows: 3 ].'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUITitle: aBLUITitle [
	^ aBLUITitle attributeValue protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUITree: aBLUITree [
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
CSNSeasideExporter >> visitCSNUIValue: aBLUIValue [
	^ aBLUIValue attributeValue protectPharoQuote
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIWidgetLabel: aCSNUIWidgetLabel [
	^ 'html label with: [ html text: ''' , ((aCSNUIWidgetLabel attributes select: [ :attribute | attribute isKindOf: CSNUILabel ]) flatCollect: [ :attribute | self visit: attribute ]) , '''.'
		, String crlf , (aCSNUIWidgetLabel widgets flatCollect: [ :widget | (self visit: widget) , String crlf , String tab ]) , ']'
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNUIWidth: aBLUIWidth [
	^ aBLUIWidth attributeValue
]

{ #category : #visiting }
CSNSeasideExporter >> visitCSNWidget: aWidget [
	^ ''
]

{ #category : #visiting }
CSNSeasideExporter >> visitMooseModel: aMooseModel [
	self generateCss.
	aMooseModel allCSNPage do: [ :phase | self visit: phase ]
]
