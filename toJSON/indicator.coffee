JU = require './jsonUtils'


class Indicator
  # 一个指标object仅含一年的一个数值,符合一物一用原则
  @fromJSONData: (funcOpts) ->

    jsonizedData = JU.jsonizedExcelData(funcOpts)
    histdata = new HistoricData()    
    
    # sheetName 是单位名,例如"医院",或"普外科"
    # rowName 是指标名称,json是指标内容
    for sheetName, table of jsonizedData 
      for rowName, rowObject of table
        for fieldName, value of rowObject when /(?:(?:20|21)\d{2})年/g.test(fieldName)
          key = rowName.replace('▲','') 
          {指标名称, 单位} = rowObject
          #console.log key, rowObject
          数值 = if /^比值/.test(单位) then eval(value) else value
          indicator = new this({指标名称,单位,数值})
          histdata.updateRecord({year:fieldName,sheetName,key,indicator}) 
    
		# json 只是用来查看和纠错的, instance objects 则应每次从原始文件生成
    {folder, basename, needToRewrite} = funcOpts
    JU.write2JSON({folder, basename:"#{basename}Hist", needToRewrite, obj: histdata})
      
    return histdata
		





  constructor: (funcOpts) ->
    {@指标名称, @单位, @数值} = funcOpts
    if indicatorDef?
      {@计量单位, @指标导向, @指标来源, @指标属性, @二级指标, @一级指标} = indicatorDef






class HistoricData
  constructor: (funcOpts) ->
    @records = {}
    @years = []
    @units = []

  # year: e.g. '2020年'
  # sheetName e.g. '医院','心内科'
  newRecord: (funcOpts) ->
    {year, sheetName, key, indicator,update=false} = funcOpts
    @years.push(year) unless year in @years
    @units.push(sheetName) unless sheetName in @units
    @records[year] ?= {}
    @records[year][sheetName] ?= {}

    if update
      @records[year][sheetName][key] = indicator
    else
      @records[year][sheetName][key] ?= indicator

  
  
  addRecord: (funcOpts) ->
    funcOpts.update = false
    @newRecord(funcOpts)


  updateRecord: (funcOpts) ->
    funcOpts.update = true
    @newRecord(funcOpts)

    

  ### year: e.g. '2020年'
  addTable: (funcOpts) ->
    {year, table} = funcOpts
    @records[year] ?= table
  ###


  description: ->
    @records

  
  yearsSorted: (funcOpts=(a,b)-> a - b) ->
    @years.sort(funcOpts)  # (key for key, value of @records).sort(funcOpts)


  unitsSorted: (funcOpts=(a,b)-> a - b) ->
    @units.sort(funcOpts)


module.exports = {
  Indicator
}