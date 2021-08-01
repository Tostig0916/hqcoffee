fs = require 'fs'
path = require 'path'
pptxgen = require 'pptxgenjs'

{IndicatorDef, IndicatorDefVersion} = require path.join __dirname, '../indicatorDef'
ju = require path.join __dirname, '../jsonUtils'

year=2020
funcOpts = {
  basename: "indef#{year}"
  folder: 'data'
  needToRewrite: false #true
}
dictionary = IndicatorDef.fromMannualFile(funcOpts)
arr = (v.description() for k, v of dictionary)


pptname = ju.getPPTFilename(funcOpts)
unless fs.existsSync pptname
  presentation = new pptxgen()

kpj = 0
jc = 0
for each in arr
  kpj++ if /可评价:true/.test each
  jc++ if /监测:true/.test each
  if presentation?
    slide = presentation.addSlide()

    # ---- to be modified -----
    
    #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
    #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
    #slide.background = { path: "https://some.url/image.jpg" }  # image: url

    #slide.color = "696969"  # Set slide default font color

    # EX: Styled Slide Numbers
    slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 32, color: "FF3399" }
    dataChartAreaLine = [
        {
            name: arr[0].科室名称,
            labels: ["医服收","收合","门收合","住收合"],
            values: [arr[0].医疗服务收入,arr[0].收入合计,arr[0].门诊收入合计,arr[0].住院收入合计]
        },
        {
            name: arr[1].科室名称,
            labels: ["医服收","收合","门收合","住收合"],
            values: [arr[1].医疗服务收入,arr[1].收入合计,arr[1].门诊收入合计,arr[1].住院收入合计]
        },
    ]

    slide.addChart(presentation.ChartType.radar, dataChartAreaLine, { 
      x: 0, y: "50%", w: '45%', h: "50%" 
      showLegend: true, legendPos: "b"
    })
    slide.addChart(presentation.ChartType.bar, dataChartAreaLine, { 
      x: 5, y: "50%", w: '45%', h: "50%" 
      showLegend: true, legendPos: "b"
      showTitle: true, title: "Bar Chart"
    })

    ###
    #// For simple cases, you can omit `then`
    presentation.writeFile({ fileName: pptname})
    ###
    #// Using Promise to determine when the file has actually completed generating
    presentation.writeFile({ fileName: pptname })
        .then((fileName) -> 
            console.log("created file:#{fileName} at #{Date()}")
        )



console.log "共#{IndicatorDefVersion.versionCount()}个版本，#{arr.length}个指标，其中#{kpj}个可评价指标, #{jc}个国家监测指标"
