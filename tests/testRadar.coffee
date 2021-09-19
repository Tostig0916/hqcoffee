path = require 'path'
{MakePPTReport, PPTXGenUtils} = require path.join __dirname, '..','usepptxgen', 'pptxgenUtils'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


# 从数据表读取数据,再生成报告用的JSON
funcOpts = {
  basename: "jsszyy"
  headerRows: 1
  sheetStubs: true
  needToRewrite: false #true
  mainKeyName: "科室名"
}

sheetName = "雷达图"

json = JU.getJSON(funcOpts)
funcOpts.json = json[sheetName]

funcOpts.generate = (pres) ->
  slide = pres.addSlide("TITLE_SLIDE")

  for key, obj of json[sheetName]
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
      showTitle: true, 
      title: obj.科室名 
    })
  
PPTXGenUtils.createPPT(funcOpts)

