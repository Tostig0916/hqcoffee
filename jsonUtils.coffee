e2j = require 'convert-excel-to-json'
fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path' 
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'


class JSONUtils
  
	# 将Excel文件转化为JSON文件
	@jsonizedData: (funcOpts) ->
		# type could be zh 综合, zy 中医,etc
		{p=__dirname, baseName} = funcOpts
		# read from mannual file and turn it into a dictionary
		
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
			json = JSONUtils.readFromExcel(readOpts)
			JSONUtils.write2JSON({jsonfilename,json})
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
				objk = obj.指标名称
				result[k][objk] = obj
		return result 


	@write2JSON: (funcOpts) ->
		{jsonfilename, json} = funcOpts
		jsonContent = JSON.stringify(json)

		fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
			if err? 
				console.log(err)
			else
				console.log "JSON file saved at #{Date()}"



	


	


module.exports = JSONUtils
