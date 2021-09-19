path = require 'path'
{IndicatorDimensionSingleton, DimensionIndicatorSingleton} = require path.join __dirname, '..', 'toJSON', 'indicatorSystem'


json = IndicatorDimensionSingleton.showJSON(rebuild:true)

#DimensionIndicatorSingleton.abstract({indicators: json})
#console.log DimensionIndicatorSingleton.dimensions 

