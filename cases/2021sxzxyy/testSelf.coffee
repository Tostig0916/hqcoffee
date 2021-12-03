###
  用于边测试边开发的 test driven developing
  功能完善后,将本文件代码部分复制粘贴 self.coffee 即可作为各项目的基础程序文件

  开发流程为,在terminal 运行 
  ```
    coffee -w cases/goodhostpital2021/testSelf.coffee
  ```

  TODO:
    医院库和专科库分开?
    若不分开,每次需要剔除医院


  注意排序:
    除了指标名是从小到大排序英文在前,其他例如年份,数值都是默认从大到小排序的.注意看 sort 用法,如果不符合前述原则,
    则须加以留意並讨论

  对标报告:
    对标报告其实逻辑上与院内报告是雷同的.之所以区分,是因为传统习惯,以及数据表设计缺陷.
    如果将对标单位统一命名,例如医院,是本医院,医院对标均1,医院对标均2,医院对标某A,医院对标某B,依次类推,则可将所有
    数据置于同一电子表格的不同sheet内,其结构完全一样,分析过程也没有不同,只需挑选其中的对象即可,不需要另外设计代码
###

# settings
customerName = 'Good Hostpital'
customGrade = '三级综合' # '三级中医','二级综合'...
lastYear = 2020


# auto settings
year_1 = "Y#{lastYear}"
year_2 = "Y#{lastYear - 1}"
year_3 = "Y#{lastYear - 2}"


# require libs
util = require 'util'
path = require 'path'

{DataManager} = require path.join __dirname, '..', '..', 'analyze', './prepare'
{fix, existNumber} = require path.join __dirname, '..', '..', 'analyze', './fix'
{MakePPTReport} = require path.join __dirname, '..', '..', 'usepptxgen','pptxgenUtils'  
{StormDBSingleton,别名库,名字ID库} = require path.join __dirname, '..', '..', 'analyze', 'singletons'


# informal 设置为true则容忍指标直接填报不完整,而通过原始数据推算

# 此表为 singleton,只有一个instance,故可使用类侧定义


###
如果要用本地的项目别名库取代系统的别名库
1. 可以在data/JSON中,改写 别名库.json 的内容,将该文件夹下的项目别名库内容复制粘贴进去
2. 可以用程序技巧,采用继承方法,去掉以下class 注释,并且去掉 normalKeyName 上下的注释
区别是,第一种方法,技术含量低,且别名库内容会通过git保存版本,而第二种方法,技术上更优雅,但
git不管理项目别名库,要小心随着电脑故障等原因而丢失
###
###
class 项目别名库 extends 别名库
  @localOptions: ->
    false

  # 必须置于此处,以便随客户文件夹而建立数据库文件
  @_dbPath: ->
    if @localOptions()
      path.join __dirname, "#{@name}.json"
    else
      super()


  @options: ->
    if @localOptions()
      @_options = {
        dirname: __dirname
        basename: @name
        mainKeyName: "数据名"
        header: {rows: 1}
        columnToKey: {'*':'{{columnHeader}}'}
        sheetStubs: true
        needToRewrite: false
        rebuild: false
        unwrap: true 
        renaming: @normalKeyName
      }

    else
      super()
###





# 咨询案例
class AnyCaseSingleton extends StormDBSingleton
  ###
  # 如果要用本地的项目别名库取代系统的别名库,须去掉注释,运用以下代码
  @normalKeyName: ({mainKey}) =>
    # keep 则保存json文件
    项目别名库.ajustedName({name:mainKey,keep:true})
  ###

  @logdb: ->
    SystemLog.db().get(@name)


  @logdbClear: ->
    @logdb().set({})
    return SystemLog.db()

  # @_dbPath 涉及到目录位置,似乎无法在此设置

  # 用于获取或计算指标数据
  @getData: (funcOpts) ->
    # 分别为单位(医院,某科),数据名,以及年度
    {entityName} = funcOpts
    funcOpts.storm_db = @db()
    funcOpts.dbItem = @db().get(entityName)

    funcOpts.regest_db = 缺漏追踪库.db()
    funcOpts.log_db = @logdb()
    funcOpts.hostname = @name

    DataManager.getData(funcOpts)






class CaseSingleton extends AnyCaseSingleton
  @createMissingData: -> 
    false

  # 必须置于此处,以便随客户文件夹而建立数据库文件
  @_dbPath: ->
    path.join __dirname, "#{@name}.json"

  @years: ->
    院内资料库.years()


  @localUnits: ->
    院内资料库.localUnits()

  @focusUnits: ->
    对标资料库.dbDictKeys()

  @二级指标表: (funcOpts={})->
    {full=false} = funcOpts
    二三级对应表 = 二级指标对应三级指标.dbValue()
    if full
      二三级对应表
    else
      (key for key, value of 二三级对应表)



class NormalCaseSingleton extends CaseSingleton
  @options: ->
    @_options = {
      dirname: __dirname
      basename: @name
      mainKeyName: "数据名"
      header: {rows: 1}
      columnToKey: {'*':'{{columnHeader}}'}
      sheetStubs: true
      needToRewrite: true
      unwrap: true 
      renaming: @normalKeyName
    }


class 缺漏追踪库 extends NormalCaseSingleton


class SystemLog extends NormalCaseSingleton


class 指标体系 extends NormalCaseSingleton

