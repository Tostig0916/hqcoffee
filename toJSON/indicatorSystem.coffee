JU = require './jsonUtils'

# 此表为 singleton,只有一个instance,故可使用 class 一侧定义
# 指标维度表
class IndicatorDimension
  @fromExcel: ->
    funcOpts = {
      basename: "指标维度表"
      #sheets: ["indicators"]
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标正名"
      unwrap: true #false
      refining: ({json}) ->
        # 维度指标
        dimensions = {} 
        for key, value of json.indicators
          (dimensions[value] ?= []).push(key)
        #console.log {dimensions}
        json.dimensions = dimensions
        return json
    }

    JU.jsonizedExcelData(funcOpts)



module.exports = {
  IndicatorDimension
}
