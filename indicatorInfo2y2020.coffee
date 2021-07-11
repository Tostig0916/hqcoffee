e2j = require 'convert-excel-to-json'
fs = require 'fs'
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'

sourceFile = './indicator2y2020.xlsx'
jsonfilename = './indicators2y2020.json'
pptname = './indicators.pptx' 




readToJson = (funcOpts) ->
  # console.log e2j 
  result = e2j funcOpts
  
  jsonContent = JSON.stringify(result)

  fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
    if err? 
      console.log(err)
    else
      console.log "json saved at #{Date()}"

readOpts = {
  sourceFile:sourceFile
  header: {rows: 1}
  sheets: ['Sheet 1']
  columnToKey: {
    '*':'{{columnHeader}}'
  }
}

createPPT = (arr) ->
  labels = []
  values = []
  lvs = ({label: key, value: value} for key, value of obj for obj, index in arr)
  console.log "will create ppt here: ", lvs

  pres = new pptxgen()
  slide = pres.addSlide("TITLE_SLIDE")

  slide = pres.addSlide()

  #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
  #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
  #slide.background = { path: "https://some.url/image.jpg" }  # image: url

  #slide.color = "696969"  # Set slide default font color

  # EX: Styled Slide Numbers
  slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 32, color: "FF3399" }
  chartDataArray = [
    {
      name: "手术占比雷达图",
      labels: any.label for any in lvs[0],
      values: any.value for any in lvs[0]
    }
  ] 
      

  slide.addChart(pres.ChartType.radar, chartDataArray, { 
    x: 0, y: "50%", w: '45%', h: "50%" 
    showLegend: true, legendPos: "b"
  })
  slide.addChart(pres.ChartType.bar, chartDataArray, { 
    x: 5, y: "50%", w: '45%', h: "50%" 
    showLegend: true, legendPos: "b"
    showTitle: true, title: "Bar Chart"
  })

  ###
  #// For simple cases, you can omit `then`
  pres.writeFile({ fileName: pptname})
  ###
  #// Using Promise to determine when the file has actually completed generating
  pres.writeFile({ fileName: pptname })
      .then((fileName) -> 
          console.log("created file:#{fileName} at #{Date()}")
      )


if fs.existsSync jsonfilename
  content = require jsonfilename
  console.log jsonfilename, content 
  
  for key, value of content
    console.log jsonfilename, key, value
  
  #unless fs.existsSync pptname
  #  createPPT(arr)
  
else
  readToJson(readOpts)

