path = require 'path'
{Indicator} = require path.join __dirname,  '..', 'toJSON', 'indicator'
#ju = require path.join __dirname, '../jsonUtils'



testit = (file) ->
  funcOpts = switch file
    when 0
      {
        basename: "国考填报表"
        headerRows: 1
        sheetStubs: true
        needToRewrite: false #true
      }
    when 1 
      {
        basename: "二级国考指标填报表"
        headerRows: 3
        sheetStubs: false
        needToRewrite: false #true
      }
    when 2 
      {
        basename: "基本信息表"
        headerRows: 1
        sheetStubs: true
        needToRewrite: false #true
      }
  
  histdata = Indicator.fromJSONData(funcOpts)
  console.log funcOpts.basename, histdata.years, histdata.units
  #console.log histdata.yearsSorted((a,b) -> a - b), histdata.unitsSorted()



testit(file) for file in [1..2]
