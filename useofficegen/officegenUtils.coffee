fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path' 
officegen = require 'officegen'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


# there's some bug in this package, give up
# https://github.com/Ziv-Barber/officegen/blob/master/manual/pptx/README.md

class OfficeGenUtils


	@getPPTFilename: (funcOpts) ->
		# 未来便于测试对比其他的库，在文件名中加上使用的PPT生成库名
		funcOpts.gen = "og" #"officegen"
		JU.getPPTFilename(funcOpts)
		


	# 所需使用的数据可由JSON提供，在参数中传递至此
	@createPPT: (funcOpts) ->
		pptname = @getPPTFilename(funcOpts)

		@pptx = officegen {
			type:'pptx'
			#themXml: ''
		}

		#@test()
		@testChart()
		
		#// Let's generate the PowerPoint document into a file:

		new Promise (resolve, reject) => 

			out = fs.createWriteStream(pptname)

			#// This one catch only the officegen errors:
			@pptx.on('error', reject)

			#// Catch fs errors:
			out.on('error', reject)

			#// End event after creating the PowerPoint file:
			out.on('close', resolve)

			#// This async method is working like a pipe - it'll generate the pptx data and put it into the output stream:
			console.log "generating #{pptname}"
			@pptx.generate(out)
		




	@testChart: ->
		#// Create a new PPTX file
		#// Create a new slide
		slide = @pptx.makeTitleSlide('FileFormat', 'FileFormat Developer Guide')
		#// Creata a new column chart
		slide = @pptx.makeNewSlide()
		slide.name = 'Chart slide'
		slide.back = 'ffffff'

		slide.addChart  
			title: 'Column chart',
			renderType: 'pie' #'bar', #'column',
			valAxisTitle: 'Costs/Revenues ($)',
			catAxisTitle: 'Category',
			valAxisNumFmt: '$0',
			valAxisMaxValue: 24,
			data: [
				{
					name: 'Income',
					labels: ['2005', '2006', '2007', '2008', '2009'],
					values: [23.5, 26.2, 30.1, 29.5, 24.6]
				},
				{
					name: 'Income',
					labels: ['2005', '2006', '2007', '2008', '2009'],
					values: [23.5, 26.2, 30.1, 29.5, 24.6]
				}
			]  
			###
			[ #// each item is one serie
				{
					name: 'Income',
					labels: ['2005', '2006', '2007', '2008', '2009'],
					values: [23.5, 26.2, 30.1, 29.5, 24.6],
					color: 'ff0000' #// optional
				},
				{
					name: 'Expense',
					labels: ['2005', '2006', '2007', '2008', '2009'],
					values: [18.1, 22.8, 23.9, 25.1, 25],
					color: '00ff00' #// optional
				}
			]
			###

		
		#// Set save path
		#out = fs.createWriteStream('Chart.pptx')
		#// Save
		#pptx.generate(out)





	@test: ->
		
		slide = @pptx.makeNewSlide {
			userLayout: 'title'
		}

		#// Change the background color:
		slide.back = '000000'

		#// Declare the default color to use on this slide (default is black):
		slide.color = 'ffffff'

		#// Basic way to add text string:
		slide.addText('This is a test')
		slide.addText('Fast position', 0, 20)
		slide.addText('Full line', 0, 40, '100%', 20)

		#// Add text box with multi colors and fonts:
		slide.addText([
			{text: 'Hello ', options: {font_size: 56}},
			{text: 'World!', options: {font_size: 56, font_face: 'Arial', color: 'ffff00'}}
			], {cx: '75%', cy: 66, y: 150})
		#// Please note that you can pass object as the text parameter to addText.

		slide.addText('Office generator', {
			y: 66, x: 'c', cx: '50%', cy: 60, font_size: 48,
			color: '0000ff' } )

		slide.addText('Big Red', {
			y: 250, x: 10, cx: '70%',
			font_face: 'Wide Latin', font_size: 54,
			color: 'cc0000', bold: true, underline: true } )




	constructor: ->
		###
		@pptx = officegen {
			type:'pptx'
			#themXml: ''
		}
		###







module.exports = OfficeGenUtils




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




