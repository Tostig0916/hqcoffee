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
###

util = require 'util'
path = require 'path'

{DataManager} = require path.join __dirname, '..', '..', 'analyze', './prepare'
{fix} = require path.join __dirname, '..', '..', 'analyze', './fix'
{MakePPTReport} = require path.join __dirname, '..', '..', 'usepptxgen','pptxgenUtils'  
{StormDBSingleton,别名库,名字ID库} = require path.join __dirname, '..', '..', 'analyze', 'singletons'

existNumber = (x) -> x? and not isNaN(x)

# 设置为true则容忍指标直接填报不完整,而通过原始数据推算
informal = not true #false

# 此表为 singleton,只有一个instance,故可使用类侧定义

# 咨询案例
class AnyCaseSingleton extends StormDBSingleton
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

    DataManager.getData(funcOpts)





class 维度权重 extends AnyCaseSingleton
  @dict: -> 
    {
      服务收入: 0.4
      医保价值: 0.1
      质量安全: 0.5
      地位影响: 0.6
      学科建设: 0.2
      人员结构: 0.2
      功能定位: 0.3
      服务流程: 0.3
      费用控制: 0.3
      合理用药: 0.3
      收支结构: 0.3
      资源效率: 0.3
      人才培养: 0.2
    }

  @dictWithPerfectData: -> 
    {
      服务收入: 2.5
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
  

class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "Good Hospital"


  # 必须置于此处,以便随客户文件夹而建立数据库文件
  @_dbPath: ->
    path.join __dirname, "#{@name}.json"

  @years: ->
    院内资料库.years()


  @localUnits: ->
    院内资料库.localUnits()

  @focusUnits: ->
    对标资料库.dbDictKeys()

  @维度列表: (funcOpts={})->
    {full=false} = funcOpts
    指标维度表 = 指标维度库.dbRevertedValue()
    if full
      指标维度表
    else
      (key for key, value of 指标维度表)



class NormalCaseSingleton extends CaseSingleton

  @options: ->
    @_options ?= {
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

class 指标维度库 extends NormalCaseSingleton
  @saveExcel: (funcOpts={}) ->
    opts = @options()
    json= @dbValue()
    arr = ({数据名:key, 维度:value} for key, value of json).sort(
      (a,b)-> if a.数据名 < b.数据名 then -1 else 1
    )
    opts.data = [{
      sheet:'指标维度'
      columns:[
        {label:'数据名',value:'数据名'}
        {label:'二级维度',value:'维度'}
      ]
      content: arr
    }]
    opts.settings = {
      extraLength: 5
      writeOptions: {}
    }
    
    @write2Excel(opts)


class 指标导向库 extends NormalCaseSingleton
  @saveExcel: (funcOpts={}) ->
    opts = @options()
    json= @dbValue()
    arr = ({数据名:key, 导向:value} for key, value of json).sort(
      (a,b)-> if a.数据名 < b.数据名 then -1 else 1
    )
    opts.data = [{
      sheet:'指标导向'
      columns:[
        {label:'数据名',value:'数据名'}
        {label:'指标导向',value:'导向'}
      ]
      content: arr
    }]
    opts.settings = {
      extraLength: 5
      writeOptions: {}
    }
    
    @write2Excel(opts)



  @导向指标集: ->
    @dbRevertedValue()



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
    if mainKey? and /测试/i.test(@customerName())
      newName = mainKey.split('.')[-1..][0]
      funcOpts.mainKey = newName  
    super(funcOpts)





class 对标资料库 extends 资料库




class 院内指标资料库 extends 资料库

  @rawDataToIndicators: ->
    @dbClear().save()
    指标维度 = 指标维度库.dbValue()
    years = @years()
    units = @localUnits()
    

    for dataName, dimension of 指标维度 when dataName?
      for entityName in units 
        for year in years
          key = year
          ownData = 院内资料库.getData({entityName, dataName, key, informal})
          @dbSet("#{entityName}.#{dataName}.#{year}", ownData) if existNumber(ownData)
    @dbSave()
    console.log "院内指标资料库: 指标数据移动完毕"
    return this



class 对标指标资料库 extends 资料库

  @rawDataToIndicators: ->
    @dbClear().save()
    units = @focusUnits() # 对标资料库.dbDictKeys()
    指标维度 = 指标维度库.dbValue()
    院内指标资料 = 院内指标资料库.dbValue()

    对标项 = ['均1','均2','某A','某B']
    

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







class 分析报告 extends NormalCaseSingleton

  @newReport: ->
    opts = @options()
    opts.generate = (funcOpts) => 
      {pres} = funcOpts
      # title slide
      slide = pres.addSlide("TITLE_SLIDE")
      slide.addText("量化报告")
      # slides in sections
      for section in @sections()
        # slide section could be added from key
        sectionTitle = section.name

        pres.addSection({title: sectionTitle})
        section.slides({pres, sectionTitle})

    MakePPTReport.newReport(opts)



  @dataPrepare: ->
 


  @slides:(funcOpts) ->
    {pres, sectionTitle} = funcOpts
    console.log {slides: sectionTitle}







class 院内分析报告 extends 分析报告
  @sections: ->
    [
      院内专科梯队表
      院内专科BCG散点图
      
      #院内各科指标轮比雷达图
      #院内单科多指标评分雷达图


      院内各科维度轮比雷达图
      院内单科多维度评分雷达图

      院内各科指标简单排序
      院内各科指标评分排序 
      院内各科维度轮比散点图
   ]






class 对标分析报告 extends 分析报告
  @sections: ->
    [
      #对标各科指标评分轮比雷达图
      #对标单科多指标评分雷达图

      #对标各科维度轮比雷达图
      #对标单科多维度评分雷达图

      对标单科指标简单排序
      对标单科指标评分排序 
      #对标各科维度轮比散点图
    ]


# https://github.com/gitbrent/PptxGenJS/blob/master/demos/modules/demo_table.mjs
class 表格报告 extends 分析报告
  @arrayName: ->
  @titles: ->

  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    data = @db().get(@arrayName()).value()
    rows = []
    titles = @titles() 
    rows.push(titles)
    for each in data
      rows.push ((if t is '科室名称' then each[t] else fix(each[t] ? 0)) for t in titles)

    slide = pres.addSlide({sectionTitle})

    #console.log {rows}
    slide.addTable(rows, {
      #x: 0.5
      #y: 0.3 
      #w: "90%" 
      #h: 1   
      colW: [
        1.2,0.55,0.55,0.55,0.55
        0.55,0.55,0.55,0.55,0.55
        0.55,0.55,0.55,0.55,0.55
      ]
      border: {color: "CFCFCF"} 
      #margin: 0.05
      align: "left"
      valign: "middle"
      fontFace: "Segoe UI"
      fontSize: 9
      autoPage: true
      autoPageRepeatHeader: true
      autoPageCharWeight: -0.5
      autoPageLineWeight: -0.5
      autoPageHeaderRows: 1
      #autoPageSlideStartY: 0.2
      verbose: false
    })



class 散点图报告 extends 分析报告
  @chartType: -> 'scatter' #'line'


  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()
    
    #@dataPrepare()
    data = @dbValue()
    
    console.log({sectionTitle,data: @db().get("医疗服务收入三年复合增长率").get(0).value()}) if /BCG/i.test(sectionTitle)

    for indicator, arr of data
      for _indicator, _arr of data when _indicator isnt indicator
        nar = []
        arr.map (each, idx) -> 
          nar[idx] = indc for indc in  _arr when indc.unitName is each.unitName   
        slide = pres.addSlide({sectionTitle})
        #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
        #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
        #slide.background = { path: "https://some.url/image.jpg" }  # image: url
        #slide.color = "696969"  # Set slide default font color
        # EX: Styled Slide Numbers
        slide.slideNumber = { x: "98%", y: "98%", fontFace: "Courier", fontSize: 15, color: "FF33FF" }
        chartData = [
          {
            name: _indicator
            values: nar.map (each,idx)-> each[_indicator]
            #labels: arr.map (each,idx)-> each.unitName
          }
          {
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
          
          valAxisTitle: indicator,
          valAxisTitleColor: "428442",
          valAxisTitleFontSize: 10,
          showValAxisTitle: true,
          lineSize: 0,
          
          catAxisTitle: _indicator,
          catAxisTitleColor: "428442",
          catAxisTitleFontSize: 10,
          showCatAxisTitle: true,
          
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
    
    #@dataPrepare()
    data = @dbValue()
    for indicator, arr of data
      slide = pres.addSlide({sectionTitle})
      #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
      #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
      #slide.background = { path: "https://some.url/image.jpg" }  # image: url
      #slide.color = "696969"  # Set slide default font color
      # EX: Styled Slide Numbers
      slide.slideNumber = { x: "98%", y: "98%", fontFace: "Courier", fontSize: 15, color: "FF33FF" }
      chartData = [
        {
          name: indicator
          labels: arr.map (each,idx)-> each.unitName
          values: arr.map (each,idx)-> each[indicator]
        }
      ]
			
      slide.addChart(pres.ChartType[chartType], chartData, { 
        x: 0.1, y: 0.1, 
        w: "95%", h: "90%"
        showLegend: true, legendPos: 'b'
        showTitle: true, 
        title: indicator 
      })







class 雷达图报告 extends 分析报告
  @chartType: ->
    'radar'


class 多科雷达图报告 extends 雷达图报告

  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()
    
    #@dataPrepare()
    data = @dbValue()
    for indicator, arr of data
      for _indicator, _arr of data when _indicator isnt indicator
        nar = []
        arr.map (each, idx) -> 
          nar[idx] = indc for indc in  _arr when indc.unitName is each.unitName   
        slide = pres.addSlide({sectionTitle})
        #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
        #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
        #slide.background = { path: "https://some.url/image.jpg" }  # image: url
        #slide.color = "696969"  # Set slide default font color
        # EX: Styled Slide Numbers
        slide.slideNumber = { x: "98%", y: "98%", fontFace: "Courier", fontSize: 15, color: "FF33FF" }
        chartData = [
          {
            name: indicator
            labels: arr[0..19].map (each,idx)-> each.unitName
            values: arr[0..19].map (each,idx)-> each[indicator] #* 100 / arr[0][indicator]
          }
          {
            name: _indicator
            labels: nar[0..19].map (each,idx)-> each.unitName
            values: nar[0..19].map (each,idx)-> each[_indicator] #* 100 / _arr[0][_indicator]
          }
        ]
        
        slide.addChart(pres.ChartType[chartType], chartData, { 
          x: 0.1, y: 0.1, 
          w: "95%", h: "90%"
          showLegend: true, legendPos: 'b'
          showTitle: true, 
          title: "#{indicator} vs #{_indicator}" #indicator 
        })



class 单科雷达图报告 extends 雷达图报告
  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()
    
    #@dataPrepare()
    data = @dbValue()
    for unitName, arr of data
      slide = pres.addSlide({sectionTitle})
      #slide.background = { color: "F1F1F1" }  # hex fill color with transparency of 50%
      #slide.background = { data: "image/png;base64,ABC[...]123" }  # image: base64 data
      #slide.background = { path: "https://some.url/image.jpg" }  # image: url
      #slide.color = "696969"  # Set slide default font color
      # EX: Styled Slide Numbers
      slide.slideNumber = { x: "98%", y: "98%", fontFace: "Courier", fontSize: 15, color: "FF33FF" }
      chartData = [
        {
          name: unitName
          labels: arr.map (each,idx)-> each.dimension
          values: arr.map (each,idx)-> each[each.dimension]
        }
      ]
			
      slide.addChart(pres.ChartType[chartType], chartData, { 
        x: 0.1, y: 0.1, 
        w: "95%", h: "90%"
        showLegend: true, legendPos: 'b'
        showTitle: true, 
        title: unitName 
      })



# 同一个科室或医院,跟同类外部科室或本身不同年份的多维度对比
class 单科对比雷达图报告 extends 雷达图报告
  @slides: (funcOpts) ->
    {pres, sectionTitle} = funcOpts
    chartType = @chartType()







class 对标单科指标简单排序 extends 排序报告
  @dataPrepare: ->
    @dbClear().save()
    focusUnits = @focusUnits()
    for unit in focusUnits
      for indicator, valueGroup of 对标指标资料库.db().get(unit).value()
        indicatorName = "#{unit}: #{indicator}"
        @dbSet(indicatorName,({unitName:name, "#{indicatorName}":value} for name, value of valueGroup when existNumber(value)))
        @db().get(indicatorName).sort (a,b) -> b[indicatorName] - a[indicatorName]
    @dbSave()




class 院内各科指标简单排序 extends 排序报告
  @dataPrepare: ->
    @dbClear().save()
    year = @years()[0]
    指标维度 = 指标维度库.dbValue()

    for dataName, dimension of 指标维度 when dataName?
      except = /^医院$/  #/(^医院$|^大|合并)/
      arr = 院内指标资料库.dbAsArray({dataName,key:year,except})
      @dbSet(dataName, arr)
      @db().get(dataName).sort((a,b)-> b[dataName] - a[dataName])

    @dbSave()

  #@chartType: ->
  #  'bar3d'








class 对标单科指标评分排序 extends 排序报告
  @dataPrepare: ->
    @dbClear().save()
    direction = 指标导向库.dbRevertedValue()
    obj = 对标单科指标简单排序.dbValue()
    directions = [].concat(direction.逐步提高).concat(direction.逐步降低)
    for indicator, arr of obj when arr[0]? and (realIndicatorName = indicator.split(': ')[1]) in directions
      first = arr[0][indicator]
      last = arr[arr.length - 1][indicator]
      distance = last - first
      @dbSet(indicator, arr.map (unit, idx)-> 
        value = 100 * (unit[indicator] - first) / distance
        console.log {bug:"> 100",realIndicatorName,value, first} if value > 101
        switch 
          when realIndicatorName in direction.逐步提高
            unit[indicator] = value
          when realIndicatorName in direction.逐步降低
            unit[indicator] = 100 - value
        unit
      )

    @dbSave()



    



class 院内各科指标评分排序 extends 排序报告

  @dataPrepare: ->
    @dbClear().save()
    direction = 指标导向库.dbRevertedValue()    
    #return null unless direction.逐步提高?
    
    obj = 院内各科指标简单排序.dbValue()
    #@db().default(obj).save()
    directions = [].concat(direction.逐步提高).concat(direction.逐步降低)
    #console.log {directions}

    for indicator, arr of obj when arr[0]? and (indicator in directions)
      first = arr[0][indicator]
      last = arr[arr.length - 1][indicator]
      distance = last - first
      @dbSet(indicator, arr.map (unit, idx)-> 
        value = 100 * (unit[indicator] - first) / distance
        console.log({bug:"> 100",indicator,distance,value, last, first, unit}) if (value > 101) or (value is null)
        switch
          when indicator in direction.逐步提高
            unit[indicator] = value
          when indicator in direction.逐步降低
            unit[indicator] = 100 - value
        unit
      )

    @dbSave()

    #console.log direction





class 院内各科指标轮比雷达图 extends 多科雷达图报告
  @dataPrepare: ->



class 院内单科多指标评分雷达图 extends 单科雷达图报告
  @dataPrepare: ->





# 以指标维度为主体,看相关指标趋势离散度
class 院内各科维度轮比雷达图 extends 多科雷达图报告
  @dataPrepare: ->
    console.log("use 院内单科多维度评分雷达图 to prepare")
    return









# 以专科为单位,各维度雷达图
class 院内单科多维度评分雷达图 extends 单科雷达图报告
  @dataPrepare: ->
    院内各科维度轮比散点图.dbClear().save() # 临时测试绘制散点图
    院内各科维度轮比雷达图.dbClear().save()
    @dbClear().save()
    dimensions = 指标维度库.dbValue()
    focusUnits = @focusUnits()[1..]
    obj = 院内各科指标评分排序.dbValue()

    newObj = {}
    compareObj = {}
    selfObj = {}
    #self
    # step one: collect all indicators in a dimension
    # 注意: 这一步还可以根据设置好的指标权重进行预处理
    for indicator, arr of obj when dimensions[indicator]?
      dmName = dimensions[indicator]
      newObj[dmName] ?= {} 
      for each in arr 
        unit = (newObj[dmName][each.unitName] ?= {unitName:each.unitName,dmis:[]})
        weight = switch indicator
          when '医疗服务收入三年复合增长率' then 0.382 * 2
          when '医疗服务收入占全院比重' then 0.618 * 2
          when 'CMI当量DRGs组数' then 0.382 * 2
          when 'CMI值' then 0.618 * 2
          else 1
        unit.dmis.push(weight * each[indicator]) if existNumber(each[indicator])
        console.log({"bug >100: #{indicator}": each[indicator], unit}) if each[indicator] > 101
    
    # step two: calculate dimension value
    
    for dmName, dmObj of newObj
      for unitName, unitObj of dmObj
        {dmis} = unitObj
        #unitObj[dmName] 
        v = 0
        v += each for each in dmis
        
        # 代码存在bug导致服务价值和医保收入等仅留下一个指标数值,原因待查,先予以越过
        #s = dmis.length
        s = if dmName in ['医保价值','服务收入'] then 2 else dmis.length  # 临时!!!

        if s > 0
          unitObj[dmName] = v / s
          #console.log({unitName, dmName, value: unitObj[dmName],v,s}) if s < 2 
        delete(unitObj.dmis)
    
    # step three: turning into an ordered array
        selfObj[unitName] ?= []
        newUnitObj = {}
        newUnitObj.dimension = dmName
        newUnitObj[dmName] = unitObj[dmName]
        selfObj[unitName].push(newUnitObj)

      sorted = (unitObj for unitName, unitObj of dmObj).sort (a, b)-> b[dmName] - a[dmName]
      compareObj[dmName] = sorted
      ### 
      # 不需要比例放大维度分数,各指标分数提高,则维度分数提高,故不比例放大才合乎实际情况
      first = sorted[0]
      compareObj[dmName] = sorted.map (each, idx) -> 
        refined = 100 * each[dmName] / first[dmName]
        each[dmName] = refined
        each
      ### 

    @db().default(selfObj).save()
    院内各科维度轮比雷达图.db().default(compareObj).save()
    院内各科维度轮比散点图.db().default(compareObj).save() # 临时测试绘制散点图






class 院内各科维度轮比散点图 extends 散点图报告
  @dataPrepare: ->





class 院内单科多维评分散点图 extends 散点图报告
  @dataPrepare: ->




class 院内专科BCG散点图 extends 散点图报告
  @dataPrepare: ->
    @dbClear().save()
    
    obj = 院内各科指标简单排序.dbValue()
    selfObj = {}
    #@db().default(obj).save()
    for indicator, arr of obj when indicator in [
      '医疗服务收入三年复合增长率'
      '医疗服务收入占全院比重'
    ]
      selfObj[indicator] = arr
      console.log({arr})
    @db().default(selfObj).save()






class 院内专科梯队Topsis评分 extends 院内分析报告
  @dataPrepare: ->
    @dbClear().save()
    weight = 维度权重.dict()
    for unitName, unitArray of 院内单科多维度评分雷达图.dbValue()
      @dbSet(unitName, {})
      value = 0
      for object in unitArray when existNumber(v = object[object.dimension])
        @db().get(unitName).set(object.dimension, v)
        value += v * weight[object.dimension]
      @db().get(unitName).set('综合评分',value).save()



class 院内专科梯队表 extends 表格报告
  @dataPrepare: ->
    @dbClear().save()
    arrayName = @arrayName()
    @dbDefault('学科梯队':[])
    topsis = 院内专科梯队Topsis评分.dbValue()
    for unitName, unitObj of topsis when not /(医院|合并)/i.test(unitName)
      unitObj.科室名称 = unitName
      @db().get('学科梯队').push(unitObj)
    @db().get('学科梯队').sort((a,b)-> b.综合评分 - a.综合评分) 
    @dbSave()  


  @arrayName: ->
    '学科梯队'


  @titles: ->
    dict = 维度权重.dict()
    arr = (key for key, value of dict)
    arr.unshift("科室名称")
    arr.push('综合评分')
    #console.log {arr,dict}
    arr




# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports,并且可以在class定义区域下方编写生产脚本

class 生成器 extends CaseSingleton

  @run: ->
    this
      #.showDBs()
      .readExcel()
      #.showUnitNames()
      #._tryGetSomeData()
      #.showDimensions()
      .showMissingIndicatorsOrDataProblems()
      .exportRawDataToReportDB()
      
      .simpleLocalIndicatorOrdering()
      .localIndicatorBCGChart()
      .localIndicatorScoreSort()
      .localIndicatorRadarChart()
      .localTeamsTable()
      .localReport()

      .simpleCompareIndicatorOrdering()
      .compareIndicatorScoreSort()
      .compareReport()
      #.saveUtilExcel()




  # 获取最新资料,若有Excel源文件,则同时会生成json文件
  @readExcel: ->
    #console.log {院内资料库,对标资料库,指标维度库,指标导向库,名字ID库}
    v.fetchSingleJSON() for k, v of {院内资料库,对标资料库,指标维度库,指标导向库,名字ID库}
    return this



  # 查看各自 db, 以及log
  @showDBs: ->
    console.log {db: v.dbValue()} for k, v of {院内资料库,院内分析报告,对标资料库,对标分析报告,别名库,缺漏追踪库,指标维度库,名字ID库,SystemLog}
    console.log {log: v.logdb().value()} for k, v of {院内资料库,院内分析报告,对标资料库,对标分析报告,别名库,缺漏追踪库,指标维度库,名字ID库}
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
    console.log @维度列表({full: true})
    return this


  # 筛查数据
  @checkForAllIndicators: ->
    院内资料库.logdbClear().save()
    对标资料库.logdbClear().save()
    缺漏追踪库.dbClear().save()

    指标维度 = 指标维度库.dbValue()

    informal = true
    
    k1 = 'Y2020'
    k2 = '均2'
    for dataName, dimension of 指标维度 when dataName?
      for entityName in 院内资料库.dbDictKeys()
        院内资料库.getData({entityName, dataName, key:k1, informal})
      for entityName in 对标资料库.dbDictKeys()
        对标资料库.getData({entityName, dataName, key:k2, informal})
    console.log "指标数据筛查完毕"
    return this



  # 看缺多少指标数据,需要用数据计算
  @showMissingIndicatorsOrDataProblems: ->
    @checkForAllIndicators()
    
    console.log { 
      院内资料: 院内资料库.logdb().value()
      对标资料: 对标资料库.logdb().value()
      缺漏追踪: 缺漏追踪库.dbDictKeys()
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

  @localIndicatorRadarChart: ->
    院内单科多维度评分雷达图.dataPrepare()
    return this


  @localIndicatorBCGChart: ->
    院内专科BCG散点图.dataPrepare()
    return this

  @localTopsis: ->
    院内专科梯队Topsis评分.dataPrepare()
    return this

  @localTeamsTable: ->
    @localTopsis()
    院内专科梯队表.dataPrepare()
    return this


  @localReport: ->
    院内分析报告.newReport()
    return this


  @compareReport: ->
    对标分析报告.newReport()
    return this


  # 院内专科指标按照评分简单排序


  @saveUtilExcel: ->
    指标维度库.saveExcel()
    指标导向库.saveExcel()










# --------------------------------------- 以下为测试代码 ---------------------------------------- #

# 将测试代码写成 function 加入到class method
# 将以上db工具function转移到 jsonUtils 文件中,並重启coffee测试行命令,重新测试

生成器.run()
生成器
  #.showDBs()
  #.readExcel()
  #.showUnitNames()
  #._tryGetSomeData()
  
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



#
#院内单科多维度评分雷达图.dataPrepare()
#console.log @focusUnits()[1..9]
#院内分析报告.newReport()

#console.log 院内各科指标简单排序.dataPrepare()
#console.log 指标导向库.导向指标集()

###
dx = (key for key, value of 指标导向库.dbValue())
wd = (key for key, value of 指标维度库.dbValue())
console.log {
  dx_wd: dx.length - wd.length
  dx: (each for each in dx when not (each in wd))
  wd: (each for each in wd when not (each in dx))
}
###


# 先rename keys
###
# 修改平均住院日 2018年数据
for uname, idx in 院内分析报告.dbDictKeys()
  key = "#{uname}.平均住院日.y2018"
  院内分析报告.dbSet(key, 院内分析报告.dbValue(key)/(idx+1))
  console.log {uname, 平均住院日:院内分析报告.dbValue(key)}

院内分析报告.dbSave()
###
