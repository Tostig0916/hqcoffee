path = require 'path'
{Indicator} = require path.join __dirname,  '..', 'toJSON', 'indicator'
getHistdata = require './testIndicator'
arrayOfDefs = require './testIndicatorDef'

#ju = require path.join __dirname, '../jsonUtils'


{histdata} = getHistdata(1)
{arr, dictionary} = arrayOfDefs({year:2020})
console.log dictionary, histdata.records
