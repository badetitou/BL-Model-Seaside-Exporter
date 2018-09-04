Class {
	#name : #BaselineOfBLSeaside,
	#superclass : #BaselineOf,
	#category : 'BaselineOfBLSeaside'
}

{ #category : #baselines }
BaselineOfBLSeaside >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfBLSeaside >> defineDependencies: spec [
			spec
				baseline: 'MaterialDesignLite'
				with: [ spec repository: 'github://DuneSt/MaterialDesignLite:master/src' ].
]

{ #category : #baselines }
BaselineOfBLSeaside >> defineGroups: spec [
	spec 
		group: 'default' with: #('BL-Model-Exporter-Seaside' 'BL-Model-SeasideMDL' 'MaterialDesignLite') 
]

{ #category : #baselines }
BaselineOfBLSeaside >> definePackages: spec [
	spec 
		repository: 'https://github.com/badetitou/BL-Model-Seaside-Exporter';
		package: 'BaselineOfBLSeaside';
		package: 'BL-Model-Exporter-Seaside' with: [ spec requires: #('BL-Model-SeasideMDL') ];
		package: 'BL-Model-SeasideMDL'
]
