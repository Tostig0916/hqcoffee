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
		{p=__dirname, baseName, headerRows=1,sheetStubs=true} = funcOpts
		# read from mannual file and turn it into a dictionary
		
		excelfileName = path.join p, "#{baseName}.xlsx"
		jsonfilename = path.join p, "#{baseName}.json"

		needToRewrite = false 
		if needToRewrite or not fs.existsSync jsonfilename
			readOpts =
				sourceFile: excelfileName
				sheetStubs: sheetStubs
				header: {rows: headerRows}
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

	@checkForHeaders: (funcOpts) ->
		{rows} = funcOpts
		headers = (key for key, value of rows[0])
		unless "指标名称" in headers or "项目" in headers 
			throw new Error("缺少指标名称项") 


	# 去掉名实两边空格
	@deleteSpacesOnBothSide: (funcOpts) ->
		{rowObj} = funcOpts
		for key, value of rowObj when (typeof value is 'string') or (value instanceof String)
			rowObj[key.replace(/\s+/g,'')] = value.replace(/\s+/g,'')
	


	# 针对有些报表填报时,将表头"指标名称"改成了其他表述,在此清理
	@correctKeyName: (funcOpts) -> 
		{rowObj} = funcOpts
		if rowObj.项目? and not rowObj.指标名称?
			rowObj.指标名称 = rowObj.项目
			# delete rowObj.项目
		

	@readFromExcel: (funcOpts) ->
		# console.log e2j 
		source = e2j funcOpts
		objOfSheets = {}
		for shnm, rows of source
			JSONUtils.checkForHeaders({rows})
			# 去掉空格
			sheetName = shnm.replace(/\s+/g,'')
			objOfSheets[sheetName] = {}
			for rowObj in rows
				JSONUtils.deleteSpacesOnBothSide({rowObj})
				# 针对有些报表填报时,将表头"指标名称"改成了其他表述,在此清理
				JSONUtils.correctKeyName({rowObj})
				{指标名称} = rowObj
				if 指标名称? and 指标名称 isnt "undefined"
					objOfSheets[sheetName][指标名称] = rowObj
				else
					console.log("清除废数据行", rowObj)
		return objOfSheets 




	@write2JSON: (funcOpts) ->
		{jsonfilename, json} = funcOpts
		jsonContent = JSON.stringify(json)

		fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
			if err? 
				console.log(err)
			else
				console.log "#{path.basename(jsonfilename)} saved at #{Date()}"



	


	


module.exports = JSONUtils
