{Indicator, IndicatorValue} = require './indicator'
{IndicatorDef, IndicatorDefVersion} = require './indicatorDef'

baseName = "国考填报表"
#baseName = "基本信息表"
histdata = Indicator.fromDataTable({p: __dirname, baseName})
console.log histdata.description()


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