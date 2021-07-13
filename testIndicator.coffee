{Indicator, IndicatorValue} = require './indicator'
IndicatorInfo = require './indicatorInfo'

dictionary = IndicatorInfo.fromMannualFile({p:__dirname})
console.log ([k, ("指标:#{each.versionName}, 序号:#{each.序号}, 监测:#{each.测}" for each in v.versions) ] for k, v of dictionary)

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