class 评价指标体系 extends 指标体系
  @options: ->
    super()
    # JSON不作简化
    @_options.unwrap = false
    @_options


  @二级指标对应一级指标: ->
    obj = {}
    for key, value of @dbValue('二级指标设置') # sleepy
      obj[key] =  value.上级指标
    return obj


  @groups: ->
    struct = @dbValue('一级指标设置')
    (group for group, obj of struct)



  @saveExcel: (funcOpts={}) ->
    opts = @options()
    json= @dbValue()
    opts.data = [
      
      {
        sheet: '一级指标设置'
        columns:[
          {label:'数据名', value:'数据名'}
          {label:'权重',value:'权重'}
        ]
        content:({
          数据名: key 
          权重: value.权重
        } for key, value of json.一级指标设置).sort((a,b)-> if b.数据名 > a.数据名 then -1 else 1)
      },

      {
        sheet: '二级指标设置'
        columns:[
          {label:'数据名', value:'数据名'}
          {label:'权重',value:'权重'}
          {label:'上级指标', value:'上级指标'}
        ]
        content:({
          数据名: key 
          权重: value.权重
          上级指标: value.上级指标
        } for key, value of json.二级指标设置).sort((a,b)-> if b.数据名 > a.数据名 then -1 else 1)
      },
      {
        sheet:'三级指标设置'
        columns:[
          {label:'数据名', value:'数据名'}
          {label:'权重',value:'权重'}
          {label:'上级指标', value:'上级指标'}
          {label:'指标导向', value:'指标导向'}
          {label:'计量单位', value:'计量单位'}
          {label:'指标来源', value:'指标来源'}
          {label:'三级中医', value:'三级中医'}
          {label:'三级综合', value:'三级综合'}
          {label:'二级综合', value:'二级综合'}        
        ]
        content: ({
          数据名: key 
          权重: value.权重
          指标导向: value.指标导向
          上级指标: value.上级指标
          指标来源: value.指标来源
          三级中医: value.三级中医
          三级综合: value.三级综合
          二级综合: value.二级综合
          计量单位: value.计量单位
        } for key, value of json.三级指标设置).sort((a,b)-> if b.数据名 > a.数据名 then -1 else 1)
      }
    ]
    opts.settings = {
      extraLength: 5
      writeOptions: {}
    }
    
    @write2Excel(opts)





  # 从之前旧设计的两个结果json合并出一个新的Excel表,以后采用此表为基础,增加少量三级权重
  @combine2Excel: ->
    导向 = 指标导向库.dbValue()
    维度 = 三级指标对应二级指标.db()
    
    # 数据名采用顺序排列,与其他采用倒序排序方式不同
    arr = ({数据名, 指标导向, 上级指标: 维度.get(数据名).value()} for 数据名, 指标导向 of 导向).sort (a, b)->
      if b.数据名 > a.数据名 then -1 else 1

    opts = @options()
    opts.data = [{
      sheet:'维度导向'
      columns:[
        {label:'上级指标',value:'上级指标'}
        {label:'指标导向',value:'指标导向'}
        {label:'数据名',value:'数据名'}
      ]
      content: arr
    }]

    opts.settings = {
      extraLength: 5
      writeOptions: {}
    }
    
    @write2Excel(opts)




class 指标导向库 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    for key, obj of 评价指标体系.dbValue("三级指标设置")
      @dbSet(key, obj.指标导向)
    @dbSave()

    


  @导向指标集: ->
    @dbRevertedValue()




class 三级指标对应一级指标 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    三级设置 = 评价指标体系.dbValue("三级指标设置")
    二级设置 = 评价指标体系.dbValue("二级指标设置")
    for key, obj of 三级设置
      console.log {缺少二级设置: obj.上级指标} unless 二级设置[obj.上级指标]?
      @dbSet(key, 二级设置[obj.上级指标].上级指标)
    @dbSave()




class 二级指标对应一级指标 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    二级设置 = 评价指标体系.dbValue("二级指标设置")
    for key, obj of 二级设置
      @dbSet(key, obj.上级指标)
    @dbSave()





class 一级指标对应二级指标 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    @dbDefault(二级指标对应一级指标.dbRevertedValue()).save()




class 一级指标对应三级指标 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    @dbDefault(三级指标对应一级指标.dbRevertedValue()).save()




class 三级指标对应二级指标 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    for key, obj of 评价指标体系.dbValue("三级指标设置")
      @dbSet(key, obj.上级指标)
    @dbSave()



  # 矢量指标,即有明确方向的指标
  @vectors: ->
    obj = {}
    for k, v of @dbValue() when 指标导向库.db().get(k).value() in ['逐步提高','逐步降低','高优','低优']
      (obj[v] ?= []).push(k)
    obj


    
class 指标填报表 extends 指标体系
  @saveExcel: (funcOpts={}) ->
    opts = @options()
    json= 评价指标体系.dbValue('三级指标设置')
    科室设置 = 评价指标体系.dbValue('科室设置')
    opts.data = [
      {
        sheet:'医院'
        columns:[
          {label:'数据名',value:'数据名'}
          #{label:'上级指标',value:'上级指标'}
          {label:'计量单位',value:'计量单位'}
          {label:year_1,value:year_1}
          {label:year_2,value:year_2}
          {label:year_3,value:year_3}
        ]
        content: (value for key, value of json \
        when (value.适用范围 in [1,3]) and /(自|考|监)/.test(value[customGrade])).sort(
          (a,b)-> switch 
            when b.上级指标 > a.上级指标 then -1
            when b.上级指标 is a.上级指标 then switch
              when b.数据名 > a.数据名 then -1
              else 1        
            #when b.数据名 > a.数据名 then -1
            else 1
        )
      }
    ]

    for 科室名, 科室 of 科室设置 when 科室.选项 in [1,2,3]
      opts.data.push {
        sheet: 科室名
        columns:[
          {label:'数据名',value:'数据名'}
          #{label:'上级指标',value:'上级指标'}
          {label:'计量单位',value:'计量单位'}
          {label:year_1,value:year_1}
          {label:year_2,value:year_2}
          {label:year_3,value:year_3}
        ]
        content: (value for key, value of json \
        when (value.适用范围 in [1,2,3]) and /(自|考|监)/.test(value[customGrade])).sort(
          (a,b)-> switch 
            when b.上级指标 > a.上级指标 then -1
            when b.上级指标 is a.上级指标 then switch
              when b.数据名 > a.数据名 then -1
              else 1        
            #when b.数据名 > a.数据名 then -1
            else 1
        )
      }

    opts.settings = {
      extraLength: 5
      writeOptions: {}
    }
    
    @write2Excel(opts)



class 二级指标对应三级指标 extends 指标体系
  @dataPrepare: ->
    @dbClear()
    @dbDefault(三级指标对应二级指标.dbRevertedValue()).save()
    @dbSave()





class 资料库 extends NormalCaseSingleton 

class 院内资料库 extends 资料库
  @localUnits: ->
    @dbDictKeys()
  
  @dataNames: -> 
    (k for k, v of @dbValue()[@localUnits()[0]]) 
  
  @years: -> 
    years = (k for k, v of @dbValue()[@localUnits()[0]][@dataNames()[0]] when /^y/i.test(k))
    years = years.sort((x,y)-> if x > y then -1 else 1)

 
 
 
 
  # 仅用于建水县的一份国考数据资料,但是演示了一种定制程序的方法
  @normalKeyName: (funcOpts) =>
    {mainKey} = funcOpts
    if mainKey? and /测试/i.test(customerName)
      newName = mainKey.split('.')[-1..][0]
      funcOpts.mainKey = newName  
    super(funcOpts)






class 院内指标资料库 extends 资料库

  @rawDataToIndicators: ->
    @dbClear()
    指标维度 = 三级指标对应二级指标.dbValue()
    years = @years()
    units = @localUnits()
    informal = @createMissingData()

    for dataName, dimension of 指标维度 when dataName?
      for entityName in units 
        for year in years
          key = year
          ownData = 院内资料库.getData({entityName, dataName, key, informal})
          @dbSet("#{entityName}.#{dataName}.#{year}", ownData) if existNumber(ownData)
    @dbSave()
    console.log "院内指标资料库: 指标数据移动完毕"
    return this



