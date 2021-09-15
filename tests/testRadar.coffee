path = require 'path'
PPTXGenUtils = require path.join __dirname, '..', 'gen', 'pptxgenUtils'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'



funcOpts = {
  basename: "jsszyy"
  #sheetName: "雷达图"
  headerRows: 1
  sheetStubs: true
  needToRewrite: false #true
  mainKeyName: "科室名"
}

sheetName = "雷达图"

json = JU.jsonizedExcelData(funcOpts)
funcOpts.json = json[sheetName]
PPTXGenUtils.createPPT(funcOpts)

