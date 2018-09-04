Class {
	#name : #BLModelExporterSeaside,
	#superclass : #BLModelExporter,
	#category : 'BL-Model-Exporter-Seaside'
}

{ #category : #accessing }
BLModelExporterSeaside >> postExport [
	(RPackageOrganizer default packageNamed: model name) classes do: #initialize
]

{ #category : #accessing }
BLModelExporterSeaside >> prepareExport [
	RPackageOrganizer default createPackageNamed: model name
]

{ #category : #visiting }
BLModelExporterSeaside >> visitMooseModel: aMooseModel [
	aMooseModel allBLPhase do: [ :phase | self visit: phase ].
	aMooseModel allBLPageMetier do: [ :pageMetier | self visit: pageMetier ].
]
