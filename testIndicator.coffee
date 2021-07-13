{Indicator, IndicatorValue} = require './indicator'
{IndicatorDef, IndicatorDefVersion} = require './indicatorDef'

baseName = "建水国考填报表"
#baseName = "建水基本信息表"
dictionary = Indicator.fromDataTable({p: __dirname, baseName})
console.log dictionary


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