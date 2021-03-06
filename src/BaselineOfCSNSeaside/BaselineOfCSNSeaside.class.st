Class {
	#name : #BaselineOfCSNSeaside,
	#superclass : #BaselineOf,
	#category : #BaselineOfCSNSeaside
}

{ #category : #baselines }
BaselineOfCSNSeaside >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfCSNSeaside >> defineDependencies: spec [
	spec
		baseline: 'MaterialDesignLite'
		with: [ spec repository: 'github://DuneSt/MaterialDesignLite:master/src' ].
	spec
		baseline: 'Casino'
		with: [ spec
				loads: 'core-extented';
				repository: 'github://badetitou/Casino:master/src' ]
]

{ #category : #baselines }
BaselineOfCSNSeaside >> defineGroups: spec [
	spec group: 'default' with: #('Casino-Seaside-Exporter')
]

{ #category : #baselines }
BaselineOfCSNSeaside >> definePackages: spec [
	spec
		repository: 'https://github.com/badetitou/BL-Model-Seaside-Exporter';
		package: 'BaselineOfBLSeaside';
		package: 'Casino-Seaside-Exporter'
			with: [ spec requires: #('Casino' 'MaterialDesignLite') ]
]
