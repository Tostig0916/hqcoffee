{IndicatorDef, IndicatorDefVersion} = require './indicatorDef'
ju = require './jsonUtils'

year=2020
basename = "indef#{year}"
dictionary = IndicatorDef.fromMannualFile({p: __dirname, basename})
arr = (v.description() for k, v of dictionary)

kpj = 0
jc = 0
for each in arr
  kpj++ if /可评价:true/.test each
  jc++ if /监测:true/.test each

basename = "#{basename}Dict"
ju.write2JSON({p:__dirname, basename, obj: dictionary})
console.log "共#{IndicatorDefVersion.versionCount()}个版本，#{arr.length}个指标，其中#{kpj}个可评价指标, #{jc}个国家监测指标"
