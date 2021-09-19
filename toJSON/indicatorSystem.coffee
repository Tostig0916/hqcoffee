JU = require './jsonUtils'

# 此表为 singleton,只有一个instance,故可使用 class 一侧定义
# 指标维度表
class SingletonIndicatorDimension
  @fromExcel: ->
    funcOpts = {
      basename: "指标维度表"
      #sheets: ["indicators"]
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标正名"
      unwrap: true #false
      #refining: ({json}) ->
      #  # 维度指标
      #  json.dimensions = SingletonDimensionIndicator.rebuild({indicators:json.indicators})
      #  return json
    }

    JU.jsonizedExcelData(funcOpts)



# 各维度,及指标
class SingletonDimensionIndicator
  
  # 从指标-维度 JSON 产生维度-指标 JSON
  @rebuild: (funcOpts) ->
    {indicators} = funcOpts
    # 维度指标
    @dimensions = {} 
    for key, value of indicators
      (@dimensions[value] ?= []).push(key)
    return @dimensions
    




module.exports = {
  SingletonIndicatorDimension
  SingletonDimensionIndicator
}