# ---------------------------------  slides api  -----------------------------------
class 分析报告 extends NormalCaseSingleton

  @newReport: ->
    opts = @options()
    opts.generate = (funcOpts) => 
      {pres} = funcOpts
      # title slide
      title = "数智分析报告"
      slide = pres.addSlide("TITLE_SLIDE")
      slide.addText(title, {x: '30%', y: '50%',color: "0000FF", fontSize: 64} )
      slide.addText(customerName, {x: '10%', y: '90%',color: "DDDD00", fontSize: 32} )
      # slides in sections
      for section in @sections()
        # slide section could be added from key
        sectionTitle = section.name

        pres.addSection({title: sectionTitle})
        section.slides({pres, sectionTitle})

    MakePPTReport.newReport(opts)



  @dataPrepare: ->
 

  @sectionData: ->
    @dbValue()


  @slides:(funcOpts) ->
    {pres, sectionTitle} = funcOpts
    console.log {slides: sectionTitle}


  # 每部分限定几张PPT,用于测试和demo
  @pageLimit: ->
    null 
    



# https://github.com/gitbrent/PptxGenJS/blob/master/demos/modules/demo_table.mjs
class 表格报告 extends 分析报告
  @arrayName: ->
  
  @titles: ->
  
  @sectionData: ->
    @db().get(@arrayName()).value()

  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    data = @sectionData()
    size = data.length
    titles = @titles() 

    # 自动切分页面未掌握技巧,姑且在此切分,待掌握技巧后代码无须变动
    newPage = (data) ->
      rows = []
      rows.push(titles)

      #console.log {data}
      for each in data
        rows.push ((if t is '科室名称' then each[t] else fix(each[t] ? 0)) for t in titles)

      slide = pres.addSlide({sectionTitle})
      width = [1.2]
      n = titles.length    
      while --n > 0
        width.push(0.55) 
      #console.log {width}
      slide.addText(sectionTitle, {
        x: '35%', 
        y: '10%',
        #color: "DDDD00", 
        fontSize: 18
      })
      slide.addTable(rows, {
        #x: 0.5
        y: "20%" 
        #w: "90%" 
        #h: 1   
        colW: width
        border: {color: "CFCFCF"} 
        #margin: 0.05
        align: "left"
        valign: "middle"
        fontFace: "Segoe UI"
        fontSize: 9
        autoPage: false #true
        autoPageRepeatHeader: true
        autoPageCharWeight: -0.5
        autoPageLineWeight: -0.5
        autoPageHeaderRows: 1
        #autoPageSlideStartY: 0.2
        verbose: false
        #showTitle:true
        #title: sectionTitle
      })
    
    lines = 15
    ps = 0 
    pe = lines
    while size >= ps
      newPage(data[ps...Math.min(pe, size)])
      #console.log({size, ps, pe})
      ps = pe
      pe += lines




class 散点图报告 extends 分析报告
  @chartType: -> 'scatter'


  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()    
    data = @sectionData()
    
    pages = 0
    pageLimit = @pageLimit()

    for indicator, arr of data
      delete(data[indicator])
      for _indicator, _arr of data
   
        return null if existNumber(pageLimit) and (pages++ > pageLimit)

        nar = []
        arr.map (each, idx) -> 
          nar[idx] = indc for indc in _arr when indc.unitName is each.unitName   

        slide = pres.addSlide({sectionTitle})
        #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
        #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
        #slide.background = { path: "https://some.url/image.jpg" }  # image: url
        #slide.color = "696969"  # Set slide default font color
        # EX: Styled Slide Numbers
        slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 10, color: "3333ff" }

        chartData = [
          { # x
            name: _indicator
            values: nar.map (each,idx)-> each[_indicator]
            #labels: arr.map (each,idx)-> each.unitName
          }
          { # y
            name: indicator
            values: arr.map (each,idx)-> each[indicator]
            labels: arr.map (each,idx)-> each.unitName
          }
        ]

        slide.addChart(pres.ChartType[chartType], chartData, { 
          x: 0.1 
          y: 0.1 
          w: "95%"
          h: "95%"
          showLegend: false, 
          #legendPos: 'b'
          
          showTitle: true, 
          title: "#{indicator} vs #{_indicator}"

          # x
          catAxisTitle: _indicator,
          catAxisTitleColor: "428442",
          catAxisTitleFontSize: 10,
          showCatAxisTitle: true,

          # y
          valAxisTitle: indicator,
          valAxisTitleColor: "428442",
          valAxisTitleFontSize: 10,
          showValAxisTitle: true,

          lineSize: 0,
          
          showLabel: @showLabel(), #// Must be set to true or labels will not be shown
          dataLabelPosition: "t", #// Options: 't'|'b'|'l'|'r'|'ctr' 
          dataLabelFormatScatter: "custom", #// Can be set to `custom` (default), `customXY`, or `XY`.
        })




  @showLabel: ->
    true




class BCG矩阵报告 extends 散点图报告

  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()
    
    #@dataPrepare()
    data = @sectionData()
    
    #console.log({sectionTitle,data: @db().get("医疗服务收入三年复合增长率").get(1).value()}) if /BCG/i.test(sectionTitle)
    
    [indicator, _indicator] = [
      '医疗服务收入三年复合增长率'   # x
      '医疗服务收入占全院比重'      # y
    ]

    arr = data[indicator]
    _arr = data[_indicator]

    nar = []
    arr.map (each, idx) -> 
      nar[idx] = indc for indc in _arr when indc.unitName is each.unitName   

    slide = pres.addSlide({sectionTitle})
    #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
    #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
    #slide.background = { path: "https://some.url/image.jpg" }  # image: url
    #slide.color = "696969"  # Set slide default font color
    # EX: Styled Slide Numbers
    slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 10, color: "3333ff" }
    chartData = [
      { # x
        name: indicator
        values: arr.map (each,idx)-> each[indicator]
        #labels: arr.map (each,idx)-> each.unitName
      }
      { # y
        name: _indicator
        values: nar.map (each,idx)-> each[_indicator]
        labels: nar.map (each,idx)-> each.unitName
      }
    ]

    slide.addChart(pres.ChartType[chartType], chartData, { 
      x: 0.1 
      y: 0.1 
      w: "95%"
      h: "95%"
      showLegend: false, 
      #legendPos: 'b'
      
      showTitle: true, 
      title: sectionTitle #"#{indicator} vs #{_indicator}"
      
      # x
      catAxisTitle: indicator,
      catAxisTitleColor: "428442",
      catAxisTitleFontSize: 10,
      showCatAxisTitle: true,
      lineSize: 0,

      # y
      valAxisTitle: _indicator,
      valAxisTitleColor: "428442",
      valAxisTitleFontSize: 10,
      showValAxisTitle: true,
      lineSize: 0,
            
      showLabel: true, #// Must be set to true or labels will not be shown
      dataLabelPosition: "t", #// Options: 't'|'b'|'l'|'r'|'ctr' 
      #dataLabelFormatScatter: "custom", #// Can be set to `custom` (default), `customXY`, or `XY`.
    })





