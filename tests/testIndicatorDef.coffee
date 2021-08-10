fs = require 'fs'

path = require 'path'
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'


# use __dirname and __filename to create correct full path filename
{IndicatorDef, IndicatorDefInfoByVersion} = require path.join __dirname, '..','toJSON', 'indicatorDef'
JU = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


arrayOfDefs = (funcOpts) ->
  {year=2020} = funcOpts
  funcOpts = {
    basename: "indef#{year}"
    folder: 'data'
    needToRewrite: true
  }
  dictionary = IndicatorDef.fromMannualFile(funcOpts)
  #arr = (v for k, v of dictionary)
  arr = (v.description() for k, v of dictionary)

  #console.log arr

  vector = 0
  jc = 0


  for each in arr
    vector++ if /矢量:true/.test each
    jc++ if /监测:true/.test each
    #createPPT({presentation:null})

  #console.log IndicatorDefInfoByVersion.versionArray() #JSON.stringify(IndicatorDefInfoByVersion.versions)
  console.log "共#{IndicatorDefInfoByVersion.versionCount()}个版本，#{arr.length}个指标，其中#{vector}个可评价指标, #{jc}个国家监测指标"
  return {arr, dictionary}


module.exports = arrayOfDefs



funcOpts = {year:2020}
{arr} = arrayOfDefs(funcOpts)  
funcOpts.arr = arr


createExcel = (funcOpts) ->
  return "not done yet"

  excelfileName = JU.getExcelFilename(funcOpts)
  {arr,needToRewrite} = funcOpts
  unless fs.existsSync(excelfileName) or needToRewrite
    data = [
      {
        sheet: "国考指标体系"
        columns: [
          {label: "指标名称", value:"指标名称"}

        ]
        content: arr
      }
    ]




createPPT = (funcOpts) ->
  {presentation} = funcOpts

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



createExcel(funcOpts)

funcOpts.gen = "pptxgen"
pptname = JU.getPPTFilename(funcOpts)
unless fs.existsSync pptname
  presentation = new pptxgen()

