path = require 'path'
{MakePPTReport} = require path.join __dirname, '..','usepptxgen', 'pptxgenUtils'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


# 从数据表读取数据,再生成报告用的JSON
funcOpts = {
  basename: "jsszyy"
  headerRows: 1
  sheetStubs: true
  needToRewrite: false
  mainKeyName: "科室名"
}

json = JU.jsonizedExcelData(funcOpts)

jsonReport = {
  section1: {
    settings:{
      chartType:"radar"
    }
    data: json["雷达图"]
  }
}


funcOpts.json = jsonReport
funcOpts.needToRewrite = true

#console.log funcOpts, MakePPTReport

MakePPTReport.newReport(funcOpts)