class 排序报告 extends 分析报告
  @chartType: ->
    'bar'



  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()

    pageLimit = @pageLimit()
    pages = 0

    data = @sectionData()
    for indicator, arr of data when arr.length > 0

      return null if existNumber(pageLimit) and (pages++ > pageLimit)

      slide = pres.addSlide({sectionTitle})
      #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
      #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
      #slide.background = { path: "https://some.url/image.jpg" }  # image: url
      #slide.color = "696969"  # Set slide default font color
      # EX: Styled Slide Numbers
      slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 10, color: "3333ff" }
      chartData = [
        {
          name: indicator
          labels: arr.map (each,idx)-> each.unitName
          values: arr.map (each,idx)-> each[indicator]
        }
      ]
			
      slide.addChart(pres.ChartType[chartType], chartData, { 
        x: 0.1, y: 0.1, 
        w: "90%", h: "90%" #w: "95%", h: "90%"
        showLegend: true, 
        legendPos: 'b'
        showTitle: true, 
        title: indicator
        #chartColors: ['0088CC','FFCC00']
        showDataTableKeys: true 
        #showValue: true # 只有整数?怎么设置小数点保留位数?
      })




class 评分排序报告 extends 排序报告
  @chartType: ->
    'bar3d'


class 雷达图报告 extends 分析报告
  @chartType: ->
    'radar'


class 多科雷达图报告 extends 雷达图报告

  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()
    pageLimit = @pageLimit()
    pages = 0
    n = 49

    data = @sectionData()
    #console.log({depts:data.医保价值.length})

    for indicator, arr of data
      delete(data[indicator])
      for _indicator, _arr of data
        return null if existNumber(pageLimit) and (pages++ > pageLimit)
  
        nar = []
        arr.map (each, idx) -> 
          nar[idx] = indc for indc in  _arr when indc.unitName is each.unitName   
        slide = pres.addSlide({sectionTitle})
        #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
        #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
        #slide.background = { path: "https://some.url/image.jpg" }  # image: url
        #slide.color = "696969"  # Set slide default font color
        # EX: Styled Slide Numbers
        slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 10, color: "3333ff" }
        chartData = [
          {
            name: indicator
            labels: arr[0..n].map (each,idx)-> each.unitName
            values: arr[0..n].map (each,idx)-> each[indicator] #* 100 / arr[0][indicator]
          }
          {
            name: _indicator
            labels: nar[0..n].map (each,idx)-> each.unitName
            values: nar[0..n].map (each,idx)-> each[_indicator] #* 100 / _arr[0][_indicator]
          }
        ]
        
        slide.addChart(pres.ChartType[chartType], chartData, { 
          x: 0.1, y: 0.1, 
          w: "90%", h: "90%" #w: "95%", h: "90%"
          showLegend: true, legendPos: 'b'
          showTitle: true, 
          title: "#{indicator} vs #{_indicator}" #indicator
          fontSize: 5 
        })



class 单科雷达图报告 extends 雷达图报告
  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()
    
    pageLimit = @pageLimit()
    pages = 0

    data = @sectionData()
    for unitName, arr of data

      return null if existNumber(pageLimit) and (pages++ > pageLimit)

      slide = pres.addSlide({sectionTitle})
      #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
      #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
      #slide.background = { path: "https://some.url/image.jpg" }  # image: url
      #slide.color = "696969"  # Set slide default font color
      # EX: Styled Slide Numbers
      slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 10, color: "3333ff" }
      chartData = [
        {
          name: unitName
          labels: arr.map (each,idx)-> each.dimension
          values: arr.map (each,idx)-> each[each.dimension]
        }
      ]
			
      slide.addChart(pres.ChartType[chartType], chartData, { 
        x: 0.1, y: 0.1, 
        w: "90%", h: "90%" #w: "95%", h: "90%"
        showLegend: true, legendPos: 'b'
        showTitle: true, 
        title: unitName 
      })



# 同一个科室或医院,跟同类外部科室或本身不同年份的多维度对比
class 单科对比雷达图报告 extends 雷达图报告
  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()

    pageLimit = @pageLimit()
    pages = 0

    data = @sectionData()
    
    for departName, departObj of data
      for dimensionName, dimensionArray of departObj

        return null if existNumber(pageLimit) and (pages++ > pageLimit)

        # 每单位一张图,也可以每单位每一个大的维度一张图,共4张图等等
        slide = pres.addSlide({sectionTitle})
        slide.slideNumber = { x: "95%", y: "95%", fontFace: "Courier", fontSize: 10, color: "3333ff" }
        chartData = []
        for line in [year_1,'均2'] #[year_1,'均2','均1']
          chartData.push {
            name: line
            labels: dimensionArray.map (each, idx) -> each.key
            values: dimensionArray.map (each, idx) -> each[line]
          }

        slide.addChart(pres.ChartType[chartType], chartData, { 
          x: 0.1, y: 0.1, 
          w: "90%", h: "90%" #w: "95%", h: "90%"
          showLegend: true, legendPos: 'b'
          showTitle: true, 
          title: "#{departName}: #{if dimensionName is '满意度评价' then '地位影响' else dimensionName}" 
        })







# ---------------------------------  data api  -----------------------------------

class 院内各科指标简单排序 extends 排序报告
  @dataPrepare: ->
    @dbClear()
    year = @years()[0] # 最大的那个
    指标维度 = 三级指标对应二级指标.dbValue()

    for dataName, dimension of 指标维度 when dataName?
      except = /^医院$/  #/(^医院$|^大|合并)/
      arr = 院内指标资料库.dbAsArray({dataName,key:year,except})
      @dbSet(dataName, arr)
      @db().get(dataName).sort((a,b)-> b[dataName] - a[dataName])

    @dbSave()







