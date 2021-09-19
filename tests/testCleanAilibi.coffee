path = require 'path'
{IndicatorDimension} = require path.join __dirname, '..', 'toJSON', 'ailibi_indicators'


json = IndicatorDimension.convert()
dimensions = (value for key, value of json)
console.log {dimensions}