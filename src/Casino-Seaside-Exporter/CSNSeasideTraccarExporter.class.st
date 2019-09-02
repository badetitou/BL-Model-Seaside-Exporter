Class {
	#name : #CSNSeasideTraccarExporter,
	#superclass : #CSNSeasideExporter,
	#category : #'Casino-Seaside-Exporter'
}

{ #category : #visiting }
CSNSeasideTraccarExporter >> generateCss [
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
.mdl-textfield {
	display: block;
	 margin: 0;
    padding: 0;
    zoom: 1;
    white-space: nowrap;
    text-align: left;
    width: auto;
    position: relative;
    background-color: #ffffff;
    border-color: #c0c0c0;
    border-width: 1px;
    border-style: solid;
    -moz-box-sizing: border-box;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    overflow: hidden;
}

.mdl-textfield__input {
   height: auto;
    padding: 2px 6px 1px 6px;
    resize: none;
    height: 24px;
    line-height: 18px;
    vertical-align: top;
    color: #000000;
    font-size: 13px;
    font-family: helvetica,arial,verdana,sans-serif;
    font-weight: normal;
    border: 0;
    -webkit-box-sizing: border-box;
    -moz-box-sizing: border-box;
    box-sizing: border-box;
    -webkit-box-shadow: none;
    box-shadow: none;
}

.mdl-button{ 
    line-height: 18px;
    font-size: 12px;
    padding: 1px 1px 1px 1px;
    text-align: center;
    font-size: 12pxpx;
    color: #FFFFFF;
    font-weight: bold;
    font-family: helvetica,arial,verdana,sans-serif;
    vertical-align: middle;
}

.mdl-button { 
    border-radius: 4px;
    border-width: 1px 1px 1px 1px;
    border-style: solid;
    border-color: #126DAF;
    background-color: #3892d3;
    box-sizing: border-box;
    height: 100%;
    background: -webkit-linear-gradient(top, #4B9CD7 0%, #3892D3 50%, #358AC8 51%, #3892D3);
    background: -o-linear-gradient(top, #4B9CD7 0%, #3892D3 50%, #358AC8 51%, #3892D3);
    background: -ms-linear-gradient(top, #4B9CD7 0%, #3892D3 50%, #358AC8 51%, #3892D3);
    background: linear-gradient(to bottom, #4B9CD7 0%, #3892D3 50%, #358AC8 51%, #3892D3);
    padding: 3px 3px 3px 3px;
    cursor: pointer;
    outline: none;
    white-space: nowrap;
    overflow: hidden;
}

.mdl-card__title { 
    background: #3291d6;
    padding: 6px 10px 10px 10px;
}

.mdl-card__title-text { 
	 color: white;
	 font-family: tahoma, arial, verdana, sans-serif;
    font-size: 11px;
    font-weight: bold;
    line-height: 15px;
    color: #ffffff;
    font-size: 13px;
    font-weight: bold;
    font-family: arial,helvetica,verdana,sans-serif;
    line-height: 15px;
    text-transform: none;
}

.mdl-card__supporting-text { 
	padding: 3px 3px;
	width: auto;
}

.mdl-card { 
    border-radius: 4px;
    border-width: 5px 5px 5px 5px;
    border-style: solid;
    background-color: #ffffff;
    border-color: #3291d6;
    outline: none;
    padding: 0;
    overflow: hidden;
}


label { 
	 font-family: helvetica,arial,verdana,sans-serif;
    font-size: 13px;
    font-weight: normal;
    color: #000000;
    text-align: left;
    clear: left;
    display: block;
    float: left;
    padding: 5px 5px 0px 0px;
    position: relative;
    z-index: 2;
    overflow: hidden;
}

.mdl-textfield > label { 
	float: unset;
}

'''
]

{ #category : #visiting }
CSNSeasideTraccarExporter >> visitCSNUIInputCheckbox: aBLUICheckbox [
	^ 'html checkbox.'
]
