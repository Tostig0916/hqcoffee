e2j = require 'convert-excel-to-json'
fs = require 'fs'
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'

sourceFile = './三四级手术占比2019-2020.xlsx'
jsonfilename = './手术占比.json'
pptname = './手术占比雷达图.pptx' 




readToJson = (readOpts) ->
  # console.log e2j 
  result = e2j readOpts
  
  jsonContent = JSON.stringify(result)

  fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
    if err? 
      console.log(err)
    else
      console.log "json saved at #{Date()}"



readOpts = {
  sourceFile:sourceFile
  header: {rows: 2}
  sheets: ['三级专科','二级专科']  #['二级专科']
  #range: 'A6:Z14'
  columnToKey: {
    '*':'{{columnHeader}}'
    #A:"{{A2}}", B:"{{B2}}", C:"{{C2}}"
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
      labels: any.label for any in lvs[0] when (not isNaN(parseFloat(any.value)) && isFinite(any.value)),
      values: any.value for any in lvs[0] when (not isNaN(parseFloat(any.value)) && isFinite(any.value))
    }
  ] 
      

  slide.addChart(pres.ChartType.radar, chartDataArray, { 
    x: 0, y: "50%", w: '45%', h: "50%" 
    showLegend: true, legendPos: "b"
    showTitle: true, title: "手术占比雷达图"
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


if not fs.existsSync jsonfilename
  content = require jsonfilename
  #console.log content 
  
  arr = content['二级专科']
  #console.log arr
  
  unless not fs.existsSync pptname
    createPPT(arr)
  
else
  readToJson(readOpts)

