path = require 'path'
{Indicator} = require path.join __dirname,  '..', 'toJSON', 'indicator'
getHistdata = require './testIndicator'
arrayOfDefs = require './testIndicatorDef'

#ju = require path.join __dirname, '../jsonUtils'


getHistdata(1)
arr = arrayOfDefs({year:2020})
console.log arr
