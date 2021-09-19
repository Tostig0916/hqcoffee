path = require 'path'
{IndicatorDimension} = require path.join __dirname, '..', 'toJSON', 'ailibi_indicators'

# 指标维度
json = IndicatorDimension.convert()
# 维度指标
dimensions = {} 
for key, value of json
  (dimensions[value] ?= []).push(key) 
console.log {dimensions}