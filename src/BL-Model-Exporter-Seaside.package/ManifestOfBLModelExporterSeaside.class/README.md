"Reset Work"
MooseModel resetRoot.
MooseModel resetMeta.

"Generate BlApp"
aw := AnalyseCommand new.
fileName := '/home/badetitou/Documents/Work/PFE/Source/BLCoreIncubatorGwt/src/fr/bl/application.module.xml'. 
xml := aw getXmlFile: fileName.
mseFile := StandardFileStream fileNamed: '/home/badetitou/Documents/Work/PFE/GeneralXmlui.mse' .
mooseModel := MooseModel importFromMSEStream: mseFile .
mooseModel rootFolder: '/home/badetitou/Documents/Work/PFE/'.

"Generate Bl Model"
model := MooseModel new name: 'BL-Showroom'; yourself.
BLMooseModelCreatorAngular runOn: model fromSourceModel: mooseModel and: xml.

BLModelExporterSeaside export: model.

ZnZincServerAdaptor startOn: 8080.  "start on port 8080"
ZnZincServerAdaptor stop.