fs = require 'fs'

path = require 'path'
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'


# use __dirname and __filename to create correct full path filename
{IndicatorDef, IndicatorDefInfoByVersion} = require path.join __dirname, '..','toJSON', 'indicatorDef'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


arrayOfDefs = (funcOpts) ->
  {year=2020} = funcOpts
  funcOpts = {
    basename: "indef#{year}"
    folder: 'data'
    needToRewrite: true
  }
  dictionary = IndicatorDef.fromMannualFile(funcOpts)
  #arr = (v for k, v of dictionary)
  arr = (v.description() for k, v of dictionary)

  #console.log arr

  vector = 0
  jc = 0


  for each in arr
    vector++ if /矢量:true/.test each
    jc++ if /监测:true/.test each

  #console.log IndicatorDefInfoByVersion.versionArray() #JSON.stringify(IndicatorDefInfoByVersion.versions)
  console.log "共#{IndicatorDefInfoByVersion.versionCount()}个版本，#{arr.length}个指标，其中#{vector}个可评价指标, #{jc}个国家监测指标"
  return {arr, dictionary}


module.exports = arrayOfDefs



funcOpts = {year:2020}
{arr} = arrayOfDefs(funcOpts)  
funcOpts.arr = arr


createExcel = (funcOpts) ->
  return "not done yet"

  excelfileName = JU.getExcelFilename(funcOpts)
  {arr,needToRewrite} = funcOpts
  unless fs.existsSync(excelfileName) or needToRewrite
    data = [
      {
        sheet: "国考指标体系"
        columns: [
          {label: "指标名称", value:"指标名称"}

        ]
        content: arr
      }
    ]


createExcel(funcOpts)


