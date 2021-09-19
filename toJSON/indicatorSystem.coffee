JU = require './jsonUtils'


# 别名正名对照及转换
class CommonNameSingleton
  @options: ->
    {
      folder: 'data'
      basename: '别名表'
    }

  @singleJSON: ->
    @commonNames ?= JU.readFromJSON(@options())


# 此表为 singleton,只有一个instance,故可使用 class 一侧定义
# 指标维度表
class IndicatorDimensionSingleton
  @options: ->
    {
      basename: "指标维度表"
      #sheets: ["indicators"]
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标正名"
      unwrap: true #false
      #refining: ({json}) ->
      #  # 维度指标
      #  json.dimensions = DimensionIndicatorSingleton.rebuild({indicators:json.indicators})
      #  return json
    }

  @fromExcel: ->
    @indicators = JU.jsonizedExcelData(@options())





# 各维度,及指标
class DimensionIndicatorSingleton
  
  # 从指标-维度 JSON 产生维度-指标 JSON
  @rebuild: (funcOpts) ->
    {indicators=IndicatorDimensionSingleton.singleJSON()} = funcOpts
    # 维度指标
    @dimensions = {} 
    for key, value of indicators
      (@dimensions[value] ?= []).push(key)
    return @dimensions
    




module.exports = {
  IndicatorDimensionSingleton
  DimensionIndicatorSingleton
}
