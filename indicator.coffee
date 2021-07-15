ju = require './jsonUtils'


class HistoricData
  constructor: (funcOpts) ->
    @records = {}
  

  # year: e.g. '2020年'
  addRecord: (funcOpts) ->
    {year, key, indicator} = funcOpts
    (@records[year] ?= {})[key] ?= indicator


  # year: e.g. '2020年'
  updateRecord: (funcOpts) ->
    {year, key, indicator} = funcOpts
    (@records[year] ?= {})[key] = indicator


  # year: e.g. '2020年'
  addTable: (funcOpts) ->
    {year, table} = funcOpts
    @records[year] ?= table


  description: ->
    @records

  
  yearsSorted:(funcOpts=(a,b)-> a - b) ->
    years = (key for key, value of @records).sort(funcOpts)





class Indicator
  # 一个指标object仅含一年的一个数值,符合一物一用原则
  @fromDataTable: (funcOpts) ->
    json = ju.jsonizedData(funcOpts)
    histdata = new HistoricData()
    #console.log json
    for unitName, table of json 
      for k, json of table
        for itemName, value of json when /(?:(?:20|21)\d{2})年/g.test(itemName)
          histdata[itemName] ?= {} 
          key = k.replace('▲','') 
          {指标名称, 单位} = json
          #console.log key, json
          throw new Error("缺少项:指标名称") unless 指标名称?
          数值 = if /^比值/.test(单位) then eval(value) else value
          indicator = new Indicator({指标名称,单位,数值})
          histdata.updateRecord({year:itemName,key,indicator}) 
    return histdata




  ### 复杂,不是好设计.几年的数值混在一起记录
  @fromDataTableMixed: (funcOpts) ->
    json = ju.jsonizedData(funcOpts)
    indicators = {}
    #console.log json
    for unitName, table of json 
      for k, json of table 
        key = k.replace('▲','') 
        #console.log key, json
        indicators[key] ?= new Indicator({json})

    return indicators
  ###  

  constructor: (funcOpts) ->
    {@指标名称, @单位, @数值} = funcOpts
    if indicatorDef?
      {@计量单位, @指标导向, @指标来源, @指标属性,@二级指标,@一级指标} = indicatorDef




class IndicatorValue
  @mixedFromJSON: (json) ->
    values = {}



  constructor: (funcOpts) ->
    {@年度,@数值} = funcOpts





module.exports = {
  Indicator,
  IndicatorValue
}