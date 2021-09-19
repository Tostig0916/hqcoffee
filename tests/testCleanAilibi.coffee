path = require 'path'
{SingletonIndicatorDimension, SingletonDimensionIndicator} = require path.join __dirname, '..', 'toJSON', 'indicatorSystem'


json = SingletonIndicatorDimension.fromExcel()

#SingletonDimensionIndicator.rebuild({indicators: json})
#console.log SingletonDimensionIndicator.dimensions 

