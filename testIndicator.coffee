{Indicator, IndicatorValue} = require './indicator'
IndicatorInfo = require './indicatorInfo'

dictionary = IndicatorInfo.fromMannualFile({p:__dirname})
arr = (v.description() for k, v of dictionary)
console.log arr, arr.length

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