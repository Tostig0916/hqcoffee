path = require 'path'
{MakePPTReport} = require path.join __dirname, '..','usepptxgen', 'pptxgenUtils'
{JSONUtils} = require path.join __dirname, '..', 'analyze', 'jsonUtils'


# 从数据表读取数据,再生成报告用的JSON
funcOpts = {
  basename: "jsszyy"
  headerRows: 1
  sheetStubs: true
  needToRewrite: false  #true
  mainKeyName: "科室名"
}

json = JSONUtils.getJSON(funcOpts)

data = json["雷达图"]

jsonReport = {
  "专科散点图": {
    settings:{
      chartType: "bar3d" #"scatter"
    }
    data: data
  }
  "专科线图": {
    settings:{
      chartType:"line"
    }
    data
  }

  "专科雷达图": {
    settings:{
      chartType:"radar"
    }
    data
  }
}


funcOpts.json = jsonReport
funcOpts.needToRewrite = true

#console.log funcOpts, MakePPTReport

MakePPTReport.newReport(funcOpts)