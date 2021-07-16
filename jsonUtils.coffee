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
		{p=__dirname, basename, headerRows=1,sheetStubs=true} = funcOpts
		# read from mannual file and turn it into a dictionary
		
		excelfileName = path.join(p, "#{basename}.xlsx")
		jsonfilename = path.join(p, "#{basename}.json")

		needToRewrite = true #false 
		if needToRewrite or not fs.existsSync jsonfilename
			readOpts =
				sourceFile: excelfileName
				sheetStubs: sheetStubs
				header: {rows: headerRows}
				#sheets: ['Sheet 1']
				columnToKey: {
					'*':'{{columnHeader}}'
				}
			obj = JSONUtils.readFromExcel(readOpts)
			JSONUtils.write2JSON({p,basename,obj})
		else
			console.log "read from", jsonfilename #, __filename, __dirname
			obj = require jsonfilename

		return obj

	@checkForHeaders: (funcOpts) ->
		{rows} = funcOpts
		headers = (key for key, value of rows[0])
		unless "指标名称" in headers or "项目" in headers 
			throw new Error("缺少指标名称项") 

	@deleteSpacesOnBothSide: (funcOpts) ->
		{rowObj} = funcOpts
		for key, value of rowObj when (typeof value is 'string') or (value instanceof String)
			rowObj[key.replace(/\s+/g,'')] = value.replace(/\s+/g,'')
				



	@readFromExcel: (funcOpts) ->
		# console.log e2j 
		source = e2j funcOpts
		objOfSheets = {}
		for shnm, rows of source
			JSONUtils.checkForHeaders({rows})
			
			# 去掉空格
			sheetName = shnm.replace(/\s+/g,'')
			# console.log(sheetName) if sheetName is "统计指标"
			
			objOfSheets[sheetName] = {}
			for rowObj in rows
				# 去掉空格
				JSONUtils.deleteSpacesOnBothSide({rowObj})
				
				# 针对有些报表填报时,将表头"指标名称"改成了其他表述,在此清理
				if rowObj.项目? and not rowObj.指标名称?
					rowObj.指标名称 = rowObj.项目
					delete rowObj.项目
				
				objk = rowObj.指标名称
				objOfSheets[sheetName][objk] = rowObj
		return objOfSheets 





	@write2JSON: (funcOpts) ->
		{p=__dirname, basename, obj} = funcOpts
		jsonContent = JSON.stringify(obj)
		jsonfilename = path.join(p, "#{basename}.json")
		fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
			if err? 
				console.log(err)
			else
				console.log "#{path.basename(jsonfilename)} saved at #{Date()}"



	


	


module.exports = JSONUtils
