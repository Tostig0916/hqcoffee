{Indicator, IndicatorValue} = require './indicator'
#{IndicatorDef, IndicatorDefVersion} = require './indicatorDef'
ju = require './jsonUtils'


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
  when 1 
    {
      basename: "基本信息表"
      headerRows: 1
      sheetStubs: true
    }
histdata = Indicator.fromDataTable(funcOpts)
{basename} = funcOpts
Indicator.saveToJSONFile({p:__dirname, basename:"#{basename}Hist", obj:histdata.records})
# console.log histdata.description(), 
console.log histdata.yearsSorted((a,b) -> a - b)


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