e2j = require 'convert-excel-to-json'
fs = require 'fs'
path = require 'path'
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'


class IndicatorInfo
  @fromMannualFile: (funcOpts) ->
    # type could be zh 综合, zy 中医,etc
    {p='./', type='zh', grade=2, version=2020} = funcOpts
    # read from mannual file and turn it into a dictionary
    baseName = "indinfo#{grade}#{type}#{version}"
    excelfileName = path.join p, "#{baseName}.xlsx"
    jsonfilename = path.join p, "#{baseName}.json"
    readOpts =
      sourceFile: excelfileName
      header: {rows: 1}
      #sheets: ['Sheet 1']
      columnToKey: {
        '*':'{{columnHeader}}'
      }
    json = IndicatorInfo.readFromExcel(readOpts)
    IndicatorInfo.write2JSON({jsonfilename,result:json})
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
    {@name, @source, @guidance} = funcOpts





module.exports = IndicatorInfo
