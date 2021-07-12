e2j = require 'convert-excel-to-json'
fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path'  
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'

class IndicatorVersion
  constructor: (funcOpts) ->
    {@versionName, @indicatorIndex} = funcOpts


class IndicatorInfo
  @fromMannualFile: (funcOpts) ->
    json = IndicatorInfo.jsonizedMannual(funcOpts)
    indicators = {}
    for version, mannual of json
      for key, obj of mannual 
        indicators[key] ?= new IndicatorInfo(obj)
        indicators[key].versions.push(new IndicatorVersion({versionName: version, indicatorIndex: obj.序号}))
        # console.log key, obj
    return indicators
  
  
  
  @seperatedFromMannualFile: (funcOpts) ->
    json = IndicatorInfo.jsonizedMannual(funcOpts)
    indicators = {}
    for version, mannual of json
      indicators[version] = {}
      for key, obj of mannual 
        instance = new IndicatorInfo(obj)
        indicators[version][key] = instance
        # console.log key, obj
    return indicators

  @jsonizedMannual: (funcOpts) ->
    # type could be zh 综合, zy 中医,etc
    {p=__dirname, type='zh', grade=2, version=2020} = funcOpts
    # read from mannual file and turn it into a dictionary
    baseName = "indinfo#{grade}#{type}#{version}"
    excelfileName = path.join p, "#{baseName}.xlsx"
    jsonfilename = path.join p, "#{baseName}.json"

    needToRewrite = false    
    if needToRewrite or not fs.existsSync jsonfilename
      readOpts =
        sourceFile: excelfileName
        header: {rows: 1}
        #sheets: ['Sheet 1']
        columnToKey: {
          '*':'{{columnHeader}}'
        }
      json = IndicatorInfo.readFromExcel(readOpts)
      IndicatorInfo.write2JSON({jsonfilename,result:json})
    else
      console.log "read from", jsonfilename #, __filename, __dirname
      json = require jsonfilename

    return json


  @readFromExcel: (funcOpts) ->
    # console.log e2j 
    source = e2j funcOpts
    result = {}
    for key, arr of source
      k = key.replace(/\s+/g,'')
      result[k] = {}
      for obj in arr
        # (typeof myVar === 'string' || myVar instanceof String)
        for innerkey, innervalue of obj when (typeof innervalue is 'string') or (innervalue instanceof String)
          obj[innerkey] = innervalue.replace(/\s+/g,'')
        objk = obj.指标名称 #.replace(/\s+/g,'')
        result[k][objk] = obj
    return result 


  @write2JSON: (funcOpts) ->
    {jsonfilename, result} = funcOpts
    jsonContent = JSON.stringify(result)

    fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
      if err? 
        console.log(err)
      else
        console.log "json saved at #{Date()}"



  constructor: (funcOpts) ->
    {@指标名称, @指标来源, @指标导向} = funcOpts
    #[@name, @source, @guidance] = [@指标名称, @指标来源, @指标导向]
    @versions = []


  
  isValuable: ->
    /逐步/.test(@指标导向) 


module.exports = IndicatorInfo
