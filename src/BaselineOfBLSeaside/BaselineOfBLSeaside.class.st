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
		do: [ self dependencies: spec.
			spec repository: 'https://github.com/badetitou/BL-Model-Seaside-Exporter';
			package: 'BaselineOfBLSeaside';
			package: 'BL-Model-Exporter-Seaside';
			group: 'default'
					with:
					#('BL-Model-Exporter-Seaside') ]
]

{ #category : #baselines }
BaselineOfBLSeaside >> dependencies: spec. [
			spec
				baseline: 'MaterialDesignLite'
				with: [ spec repository: 'github://DuneSt/MaterialDesignLite:master/src' ].
			spec baseline: 'BLToolkit' with: [ spec repository: 'github://badetitou/BL-ToolKit' ] 
]
