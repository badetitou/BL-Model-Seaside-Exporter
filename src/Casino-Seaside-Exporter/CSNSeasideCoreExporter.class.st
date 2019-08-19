"
I export a CSNUIModel in a Seaside Application.
I define a specific CSS for the application (css inspired by one of a french company)

example: 
CSNSeasideCoreExporter export: modelToExport.
"
Class {
	#name : #CSNSeasideCoreExporter,
	#superclass : #CSNSeasideExporter,
	#category : #'Casino-Seaside-Exporter'
}

{ #category : #visiting }
CSNSeasideCoreExporter >> generateCss [
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
.mdl-card__title-text {
    color: #1D417D;
    cursor: default;
    font-family: "Arial";
    font-size: 11px;
    font-weight: bold;
    padding-left: 5px;
    text-align: left;
    vertical-align: middle;
    height: 18px;
}

.mdl-textfield__input { 
    font-family: "Verdana";
    color: #000000;
    white-space: nowrap;
    background-color: white;
    font-size: 10px;
    height: 14px;
    vertical-align: middle;
    border-color: #A7D6F8;
    border-style: solid;
    border-width: 1px;
    padding: 0 1px 0 0;
}

.mdl-textfield { 
	padding: 0px;
}

.mdl-card__title {
	padding: 0px 0px 0px 5px;
}

.mdl-card { 
	margin-bottom: 12px;
	margin-top: 5px;
	width: 100%;
   min-height: auto;
   border-radius: 0px;
}

.mdl-card__supporting-text { 
	margin: 3px 8px 3px 8px;
	padding: 0px;
	width: 100%;
}

.mdl-mini-footer { 
	padding: 0px 17px;
}

main.mdl-layout__content { 
	padding-left: 6px;
	padding-right: 6px;
	padding-top: 1px;
	padding-bottom: 1px;
}

.mdl-button { 
	text-transform: none;
	font-size: 0.7rem;
   padding: 0.05rem 0.05rem;
   background-color: #c91126;
   border-color: #c91126;
   border-radius: 15px !important;
	color: #fff;
	line-height: normal;
	height: 15px;
	padding-left: 5px;
   padding-right: 5px;

   &[disabled] {
     text-decoration:none;
     background-color: #666666;
     border-color: #666666;
   }
}

body {
	color: black;
	font-family: "Verdana";
	font-size: 10px;
	margin: 0px 0px 0px 0px;
}

p { 
    margin: 0;
	line-height: normal;
	
}

.NIVEAU1 {
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #1D417D;
}

.BLLabelNiveau1Selected {
	background-color: #1D417D;
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #FFFFFF;
}

.NIVEAU2 {
	font-family: "Verdana";
	font-weight: normal;
	font-size: 10px;
	color: #1D417D;
}

.BLLabelNiveau2Selected {
	background-color: #1D417D;
	font-family: "Verdana";
	font-weight: normal;
	font-size: 10px;
	color: #FFFFFF;
}

.BLLabel-disabled {
/* color: gray; */
}

.NIVEAU1LIST {
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #1D417D;
}

.NIVEAU2LIST {
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #000000;
}

.BLLabelListNiveau2Italic {
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #000000;
	font-style: italic;
}

.NIVEAU3LIST {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #000000;
}

.NIVEAU3LISTROUGE {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #DB1D6D;
	text-align: left;
}

.NIVEAU3LISTVERT {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #00A157;
	text-align: left;
}

.NIVEAU3LISTMARRON {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #734817;
	text-align: left;
}

.NIVEAU3LISTLAVANDE {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #793EA0;
	text-align: left;
}

.NIVEAU3LISTVERTCLAIR {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #03B6AB;
	text-align: left;
}

.NIVEAU3LISTVERTFONCE {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: normal;
	color: #009045;
	text-align: left;
}

.NIVEAU2LISTCLIGNOTANT {
	font-family: "Verdana";
	font-size: 10px;
	font-weight: bold;
	text-decoration: blink;
}

.NIVEAU_VALEUR {
	font-family: "Verdana";
	font-size: 10px;
	color: #000000;
	font-weight: normal;
}

.TABLE_LIST {     
	padding-left: 3px;
   padding-right: 3px;
   vertical-align: middle;
   color: black;
   font-family: "Verdana";
   font-size: 10px;
}

.MANDATORTY_CHARACTER {
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #C91126;
	vertical-align: bottom;
}

.WARNING_STYLE {
	font-family: "Verdana";
	font-weight: bold;
	font-size: 10px;
	color: #C91126;
}

a { 
	font-size: 0.7rem;
    padding: 0;
    cursor: pointer;
    color: #1D417D;
    font-family: "Verdana";
    font-weight: bold;
    font-size: 10px;
    text-decoration: underline; 
}

'''
]
