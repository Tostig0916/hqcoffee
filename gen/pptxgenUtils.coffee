fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path' 

pptxgen = require 'pptxgenjs'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'



class PPTXGenUtils


	@getPPTFilename: (funcOpts) ->
		funcOpts.gen = "pptxgen"
		JU.getPPTFilename(funcOpts)



	@createPPT = (funcOpts) ->
		{json} = funcOpts
		pptname = @getPPTFilename(funcOpts)
		if fs.existsSync pptname
			pres = new pptxgen()
			slide = pres.addSlide("TITLE_SLIDE")

			for key, obj of json.雷达图
				slide = pres.addSlide()

				#slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
				#slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
				#slide.background = { path: "https://some.url/image.jpg" }  # image: url

				#slide.color = "696969"  # Set slide default font color

				# EX: Styled Slide Numbers
				slide.slideNumber = { x: "90%", y: "90%", fontFace: "Courier", fontSize: 15, color: "FF33FF" }
				dataChartAreaLine = [
					{
						name: key
						labels: ((if k.length < 7 then k else k[0..5] + k[-1..]) for k, v of obj when k isnt '科室名')[0..11]
						values: (v for k, v of obj when k isnt '科室名')[0..11]
					}
				]
					

				slide.addChart(pres.ChartType.radar, dataChartAreaLine, { 
					x: 0.1, y: 0.1, 
					w: "95%", h: "90%"
					showLegend: true, legendPos: 'b'
					#showTitle: true, title: obj.科室名 
				})
				
			
			###
			#// For simple cases, you can omit `then`
			pres.writeFile({ fileName: pptname})
			###
			#// Using Promise to determine when the file has actually completed generating
			pres.writeFile({ fileName: pptname })
					.then((fileName) -> 
							console.log("created file:#{path.basename fileName} at #{Date()}")
					)



	###
	# 单纯将Excel文件转化为JSON文件,而不引入classes
	@jsonizedExcelData: (funcOpts) ->
		# type could be zh 综合, zy 中医,etc
		{folder='data', basename, headerRows=1, sheetStubs=true} = funcOpts
		# read from mannual file and turn it into a dictionary
		excelfileName = @getExcelFilename(funcOpts)
		
		# 由于是使用简单的JSON object 故除非解析规则改变否则无须重读,
		# 但是为防止后续设计改变,亦可每次皆重读
		{jsonfilename, isReady} = @jsonfileNeedsNoFix(funcOpts)
		unless isReady
			readOpts =
				sourceFile: excelfileName
				sheetStubs: sheetStubs
				header: {rows: headerRows}
				#sheets: ['Sheet 1']
				columnToKey: {'*':'{{columnHeader}}'}
				# 这一属性是我加的
				mainKeyName: "指标名称"
				
			try
				# 是简单的JSON object
				obj = @readFromExcel(readOpts)
				funcOpts.obj = obj
				@write2JSON(funcOpts)

			catch error
				console.log error
			
		else
			# 原本就是JSON object 所以直接读取即可
			obj = @readFromJSON({jsonfilename})

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
			@checkForHeaders({mainKeyName,rows})
			# 去掉空格
			sheetName = shnm.replace(/\s+/g,'')
			objOfSheets[sheetName] = {}
			for rowObj in rows
				@deleteSpacesOnBothSide({rowObj})
				# 针对有些报表填报时,将表头"指标名称"改成了其他表述,在此清理
				@correctKeyName({rowObj})
				mainKey = rowObj[mainKeyName]
				if mainKey? and not /^(undefined|栏次)$/i.test(mainKey) #isnt "undefined"
					objOfSheets[sheetName][mainKey] = rowObj
				else
					console.log("清除废数据行", rowObj)
		return objOfSheets 



	@getJSONFilename: (funcOpts) ->
		{p=__dirname,folder='data', basename} = funcOpts		
		path.join(p, folder, "JSON", "#{basename}.json")



	@getExcelFilename: (funcOpts) ->
		{p=__dirname,folder='data', basename, headerRows=1, sheetStubs=true} = funcOpts
		path.join(p,folder,'Excel', "#{basename}.xlsx")



	@getPPTFilename: (funcOpts) ->
		{p=__dirname,folder='ppt', basename, gen=""} = funcOpts
		# 顺便检查有无目录,没有在新建		
		ff = path.join(p, folder) 
		fs.mkdirSync ff unless fs.existsSync ff
		# 生成文件路径名		
		path.join(p, folder, "#{basename}#{gen}.pptx")



	@jsonfileNeedsNoFix: (funcOpts) ->
		{p=__dirname,folder='data', basename, needToRewrite} = funcOpts

		ff = path.join(p, folder, "JSON") 
		fs.mkdirSync ff unless fs.existsSync ff 
		jsonfilename = @getJSONFilename(funcOpts)
		
		if isReady = fs.existsSync(jsonfilename) and not needToRewrite
			console.log "已有文件: #{jsonfilename}"
			
		{jsonfilename, isReady}




	# 除非简单的JSON objects 否则JSON文件的作用只是用于查看是否有问题,重写与否都无所谓
	@write2JSON: (funcOpts) ->
		{jsonfilename, isReady} = @jsonfileNeedsNoFix(funcOpts)
		unless isReady
			#jsonfilename = @getJSONFilename(funcOpts)
			{obj} = funcOpts		
			jsonContent = JSON.stringify(obj)
			fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
				if err? 
					console.log(err)
				else
					console.log "#{path.basename(jsonfilename)} saved at #{Date()}"




	

	@readFromJSON: (funcOpts) ->
		{p=__dirname, folder, basename, jsonfilename} = funcOpts
		
		filename = jsonfilename ? path.join(p, folder, "JSON", "#{basename}.json")
		console.log "读取: ", filename
		obj = require filename
		return obj
###	





module.exports = PPTXGenUtils
