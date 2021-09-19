JU = require './jsonUtils'



class AnySingleton
  @showSingleJSON: (rebuild=false) ->
    funcOpts = @options()
    if rebuild
      funcOpts.needToRewrite = true
      @_json = JU.singleJSON(funcOpts)
    else
      @_json ?= JU.singleJSON(funcOpts)





# 别名正名对照及转换
class CommonNameSingleton extends AnySingleton
  @options: ->
    {
      folder: 'data'
      basename: '别名表'
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标名称"
      unwrap: true #false 
    }





# 此表为 singleton,只有一个instance,故可使用 class 一侧定义
# 指标维度表
class IndicatorDimensionSingleton extends AnySingleton
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
      #  json.dimensions = DimensionIndicatorSingleton.abstract({indicators:json.indicators})
      #  return json
    }






# 各维度,及指标
class DimensionIndicatorSingleton extends AnySingleton
  
  # 从指标-维度 JSON 产生维度-指标 JSON
  @abstract: (funcOpts) ->
    {indicators=IndicatorDimensionSingleton.showSingleJSON()} = funcOpts
    # 维度指标
    dimensions = {} 
    for key, value of indicators
      (dimensions[value] ?= []).push(key)
    return @_json = dimensions
    




module.exports = {
  IndicatorDimensionSingleton
  DimensionIndicatorSingleton
}
