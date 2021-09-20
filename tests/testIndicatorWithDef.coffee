path = require 'path'
{Indicator} = require path.join __dirname,  '..', 'toJSON', 'indicator'
getHistdata = require './testIndicator'
arrayOfDefs = require './testIndicatorDef'

{histdata} = getHistdata(1)
{arr, dictionary} = arrayOfDefs({year:2020})
console.log dictionary, histdata.records
