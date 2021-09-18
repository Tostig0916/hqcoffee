JU = require './jsonUtils'

class IndicatorDimension
  @convert: ->
    funcOpts = {
      basename: "指标维度表"
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标正名"
      simplest: false
    }

    JU.jsonizedExcelData(funcOpts)



module.exports = {
  IndicatorDimension
}