class 院内各科指标评分排序 extends 评分排序报告

  @dataPrepare: ->
    @dbClear()
    direction = 指标导向库.dbRevertedValue()    
    #return null unless direction.逐步提高?
    
    # 均为由高到低排序
    obj = @sortedIndicators()
    directions = []
      .concat(direction.逐步提高).concat(direction.高优)
      .concat(direction.逐步降低).concat(direction.低优)
    #console.log {directions}

    for indicator, arr of obj when arr[0]? and (indicator in directions)
      first = arr[0][indicator]
      last = arr[arr.length - 1][indicator]
      distance = first - last
      
      newArr = (up) -> 
        result = arr.map (unit, idx)-> 
          value = if first is 0 and last is 0 then 0 else 100 * (unit[indicator] - last) / (distance + 0.0000001) # 避免除以0
          console.log({bug:"> 100", indicator, distance, value, last, first, unit}) if (value > 101) or (value is null)
          switch
            when up
              unit[indicator] = value
            else #indicator in direction.逐步降低
              unit[indicator] = 100 - value
          unit
        
        #return result
        if up then result else result.reverse()
      
      up = indicator in [].concat(direction.逐步提高).concat(direction.高优)
      @dbSet(indicator, newArr(up))

    @dbSave()

    #console.log direction

  @sortedIndicators: ->
    # 以下计算的前提,是原来的排序以数值为依据(不以优劣为依据),从大到小排列
    # 若为安全起见,此处可先再次排序确保不受别处代码变更影响
    院内各科指标简单排序.dbValue()



class 院内各科指标轮比雷达图 extends 多科雷达图报告
  @dataPrepare: ->



class 院内单科多指标评分雷达图 extends 单科雷达图报告
  @dataPrepare: ->





# 以指标维度为主体,看相关指标趋势离散度
class 院内各科维度轮比雷达图 extends 多科雷达图报告
  @dataPrepare: ->
    @dbClear()
    @dbDefault(院内各科相关维度轮比分析.dbValue()).save()


class 院内单科多维度指标评分汇集 extends 分析报告
  @dataPrepare: ->
    @dbClear()
    dimensions = 三级指标对应二级指标.dbValue()
    obj = 院内各科指标评分排序.dbValue()

    # step one: collect all indicators in a dimension
    for indicator, arr of obj when (dmName = dimensions[indicator])?
      for each in arr
        unless @db().get(dmName)?.value?()? and @db().get(dmName).get(each.unitName)?.value?()?
          @db().get(dmName).get(each.unitName).set('indicators', []) 
        unit = @db().get(dmName).get(each.unitName).get('indicators')
        unit.push({indicator, value: each[indicator]})
        
        # 查错
        console.log({error: each.unitName,indicator, value: each[indicator]}) \
          unless existNumber(each[indicator])
    
    # 计算维度分数
    # step two: calculate dimension value
    # 注意: 这一步根据设置好的指标权重进行预处理
    指标体系 = 评价指标体系.dbValue("三级指标设置")
    vectors = 三级指标对应二级指标.vectors()

    for dmName, dmObj of @dbValue()
      s = vectors[dmName].length
      for unitName, unitObj of dmObj
        {indicators} = unitObj
        v = 0
        for each in indicators
          weight = 指标体系[each]?.权重 ? 1 / s
          v += each.value * weight
        @db().get(dmName).get(unitName).set('score', v)

    @dbSave()




class 院内各科相关维度轮比分析 extends 分析报告
  @dataPrepare: ->
    @dbClear()
    for dmName, dmObj of 院内单科多维度指标评分汇集.dbValue()
      sorted = ({unitName, "#{dmName}":unitObj.score} for unitName, unitObj of dmObj).sort (a, b)-> b[dmName] - a[dmName]
      @db().set(dmName, sorted)

    keys = (k for k, v of @dbValue())    
    for key in keys
      @db().set(key, 
        @db()
          .get(key)
          .filter((obj) -> not /(^大|合并|医院)/i.test(obj.unitName))
          .value()
      )

    @dbSave()




# 以专科为单位,各维度雷达图
class 院内单科多维度评分集中分析 extends 单科雷达图报告
  @dataPrepare: ->
    @dbClear()
    for dmName, dmObj of 院内单科多维度指标评分汇集.dbValue()
      for unitName, unitObj of dmObj
        # step three: turning into an ordered array
        unless @db().get(unitName)?.value?()?
          @db().set(unitName, [])
        newUnitObj = {}
        newUnitObj.dimension = dmName
        newUnitObj[dmName] = unitObj.score
        @db().get(unitName).push(newUnitObj)

    @dbSave()





class 院内各科维度轮比散点图 extends 散点图报告
  @dataPrepare: ->
    @dbDefault(院内各科相关维度轮比分析.dbValue()).save()


  @showLabel: -> true




class 院内单科多维评分散点图 extends 散点图报告
  @dataPrepare: ->




class 院内专科BCG矩阵分析 extends BCG矩阵报告
  @dataPrepare: ->
    @dbClear()
    
    obj = 院内各科指标简单排序.dbValue()
    selfObj = {}
    indicators = [
      '医疗服务收入占全院比重'
      '医疗服务收入三年复合增长率'
    ]
    
    for indicator in indicators
      selfObj[indicator] = obj[indicator]

    #for indicator, arr of obj when indicator in indicators
    #  selfObj[indicator] = arr
    
    
    @dbDefault(selfObj).save()




class 院内二级专科BCG矩阵分析 extends BCG矩阵报告
  @dataPrepare: ->
    @dbClear()
    keys = (k for k, v of 院内专科BCG矩阵分析.dbValue())
    
    for key in keys
      @db().set(key, 
        院内专科BCG矩阵分析.db()
          .get(key)
          .filter((obj) -> not /(^大|合并)/i.test(obj.unitName))
          .value()
      )
    
    @dbSave()
    


class 院内二级权重专科BCG矩阵分析 extends BCG矩阵报告
  @dataPrepare: ->
    @dbClear()
    key = '医疗服务收入占全院比重'
    百分之零点一 = 1.5
    @db().set(key, 
      院内二级专科BCG矩阵分析.db()
        .get(key)
        .filter((obj) -> (obj[key] > 百分之零点一))
        .value()
    )

    names = (obj.unitName for obj in @db().get(key).value())
    key = '医疗服务收入三年复合增长率'
    all =  院内二级专科BCG矩阵分析.db().get(key).value()
    #console.log({all})
    @db().set(key, [])
    for unitName in names # 以此顺序收集
      for each in all when each.unitName is unitName
        @db().get(key).push(each)
        #all.shift() # 递减循环次数,但出错,仍使用笨办法

    @dbSave()



