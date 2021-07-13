{Indicator, IndicatorValue} = require './indicator'
{IndicatorInfo, IndicatorVersion} = require './indicatorInfo'

dictionary = IndicatorInfo.fromMannualFile({p: __dirname, year: 2020})
arr = (v.description() for k, v of dictionary)
kpj = 0
jc = 0
for each in arr
  kpj++ if /可评价:true/.test each
  jc++ if /监测:true/.test each

console.log arr, "共#{arr.length}个指标，其中#{kpj}个可评价指标, #{jc}个国家监测指标"

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