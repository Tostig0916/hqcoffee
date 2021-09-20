e2j = require 'convert-excel-to-json'
fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path' 
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'
StormDB = require 'stormdb'


class JSONSimple  # with no dependences to stormdb
	
	# 给定文件名,其数据源Excel和转换成的JSON文件同名,故不存在歧义,可以此法一以蔽之
	@getJSON: (funcOpts={}) ->
		# 由于是使用简单的JSON object 故除非解析规则改变否则无须重读,
		# 但是为防止后续设计改变,亦可每次皆重读
		{jsonfilename, isReady} = @jsonfileNeedsNoFix(funcOpts)
		if isReady
			# 原本就是JSON object 所以直接读取即可
			obj = @readFromJSON({jsonfilename})
		else
			@jsonizedExcelData(funcOpts)





	# 单纯将Excel文件转化为JSON文件,而不引入classes
	@jsonizedExcelData: (funcOpts={}) ->
		# type could be zh 综合, zy 中医,etc
		{headerRows=1, sheets} = funcOpts
		# read from mannual file and turn it into a dictionary
		readOpts = funcOpts
		readOpts.sourceFile ?= @getExcelFilename(funcOpts)
		readOpts.header ?= {rows: headerRows}
		readOpts.columnToKey ?= {'*':'{{columnHeader}}'}
		if sheets? then readOpts.sheets = sheets

		try
			# JSON object
			obj = @readFromExcel(readOpts)							
			funcOpts.obj = obj
			@write2JSON(funcOpts)

		catch error
			console.log error
		return obj





	@checkForHeaders: (funcOpts={}) ->
		{mainKeyName,rows} = funcOpts
		headers = (key for key, value of rows[0])
		#console.log headers 
		unless (headers.length is 0) or (mainKeyName in headers) or ("项目" in headers) 
			throw new Error("缺少指标名称项") 




	# 去掉名实两边空格
	@deleteSpacesOnBothSide: (funcOpts={}) ->
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
	@correctKeyName: (funcOpts={}) -> 
		{rowObj} = funcOpts
		if rowObj.项目? and not rowObj.指标名称?
			rowObj.指标名称 = rowObj.项目
			delete rowObj.项目
		



	@readFromExcel: (funcOpts={}) ->
		source = e2j(funcOpts)
		objOfSheets = {}
		
		# 设置主键名,一般可作为第一列字段名,后面的字段看成是改名称object的属性
		# key、value 一对生成简单字典型的JSON，unwrap参数设置为true
		{mainKeyName="指标名称", unwrap=false,refining} = funcOpts

		# 每sheet
		for shnm, rows of source
			@checkForHeaders({mainKeyName,rows})
			# 去掉空格
			sheetName = shnm.replace(/\s+/g,'')
			objOfSheets[sheetName] = {}
			
			# 每行
			for rowObj in rows
				@deleteSpacesOnBothSide({rowObj})
				# 针对有些报表填报时,将表头"指标名称"改成了其他表述,在此清理
				@correctKeyName({rowObj})
				mainKey = rowObj[mainKeyName]

				switch
					when (not mainKey?) or /^(undefined|栏次)$/i.test(mainKey)
						console.log("清除废数据行", rowObj)
					
					#when /指标/.test(mainKeyName) and /[、]/i.test(mainKey)
					#	console.log("清除废数据行", rowObj)

					else
						if refining?
							mainKey = refining({mainKey})
							rowObj[mainKeyName] = mainKey
						
						switch #isnt "undefined"
							# 拆解方式仅适用于只有两个column情形
							when unwrap
								# 对于只有两个column的简单表格，可以生成简单的JSON
								rowVals = (rv for rk, rv of rowObj)
								{length} = rowVals
								#console.log {length}
								switch
									when length is 2 
										objOfSheets[sheetName][mainKey] = rowVals[1]
										#console.log {mainKey, value:rowVals[1]}
									else
										objOfSheets[sheetName][mainKey] = rowObj
							else
								objOfSheets[sheetName][mainKey] = rowObj


		# 如果经过以上处理之后，仍只有一个键就解开
		keys = (key for key, value of objOfSheets)
		if unwrap and (keys.length is 1)
			objOfSheets = objOfSheets[keys[0]]
				
		return objOfSheets 



	@getJSONFilename: (funcOpts={}) ->
		{dirname=__dirname,folder='data', basename} = funcOpts		
		path.join(dirname, '..', folder, "JSON", "#{basename}.json")


	
	@getExcelFilename: (funcOpts={}) ->
		{dirname=__dirname,outfolder,folder='data', basename, basenameOnly, headerRows=1, sheetStubs=true} = funcOpts
		fd = outfolder ? folder
		ff = path.join(dirname, '..', fd) 
		fs.mkdirSync ff unless fs.existsSync ff
		ff = path.join(dirname, '..', fd, 'Excel') 
		fs.mkdirSync ff unless fs.existsSync ff
		path.join(dirname, '..', outfolder ? folder,'Excel', if basenameOnly then basename else "#{basename}.xlsx")



	@getPPTFilename: (funcOpts={}) ->
		{dirname=__dirname,folder='outputs', basename, gen=""} = funcOpts
		# 顺便检查有无目录,没有在新建		
		ff = path.join(dirname, '..', folder) 
		fs.mkdirSync ff unless fs.existsSync ff
		ff = path.join(dirname, '..', folder, 'PPT') 
		fs.mkdirSync ff unless fs.existsSync ff

		# 生成文件路径名		
		path.join(dirname, '..', folder,'PPT', "#{basename}.#{gen}.pptx")



	@jsonfileNeedsNoFix: (funcOpts={}) ->
		{dirname=__dirname,folder='data', basename, needToRewrite=false} = funcOpts

		ff = path.join(dirname, '..', folder, "JSON") 
		fs.mkdirSync ff unless fs.existsSync ff 
		jsonfilename = @getJSONFilename(funcOpts)
		
		if isReady = fs.existsSync(jsonfilename) and not needToRewrite
			console.log "已有文件: #{jsonfilename}"
			
		{jsonfilename, isReady}





	# 指标定义详情比较表
	@write2Excel: (funcOpts={}) ->
		{isReady} = @jsonfileNeedsNoFix(funcOpts)
		unless isReady
			{data,settings} = funcOpts
			funcOpts.basenameOnly = true
			funcOpts.outfolder = "outputs"
			ff = @getExcelFilename(funcOpts)
			settings.fileName = ff
			xlsx(data, settings)
			console.log path.basename(settings.fileName), "saved at #{new Date()}"





	# 除非简单的JSON objects 否则JSON文件的作用只是用于查看是否有问题,重写与否都无所谓
	@write2JSON: (funcOpts={}) ->
		{obj} = funcOpts		

		{jsonfilename, isReady} = @jsonfileNeedsNoFix(funcOpts)
		unless isReady			
			jsonContent = JSON.stringify(obj)
			fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
				if err? 
					console.log(err)
				else
					console.log "#{path.basename(jsonfilename)} saved at #{Date()}"




	

	@readFromJSON: (funcOpts={}) ->
		{dirname=__dirname, folder, basename, jsonfilename} = funcOpts
		
		filename = jsonfilename ? @getJSONFilename(funcOpts) #path.join(dirname, '..', folder, "JSON", "#{basename}.json")
		console.log "读取: ", filename
		obj = require filename
		return obj
	



# use stormdb
class JSONDatabase extends JSONSimple

	@getDBFilename: (funcOpts={}) ->
		{dirname,folder='data', basename} = funcOpts
		if dirname?
			path.json(dirname, "db.json")
		else	
			path.join(__dirname, '..', folder, "db.json")





class JSONUtils extends JSONDatabase







module.exports = {
	JSONUtils
}
