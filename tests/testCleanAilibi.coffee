path = require 'path'
{IndicatorDimensionSingleton, DimensionIndicatorSingleton} = require path.join __dirname, '..', 'toJSON', 'indicatorSystem'


json = IndicatorDimensionSingleton.fromExcel()

#DimensionIndicatorSingleton.rebuild({indicators: json})
#console.log DimensionIndicatorSingleton.dimensions 

