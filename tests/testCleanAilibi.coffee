path = require 'path'
{IndicatorDimensionSingleton, DimensionIndicatorSingleton} = require path.join __dirname, '..', 'toJSON', 'indicatorHelpers'


json = IndicatorDimensionSingleton.showJSON(rebuild:true)

#DimensionIndicatorSingleton.abstract({indicators: json})
#console.log DimensionIndicatorSingleton.dimensions 

