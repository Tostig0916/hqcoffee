JU = require './jsonUtils'

class IndicatorDimension
  @convert: ->
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
