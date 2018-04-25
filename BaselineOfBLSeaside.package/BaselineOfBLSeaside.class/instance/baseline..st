baselines
baseline: spec
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