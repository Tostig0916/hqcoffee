fs = require 'fs'

path = require 'path'


# use __dirname and __filename to create correct full path filename
{IndicatorDef, IndicatorDefInfoByVersion} = require path.join __dirname, '..','analyze', 'indicatorDef'


arrayOfDefs = (funcOpts) ->
  {year=2020} = funcOpts
  funcOpts = {
    basename: "indef#{year}"
    folder: 'data'
    needToRewrite: true
  }
  dictionary = IndicatorDef.fromMannualFile(funcOpts)
  arr = (v.description() for k, v of dictionary)
  return {arr, dictionary}



inspect = (funcOpts) ->
  {arr} =  arrayOfDefs(funcOpts)
  vector = 0
  jc = 0
  for each in arr
    vector++ if /矢量:true/.test each
    jc++ if /监测:true/.test each

  console.log "共#{IndicatorDefInfoByVersion.versionCount()}个版本，#{arr.length}个指标，其中#{vector}个可评价指标, #{jc}个国家监测指标"


module.exports = arrayOfDefs



inspect({year:2020})  





