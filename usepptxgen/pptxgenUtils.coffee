fs = require 'fs'
# use __dirname and __filename to create correct full path filename
path = require 'path' 

pptxgen = require 'pptxgenjs'
{JSONUtils} = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


### 生成报告专用的JSON文件规格
		# slide section 对标
		
		# 医院层面指标，矢量维度雷达图，标量散点图，均含纵横两张图

		# 科室层面指标，矢量维度雷达图，标量散点图，均含纵横两张图

		# slide section 内部梳理
		
		# 矢量雷达图，可分为当年和三年纵贯

{
	"section1": {
		"settings":{

		},
		"data": {

		}
	},
	"section2": {
		"settings":{

		},
		"data":{

		}
	}
}

###

# 生成一个完整的报告使用的数据库JSON,其中按照报告的section分成几个部分
# 使用 MakePPTReport 之 generate 来生成整个报告
class MakePPTReport
	
	@newReport: (funcOpts={}) ->
		{json} = funcOpts
		funcOpts.generate = @generate
		PPTXGenUtils.createPPT(funcOpts)



	@generate: (funcOpts={}) => # 需要在callback中使用故需使用 =>
		{pres,json} = funcOpts
		# slide title page
		slide = pres.addSlide("TITLE_SLIDE")
		slide.addText("量化报告")

		for key, section of json
			
			# slide section could be added from key
			pres.addSection({title:key})
			funcOpts.json = section
			funcOpts.sectionTitle = key

			@singleCharts(funcOpts)





	@singleCharts: (funcOpts={}) ->
		{pres,sectionTitle,json:{data, settings:{chartType}}} = funcOpts
		#console.log {singleCharts: chartType, data}
		
		for key, obj of data
			slide = pres.addSlide({sectionTitle})

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
				

			slide.addChart(pres.ChartType[chartType], dataChartAreaLine, { 
				x: 0.1, y: 0.1, 
				w: "95%", h: "90%"
				showLegend: true, legendPos: 'b'
				showTitle: true, 
				title: obj.科室名 
			})






class PPTXGenUtils


	@getPPTFilename: (funcOpts={}) ->
		# 未来便于测试对比其他的库，在文件名中加上使用的PPT生成库名
		funcOpts.gen = "pg" #"pptxgen"
		JSONUtils.getPPTFilename(funcOpts)



	@createPPT: (funcOpts={}) ->
		{json,generate} = funcOpts
		pptname = @getPPTFilename(funcOpts)
		
		if true #not fs.existsSync pptname
			pres = new pptxgen()
			funcOpts.pres = pres
			generate?(funcOpts)
			
			#// For simple cases, you can omit `then`
			# pres.writeFile({ fileName: pptname})			
			#// Using Promise to determine when the file has actually completed generating
			pres.writeFile({ fileName: pptname })
					.then((fileName) -> 
							console.log("created file:#{path.basename fileName} at #{Date()}")
					)







module.exports = {
	MakePPTReport
	PPTXGenUtils
}
