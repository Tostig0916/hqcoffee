###
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
		






module.exports = OfficeGenUtils



###




