e2j = require 'convert-excel-to-json'
fs = require 'fs'

sourceFile = './indicator2y2020.xlsx'
jsonfilename = './indicators2y2020.json'


readToJson = (funcOpts) ->
  # console.log e2j 
  source = e2j funcOpts
  result = {}
  for key, arr of source 
    result[key] = {}
    for obj in arr
      result[key][obj.指标名称] = obj

  jsonContent = JSON.stringify(result)

  fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
    if err? 
      console.log(err)
    else
      console.log "json saved at #{Date()}", jsonContent



readOpts = {
  sourceFile:sourceFile
  header: {rows: 1}
  sheets: ['Sheet 1']
  columnToKey: {
    '*':'{{columnHeader}}'
  }
}


if fs.existsSync jsonfilename
  content = require jsonfilename
  for key, value of content
    console.log jsonfilename, key, value
else
  readToJson(readOpts)

