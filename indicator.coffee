JU = require './jsonUtils'


class Indicator
  # 一个指标object仅含一年的一个数值,符合一物一用原则
  @fromDataTable: (funcOpts) ->
    json = JU.jsonizedExcelData(funcOpts)
    histdata = new HistoricData()    
    
    # unitName 是单位名,例如医院,或科室名称
    # k是指标名称,json是指标内容
    for unitName, table of json 
      for k, json of table #when json.指标名称?
        for itemName, value of json when /(?:(?:20|21)\d{2})年/g.test(itemName)
          histdata[itemName] ?= {} 
          key = k.replace('▲','') 
          {指标名称, 单位} = json
          #console.log key, json
          数值 = if /^比值/.test(单位) then eval(value) else value
          indicator = new this({指标名称,单位,数值})
          histdata.updateRecord({year:itemName,unitName,key,indicator}) 
    
    {folder,basename} = funcOpts
    @saveToJSONFile({folder, basename:"#{basename}Hist", obj: histdata.records})
    
    return histdata
		


  
  @saveToJSONFile: (funcOpts) ->
    JU.write2JSON(funcOpts)




  constructor: (funcOpts) ->
    {@指标名称, @单位, @数值} = funcOpts
    if indicatorDef?
      {@计量单位, @指标导向, @指标来源, @指标属性,@二级指标,@一级指标} = indicatorDef






class HistoricData
  constructor: (funcOpts) ->
    @records = {}
    @years = []
    @units = []

  # year: e.g. '2020年'
  # unitName e.g. '医院','心内科'
  newRecord: (funcOpts) ->
    {year, unitName, key, indicator,update=false} = funcOpts
    @years.push(year) unless year in @years
    @units.push(unitName) unless unitName in @units
    @records[year] ?= {}
    @records[year][unitName] ?= {}

    if update
      @records[year][unitName][key] = indicator
    else
      @records[year][unitName][key] ?= indicator

  
  
  addRecord: (funcOpts) ->
    funcOpts.update = false
    @newRecord(funcOpts)


  updateRecord: (funcOpts) ->
    funcOpts.update = true
    @newRecord(funcOpts)

    

  # year: e.g. '2020年'
  addTable: (funcOpts) ->
    {year, table} = funcOpts
    @records[year] ?= table


  description: ->
    @records

  
  yearsSorted: (funcOpts=(a,b)-> a - b) ->
    @years.sort(funcOpts)  # (key for key, value of @records).sort(funcOpts)


  unitsSorted: (funcOpts=(a,b)-> a - b) ->
    @units.sort(funcOpts)


module.exports = {
  Indicator
}