path = require 'path'
{IndicatorDef, IndicatorDefVersion} = require path.join __dirname, '../indicatorDef'
ju = require path.join __dirname, '../jsonUtils'

year=2020
funcOpts = {
  basename: "indef#{year}"
  folder: 'data'
  needToRewrite: true
}
dictionary = IndicatorDef.fromMannualFile(funcOpts)
arr = (v.description() for k, v of dictionary)

kpj = 0
jc = 0
for each in arr
  kpj++ if /可评价:true/.test each
  jc++ if /监测:true/.test each

console.log "共#{IndicatorDefVersion.versionCount()}个版本，#{arr.length}个指标，其中#{kpj}个可评价指标, #{jc}个国家监测指标"
