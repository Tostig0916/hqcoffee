path = require 'path'
{Indicator} = require path.join __dirname, '../indicator'
ju = require path.join __dirname, '../jsonUtils'


file = 1
funcOpts = switch file
  when 0
    {
      basename: "国考填报表"
      headerRows: 1
      sheetStubs: true
    }
  when 1 
    {
      basename: "二级国考指标填报表"
      headerRows: 3
      sheetStubs: false
    }
  when 2 
    {
      basename: "基本信息表"
      headerRows: 1
      sheetStubs: true
    }
histdata = Indicator.fromDataTable(funcOpts)
console.log histdata.yearsSorted((a,b) -> a - b), histdata.unitsSorted()


