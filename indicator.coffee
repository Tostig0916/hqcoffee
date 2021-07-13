ju = require './jsonUtils'


class Indicator
  @fromDataTable: (funcOpts) ->
    json = ju.jsonizedData(funcOpts)
    indicators = {}
    console.log json
    for k, o of table for unitName, table of json 
      key = k.replace('▲','') 
      #console.log key, o
      indicators[key] ?= new Indicator({指标名称:key,json:o})

		
    return indicators
    

  constructor: (funcOpts) ->
    {@指标名称, @json} = funcOpts
    if indicatorDef?
      {@计量单位, @指标导向, @指标来源, @指标属性,@二级指标,@一级指标} = indicatorDef




class IndicatorValue
  constructor: (funcOpts) ->
    {@年度, @数值} = funcOpts





module.exports = {
  Indicator,
  IndicatorValue
}