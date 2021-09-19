JU = require './jsonUtils'

class IndicatorDimension
  @convert: ->
    funcOpts = {
      basename: "指标维度表"
      #sheets: ["Sheet1"]
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标正名"
      unwrap: true #false
    }

    JU.jsonizedExcelData(funcOpts)



module.exports = {
  IndicatorDimension
}
