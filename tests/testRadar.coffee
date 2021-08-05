fs = require 'fs'
path = require 'path'
pptxgen = require 'pptxgenjs'
#xlsx = require 'json-as-xlsx'
# use __dirname and __filename to create correct full path filename
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'



funcOpts = {
  basename: "jsszyy"
  headerRows: 1
  sheetStubs: true
  needToRewrite: false #true
  mainKeyName: "科室名"
}
    
json = JU.jsonizedExcelData(funcOpts)

console.log json