class 二级指标权重 extends 分析报告
  @dataPrepare: ->
    #return @dataPrepare_()

    @dbClear()
    一级设置 = 评价指标体系.dbValue("一级指标设置")
    二级设置 = 评价指标体系.dbValue("二级指标设置")
    for 二级名称, 二级指标 of 二级设置
      @db().get(二级名称).set(一级设置[二级指标.上级指标].权重 * 二级指标.权重)
    @dbSave()


  @dataPrepare_: ->
    @dbClear()
    #@dbSet('data',[])
    for cat, category of @struct()
      for dim, dimension of category.indicators
        @db().get(dim).set(category.weight * dimension.weight) 
    @dbSave()
    
  # 暂时保留,以便保留权重设置
  @struct: ->
    {
      医疗质量:{
        weight: 0.3
        indicators: {
          质量安全:{
            weight:0.3
          }
          功能定位: {
            weight:0.2
          }
          合理用药: {
            weight: 0.15
          }
          服务流程: {
            weight: 0.2
          }
          医保价值: {
            weight: 0.1
          }
        }
      }
      运营效率:{
        weight: 0.2
        indicators: {
          收支结构:{
            weight: 0.3
          }
          费用控制:{
            weight: 0.5
          }
          经济管理:{
            weight: 0
          }
          资源效率:{
            weight: 0.2
          }
        }
      }
      持续发展: {
        weight: 0.2
        indicators: {
          人员结构:{
            weight: 0.4 #0.3
          }
          人才培养:{
            weight: 0 #0.3
          }
          学科建设:{
            weight: 0.6 #0.4
          }
          信用建设:{
            weight: 0 #0.15
          }
        }
      }
      满意度评价: {
        weight: 0.3
        indicators: {
          医服收入:{
            weight: 0.8
          }
          地位影响: {
            weight: 0.2
          }
          医务人员满意度:{
            weight: 0
          }
          患者满意度:{
            weight: 0
          }
        }
      }
    }







  @dictWithPerfectData: -> 
    {
      医服收入: 2.5
      医保价值: 0.5
      质量安全: 1.5
      地位影响: 0.5
      学科建设: 0.1
      人员结构: 0.1
      功能定位: 0.1
      服务流程: 0.1
      费用控制: 0.1
      合理用药: 0.1
      收支结构: 0.1
      资源效率: 0.1
      人才培养: 0.1
    }

      




class 院内专科梯队Topsis评分 extends 分析报告
  @dataPrepare: ->
    @dbClear()
    weight = 二级指标权重.dbValue()
    for unitName, unitArray of 院内单科多维度评分集中分析.dbValue()
      @dbSet(unitName, {})
      value = 0
      for object in unitArray when existNumber(v = object[object.dimension])
        @db().get(unitName).set(object.dimension, v)
        value += v * weight[object.dimension]
      @db().get(unitName).set('综合评分',value).save()



class 院内专科梯队表 extends 表格报告
  @dataPrepare: ->
    @dbClear() #()
    arrayName = @arrayName()
    @db().set(arrayName,[])

    topsis = 院内专科梯队Topsis评分.dbValue()
    for unitName, unitObj of topsis when @validDeparts({unitName})
      unitObj.科室名称 = unitName
      @db().get(arrayName).push(unitObj)
    @db().get(arrayName).sort((a,b)-> b.综合评分 - a.综合评分) 
    @dbSave()  


  @validDeparts: (funcOpts={}) ->
    {unitName} = funcOpts
    not /医院/i.test(unitName)

  @arrayName: ->
    '学科梯队'


  @titles: ->
    dict = 二级指标权重.dbValue()
    arr = (key for key, value of dict when value > 0)
    arr.unshift("科室名称")
    arr.push('综合评分')
    arr


class 院内大小专科梯队混合表 extends 院内专科梯队表
  @validDeparts: (funcOpts={}) ->
    {unitName} = funcOpts
    not /(医院|合并)/i.test(unitName)



class 院内二级专科梯队表 extends 院内专科梯队表
  @validDeparts: (funcOpts={}) ->
    {unitName} = funcOpts
    not /(^大|医院|合并)/i.test(unitName)




# ------------------------------------- 对标本非逻辑有异,合表同理遴选即可 ------------------------------------
class 对标资料库 extends 资料库



class 对标指标资料库 extends 资料库

  @rawDataToIndicators: ->
    @dbClear()
    units = @focusUnits() # 对标资料库.dbDictKeys()
    指标维度 = 三级指标对应二级指标.dbValue()
    院内指标资料 = 院内指标资料库.dbValue()

    对标项 = ['均1','均2','某A','某B']
    informal = @createMissingData()  

    for dataName, dimension of 指标维度 when dataName?     
      for entityName in units when 院内指标资料[entityName]?
        for year, value of 院内指标资料[entityName][dataName]
          @dbSet("#{entityName}.#{dataName}.#{year}", value) if existNumber(value)

        for item in 对标项
          key = item
          otherData = 对标资料库.getData({entityName, dataName, key, informal})
          @dbSet("#{entityName}.#{dataName}.#{key}", otherData) if existNumber(otherData)
    
    @dbSave()
    console.log "对标指标资料库: 指标数据移动完毕"
    return this    






class 对标单科指标简单排序 extends 排序报告
  @dataPrepare: ->
    @dbClear()
    focusUnits = @focusUnits()
    for unit in focusUnits
      for indicator, valueGroup of 对标指标资料库.db().get(unit).value()
        indicatorName = "#{unit}: #{indicator}"
        @dbSet(indicatorName,({unitName:name, "#{indicatorName}":value} for name, value of valueGroup when existNumber(value)))
        @db().get(indicatorName).sort (a,b) -> b[indicatorName] - a[indicatorName]
    @dbSave()







class 对标单科指标评分排序 extends 评分排序报告

  @dataPrepare: ->
    @dbClear()
    direction = 指标导向库.dbRevertedValue()

    # 从高到低排序
    obj = @sortedIndicators()
    directions = []
      .concat(direction.逐步提高).concat(direction.高优)
      .concat(direction.逐步降低).concat(direction.低优)
    for indicator, arr of obj when arr[0]? and (realIndicatorName = indicator.split(': ')[1]) in directions
      first = arr[0][indicator]
      last = arr[arr.length - 1][indicator]
      distance = first - last
      newArr = (up)->
        result = arr.map (unit, idx)-> 
          value = if last is 0 and first is 0 then 0 else 100 * (unit[indicator] - last) / (distance + 0.0000001) # 避免除以0
          console.log {bug:"> 100",realIndicatorName,value, first} if value > 101
          switch 
            when up
              unit[indicator] = value
            else #realIndicatorName in direction.逐步降低
              unit[indicator] = 100 - value
          unit
        
        #return result
        if up then result else result.reverse()

      up = realIndicatorName in [].concat(direction.逐步提高).concat(direction.高优)
      @dbSet(indicator, newArr(up))

    @dbSave()



    
  @sortedIndicators: ->
    # 以下计算的前提,是原来的排序以数值为依据(不以优劣为依据),从大到小排列
    # 若为安全起见,此处可先再次排序确保不受别处代码变更影响
    对标单科指标简单排序.dbValue()





