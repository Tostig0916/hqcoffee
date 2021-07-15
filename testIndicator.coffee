{Indicator, IndicatorValue} = require './indicator'
{IndicatorDef, IndicatorDefVersion} = require './indicatorDef'

file = 1
funcOpts = switch file
  when 0
    {
      baseName: "国考填报表"
      headerRows: 1
      sheetStubs: true
    }
  when 1 
    {
      baseName: "二级国考指标填报表"
      headerRows: 3
      sheetStubs: false
    }
  when 2
    {
      baseName: "基本信息表"
      headerRows: 1
      sheetStubs: true
    }

histdata = Indicator.fromDataTable(funcOpts)
#console.log histdata.description(), histdata.yearsSorted((a,b) -> a - b)


###
value = new IndicatorValue({
  date: 2020
  number: 32.47
})
#console.log value

出院患者手术占比 = new Indicator({
  name: '出院患者手术占比'
  indicatorUnit: '%'
  indicatorValue: value
})


console.log 出院患者手术占比
###