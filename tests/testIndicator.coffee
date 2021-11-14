path = require 'path'
{SimpleIndicator} = require path.join __dirname,  '..', 'analyze', 'indicator'

console.log SimpleIndicator.fromJSONData  {
        basename: "二级国考指标填报表"
        #mainKeyName: "指标名称"
        headerRows: 3
        sheetStubs: false
        needToRewrite: false #true
        customData: true
      }

###
getHistdata = (selection) ->
  funcOpts = switch selection
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
  
  histdata = SimpleIndicator.fromJSONData(funcOpts)
  return {funcOpts, histdata}


module.exports = getHistdata

for selection in [1..2]
  {funcOpts,histdata} = getHistdata(selection)
  console.log funcOpts.basename, histdata.years, histdata.units
  #console.log histdata.yearsSorted((a,b) -> a - b), histdata.unitsSorted()

###