class 对标单科多指标评分雷达图 extends 单科对比雷达图报告
  @dataPrepare: ->
    @dbClear()
    sortKey = year_1
    largest = 7 # 雷达图可呈现的最多线条数,最多7条,即 自身三年外加两均两家,空缺为0分
    
    groups = 评价指标体系.groups()
    dict = 一级指标对应三级指标.dbValue()
    #console.log {groups,dict}
    dbscores = 对标单科指标评分排序.dbValue()
    
    getUnits = (scores)->    
      for deptIndicator, arr of scores when arr.length is largest
        return (each.unitName for each in arr)
    
    for deptIndicator, arr of dbscores
      sp = deptIndicator.split(': ')
      # 单位名和指标名
      [departName, indicatorName] = [sp[0], sp[1]]

      for each in arr when existNumber(each[deptIndicator])
        for dimensionName in groups when indicatorName in dict[dimensionName]
          @db()
            .get('data')
            .get(departName)
            .get(dimensionName)
            .get(indicatorName)
            .get(each.unitName)
            .set(each[deptIndicator])

      inObj = @db().get('data').value() #get(departName).get(dimensionName).value()

      transform = (name, obj) ->
        obj.key = name
        return obj

      # 各部门
      for departName, departObj of inObj
        # 各维度
        for dimensionName, dimensionObj of departObj
          dimensionArray = (transform(indicatorName, indicatorObj) for indicatorName, indicatorObj of dimensionObj)
          @db().get(departName).get(dimensionName).set(dimensionArray)
          @db().get(departName).get(dimensionName).sort((a,b)-> b[sortKey] - a[sortKey])

    @dbDelete('data').save()






  @dataPrepare_array: ->
    largest = 7 # 雷达图可呈现的最多线条数,最多7条,即 自身三年外加两均两家,空缺为0分
    @dbClear()
    groups = 评价指标体系.groups()
    dict = 一级指标对应三级指标.dbValue()
    dbscores = 对标单科指标评分排序.dbValue()
    getUnits = (scores)->    
      for deptIndicator, arr of scores when arr.length is largest
        return (each.unitName for each in arr)
    units = getUnits(dbscores)
    units.sort()
    for deptIndicator, arr of dbscores
      sp = deptIndicator.split(': ')
      [departName, indicatorName] = [sp[0], sp[1]]

      # 为当前个体(名 departName)中的每一个对象设置array
      for line in units
        for dimensionName in groups
          try
            # 第一个对比对象因未曾有故报错,由catch处理设置,其后此处一一设置
            unless @db().get(departName).get(dimensionName).get(line).value()
              @db().get(departName).get(dimensionName).get(line).set([]) #.save()
              #console.log({departName,line, try: true})

          catch error
            # 首次设置,在单位名下对比对象名尚未设立,故会出错,以下这一行将设置第一个对比对象的array
            @db().get(departName).get(dimensionName).get(line).set([]) #.save()
            #console.log({departName,line})

      for each in arr
        for dimensionName in groups when indicatorName in dict[dimensionName]
          @db().get(departName).get(dimensionName).get(each.unitName).push({
            key: indicatorName
            value: each[deptIndicator] ? 0
          })
    @dbSave()







# ---------------------------------  report api  -----------------------------------
# 不分内外,混合评估
class 院科混合分析报告 extends 分析报告

class 院科内部分析报告 extends 分析报告
  @sections: ->
    [

      #院内各科指标简单排序
      #院内各科指标评分排序 
      院内各科维度轮比雷达图
      院内各科维度轮比散点图
      院内单科多维度评分集中分析

      #院内专科BCG矩阵分析
      #院内二级专科BCG矩阵分析
      #院内二级权重专科BCG矩阵分析
      
      #院内专科梯队表
      院内二级专科梯队表
      #院内大小专科梯队混合表

      
      # 尚未制作
      # 院内各科指标轮比雷达图
      # 院内单科多指标评分雷达图
   ]



class 院科外部对标报告 extends 分析报告
  @sections: ->
    [
      #对标单科指标简单排序
      #对标单科指标评分排序 
      对标单科多指标评分雷达图
      
      #对标单科多维度评分雷达图

      #对标各科指标评分轮比雷达图
      #对标各科维度轮比雷达图
      #对标各科维度轮比散点图
    ]




# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports,并且可以在class定义区域下方编写生产脚本

