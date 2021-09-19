path = require 'path'
{IndicatorDimensionSingleton, DimensionIndicatorSingleton} = require path.join __dirname, '..', 'toJSON', 'singletons'


json = IndicatorDimensionSingleton.showSingleJSON({rebuild:true})

#DimensionIndicatorSingleton.abstract({indicators: json})
#console.log DimensionIndicatorSingleton.dimensions 

