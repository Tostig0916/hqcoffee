e2j = require 'convert-excel-to-json'
fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path' 
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'


class JSONUtils
  
	# 将Excel文件转化为JSON文件
	@jsonizedExcelData: (funcOpts) ->
		# type could be zh 综合, zy 中医,etc
		{folder='data', basename, headerRows=1,sheetStubs=true} = funcOpts
		# read from mannual file and turn it into a dictionary
		
		excelfileName = path.join(__dirname, folder, "#{basename}.xlsx")
		jsonfilename = path.join(__dirname, folder, "#{basename}.json")
		console.log({jsonfilename})
		needToRewrite = false 
		if needToRewrite or not fs.existsSync jsonfilename
			readOpts =
				sourceFile: excelfileName
				sheetStubs: sheetStubs
				header: {rows: headerRows}
				#sheets: ['Sheet 1']
				columnToKey: {'*':'{{columnHeader}}'}
				# 这一属性是我加的
				mainKeyName: "指标名称"
				
			try
				obj = JSONUtils.readFromExcel(readOpts)
				JSONUtils.write2JSON({folder,basename,obj})
			catch error
				console.log error
			
		else
			obj = JSONUtils.readFromJSON({folder,basename})

		return obj



	@checkForHeaders: (funcOpts) ->
		{mainKeyName,rows} = funcOpts
		headers = (key for key, value of rows[0])
		console.log headers 
		unless (headers.length is 0) or (mainKeyName in headers) or ("项目" in headers) 
			throw new Error("缺少指标名称项") 




	# 去掉名实两边空格
	@deleteSpacesOnBothSide: (funcOpts) ->
		{rowObj} = funcOpts
		for key, value of rowObj when (typeof value is 'string') or (value instanceof String)
			if /^[\+\-]?\d*\.?\d+(?:[Ee][\+\-]?\d+)?$/.test(value) 
				rowObj[key.replace(/\s+/g,'')] = Number(value)
			else if /\/\d+/.test(value)
				rowObj[key.replace(/\s+/g,'')] = eval(value)
				console.log("计算比值: ",value)
			else
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
		
		# 设置主键名,一般可作为第一列字段名,后面的字段看成是改名称object的属性
		{mainKeyName="指标名称"} = funcOpts

		for shnm, rows of source
			JSONUtils.checkForHeaders({mainKeyName,rows})
			# 去掉空格
			sheetName = shnm.replace(/\s+/g,'')
			objOfSheets[sheetName] = {}
			for rowObj in rows
				JSONUtils.deleteSpacesOnBothSide({rowObj})
				# 针对有些报表填报时,将表头"指标名称"改成了其他表述,在此清理
				JSONUtils.correctKeyName({rowObj})
				mainKey = rowObj[mainKeyName]
				if mainKey? and mainKey isnt "undefined"
					objOfSheets[sheetName][mainKey] = rowObj
				else
					console.log("清除废数据行", rowObj)
		return objOfSheets 





	@write2JSON: (funcOpts) ->
		{p=__dirname,folder='data', basename, obj} = funcOpts
		jsonContent = JSON.stringify(obj)
		jsonfilename = path.join(p, folder, "#{basename}.json")
		fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
			if err? 
				console.log(err)
			else
				console.log "#{path.basename(jsonfilename)} saved at #{Date()}"



	

	@readFromJSON: (funcOpts) ->
		{p=__dirname,folder,basename} = funcOpts
		jsonfilename = path.join(p, folder, "#{basename}.json")
		console.log "read from", jsonfilename
		obj = require jsonfilename
		return obj
	





module.exports = JSONUtils