class 生成器 extends CaseSingleton
  
  # 不知原因,不能连续运行这两步,内存中的各class数据会出现"串台"现象,
  # 需要分步做,第二步是从数据库读取,结果正确
  @run: ->
    @setUpSystem()
    @buildDB()
    @generateReports()



  @setUpSystem: ->
    this
      .readIndicatorExcel()



  @buildDB: ->
    this
      #.showDBs()
      .readDataExcel()
      .checkForAllIndicators()
      #.showMissingIndicatorsOrDataProblems()

      #.saveUtilExcel()

      #.showUnitNames()
      #._tryGetSomeData()
      #.showDimensions()
      
      .exportRawDataToReportDB()
      
      .simpleLocalIndicatorOrdering()
      .localIndicatorBCGChart()
      .localIndicatorScoreSort()
      .localIndicatorRadarChart()
      .localTeamsTable()

      .simpleCompareIndicatorOrdering()
      .compareIndicatorScoreSort()
      .compareIndicatorScoreRadarChart()
  
  
  
  @generateReports: ->
    this
      .localReport()
      .compareReport()




  # 获取最新资料,若有Excel源文件,则同时会生成json文件
  ###
  @readExcel: ->
    @readIndicatorExcel()
    @readDataExcel()
    return this
  ###


  @readIndicatorExcel: ->
    #console.log {院内资料库,对标资料库,三级指标对应二级指标,指标导向库,名字ID库}
    v.fetchSingleJSON() for k, v of {评价指标体系,名字ID库} #三级指标对应二级指标,指标导向库,

    指标导向库.dataPrepare()
    二级指标权重.dataPrepare()

    三级指标对应一级指标.dataPrepare()
    三级指标对应二级指标.dataPrepare()
    二级指标对应一级指标.dataPrepare()

    一级指标对应二级指标.dataPrepare()
    一级指标对应三级指标.dataPrepare()
    二级指标对应三级指标.dataPrepare()

    指标填报表.saveExcel()
    return this



  @readDataExcel: ->
    v.fetchSingleJSON() for k, v of {院内资料库,对标资料库} #三级指标对应二级指标,指标导向库,

    return this



  # 查看各自 db, 以及log
  @showDBs: ->
    console.log {db: v.dbValue()} for k, v of {院内资料库,院科内部分析报告,对标资料库,院科外部对标报告,别名库,项目别名库,缺漏追踪库,三级指标对应二级指标,名字ID库,SystemLog}
    console.log {log: v.logdb?().value()} for k, v of {院内资料库,院科内部分析报告,对标资料库,院科外部对标报告,别名库,项目别名库,缺漏追踪库,三级指标对应二级指标,名字ID库}
    return this



  # 看看有多少科室数据
  @showUnitNames: ->
    years = @years()
    localUnits = @localUnits()
    focusUnits = @focusUnits()
    console.log {localUnits, focusUnits, years}
    return this
  
  

  # 测试一下 getData, 例如平均住院日等等应该有的数据,看看程序逻辑是否走通
  @_tryGetSomeData: ->
    [entityName,dataName,key] = ['医院','平均住院日','Y2018']
    console.log {entityName,dataName,key,院内: 院内资料库.getData({entityName,dataName,key})}
    console.log {entityName,dataName,key,院内: 院内资料库.getData({entityName,dataName})}
    [entityName,dataName,key] = ['医院','平均住院日','某A']
    console.log {entityName,dataName,key,对标: 对标资料库.getData({entityName,dataName,key})}
    console.log {entityName,dataName,key,对标: 对标资料库.getData({entityName,dataName})}
    return this



  @showDimensions: ->
    console.log @二级指标表({full: true})
    return this


  # 筛查数据
  @checkForAllIndicators: ->
    院内资料库.logdbClear().save()
    对标资料库.logdbClear().save()
    缺漏追踪库.dbClear()

    指标维度 = 三级指标对应二级指标.dbValue()
    
    k1 = year_1
    k2 = '均2'
    for dataName, dimension of 指标维度 when dataName?
      for entityName in 院内资料库.dbDictKeys()
        院内资料库.getData({entityName, dataName, key:k1, informal:true})
      for entityName in 对标资料库.dbDictKeys()
        对标资料库.getData({entityName, dataName, key:k2, informal:true})
    console.log "指标数据筛查完毕"
    return this



  # 看缺多少指标数据,需要用数据计算
  @showMissingIndicatorsOrDataProblems: ->
    #@checkForAllIndicators()
    
    console.log { 
      院内资料: 院内资料库.logdb().value()
      对标资料: 对标资料库.logdb().value()
      缺漏追踪: (key for key, value of 缺漏追踪库.db().get('院内资料库').value() when value.length > 1)
    }
    return this



  # 研究 院内资料库
  # 先将指标计算结果存入报告db
  @exportRawDataToReportDB: ->
    院内指标资料库.rawDataToIndicators()
    对标指标资料库.rawDataToIndicators()
    return this

  
  

  # 院内各科指标简单排序存储备用
  @simpleLocalIndicatorOrdering: ->
    院内各科指标简单排序.dataPrepare()
    return this

  @simpleCompareIndicatorOrdering: ->
    对标单科指标简单排序.dataPrepare()
    return this


  @localIndicatorScoreSort: ->
    院内各科指标评分排序.dataPrepare()
    return this

  @compareIndicatorScoreSort: ->
    对标单科指标评分排序.dataPrepare()
    return this 

  @compareDimensionScoreRadarChart: ->
    对标单科多维度评分雷达图.dataPrepare()
    return this

  @compareIndicatorScoreRadarChart: ->
    对标单科多指标评分雷达图.dataPrepare()
    return this

  @localIndicatorRadarChart: ->
    院内单科多维度指标评分汇集.dataPrepare()
    院内单科多维度评分集中分析.dataPrepare()
    院内各科相关维度轮比分析.dataPrepare()
    院内各科维度轮比雷达图.dataPrepare()
    院内各科维度轮比散点图.dataPrepare()
    return this


  @localIndicatorBCGChart: ->
    院内专科BCG矩阵分析.dataPrepare()
    院内二级专科BCG矩阵分析.dataPrepare()
    院内二级权重专科BCG矩阵分析.dataPrepare()
    return this

  @localTopsis: ->
    院内专科梯队Topsis评分.dataPrepare()
    return this

  @localTeamsTable: ->
    @localTopsis()
    #院内专科梯队表.dataPrepare()
    院内二级专科梯队表.dataPrepare()
    院内大小专科梯队混合表.dataPrepare()
    return this


  @localReport: ->
    院科内部分析报告.newReport()
    return this


  @compareReport: ->
    院科外部对标报告.newReport()
    return this


  # 院内专科指标按照评分简单排序


  @saveUtilExcel: ->
    评价指标体系.saveExcel()
    return this










# --------------------------------------- 以下为测试代码 ---------------------------------------- #

# 将测试代码写成 function 加入到class method
# 将以上db工具function转移到 jsonUtils 文件中,並重启coffee测试行命令,重新测试


生成器
  .setUpSystem()
  #.buildDB()
  #.generateReports()

#console.log {L:项目别名库.localOptions(), O: 项目别名库.options(), P: 项目别名库._dbPath()}

#生成器.run()
生成器
  #.saveUtilExcel()
  #.showDBs()
  #.readExcel()
  #.showUnitNames()
  #._tryGetSomeData()
  #.checkForAllIndicators()
  
  #.showMissingIndicatorsOrDataProblems()
  
  #.exportRawDataToReportDB()
  
  #.simpleLocalIndicatorOrdering()
  #.localIndicatorScoreSort()
  #.localIndicatorRadarChart()
  
  #.localIndicatorBCGChart()
  #.localTeamsTable()
  #.localReport()
  #.compareReport()


###
# 对比雷达图设计
db = 对标单科指标评分排序.db()
db.filter()

###




#console.log db: 缺漏追踪库.db().get('院内资料库').value?()?

#
#院内单科多维度评分集中分析.dataPrepare()
#console.log @focusUnits()[1..9]
#院科内部分析报告.newReport()

#console.log 院内各科指标简单排序.dataPrepare()
#console.log 指标导向库.导向指标集()

###
dx = (key for key, value of 指标导向库.dbValue())
wd = (key for key, value of 三级指标对应二级指标.dbValue())
console.log {
  dx_wd: dx.length - wd.length
  dx: (each for each in dx when not (each in wd))
  wd: (each for each in wd when not (each in dx))
}
###


# 先rename keys
###
# 修改平均住院日 2018年数据
for uname, idx in 院科内部分析报告.dbDictKeys()
  key = "#{uname}.平均住院日.y2018"
  院科内部分析报告.dbSet(key, 院科内部分析报告.dbValue(key)/(idx+1))
  console.log {uname, 平均住院日:院科内部分析报告.dbValue(key)}

院科内部分析报告.dbSave()
###

#评价指标体系.combine2Excel()
