###
  用于边测试边开发的 test driven developing
  功能完善后,将本文件代码部分复制粘贴 self.coffee 即可作为各项目的基础程序文件

  开发流程为,在terminal 运行 
  ```
    coffee -w cases/goodhostpital2021/testSelf.coffee
  ```
###
util = require 'util'
path = require 'path'

{MakePPTReport} = require path.join __dirname, '..', '..', 'usepptxgen','pptxgenUtils'  

{
  AnyCaseSingleton
  SystemLog
  缺漏追踪库
  别名库
  指标维度库
  指标导向库
  名字ID库
} = require path.join __dirname, '..', '..', 'toJSON', 'singletons'

class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "山东中医药大学"


  # 必须置于此处,以便随客户文件夹而建立数据库文件
  @_dbPath: ->
    path.join __dirname, "#{@name}.json"

  
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
      refining: @normalKeyName
    }



class 资料库 extends CaseSingleton
  @years: ->
    院内资料库.years()



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




class 分析报告 extends CaseSingleton
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
        pres.addSection({title: section.name})
        section.slides({pres})

    MakePPTReport.newReport(opts)



  @dataPrepare: ->
 





class 院内分析报告 extends 分析报告

  @sections: ->
    [
      院内专科指标简单排序
      院内专科指标评分排序
      院内专科指标评分雷达图
      院内专科BCG散点图
      院内专科梯队表格
    ]




  @slides:(funcOpts) ->
    {pres} = funcOpts
    #console.log {slides: @name}







  @rawDataToIndicators: ->
    @dbClear().save()
    指标维度 = 指标维度库.dbValue()
    years = 院内资料库.years()
    units = 院内资料库.localUnits()
    informal = true
    for dataName, dimension of 指标维度 when dataName?
      for entityName in units 
        for year in years
          key = year
          ownData = 院内资料库.getData({entityName, dataName, key, informal})
          @dbSet("#{entityName}.#{dataName}.#{year}", ownData) #if ownData
    @dbSave()
    console.log "院内分析报告: 指标数据移动完毕"
    return this





class 院内专科指标简单排序 extends 院内分析报告
  @dataPrepare: ->
    @dbClear().save()
    year = 院内资料库.years()[0]
    localUnits = 院内资料库.localUnits()
    指标维度 = 指标维度库.dbValue()

    for dataName, dimension of 指标维度 when dataName?
      arr = 院内分析报告.dbAsArray({dataName,key:year})
      _arr = arr.sort (a,b)-> 
        try
          b[dataName] - a[dataName]
        catch error
          -1
      @dbSet(dataName, _arr)

    @dbSave()




  @slides: (funcOpts) ->
    {pres} = funcOpts
    chartType = 'bar3d'
    
    #@dataPrepare()
    data = @dbValue()
    for indicator, arr of data
      slide = pres.addSlide({@name})
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








    



class 院内专科指标同向评分 extends 院内分析报告
  @dataPrepare: ->
    @dbClear().save()
    direction = 指标导向库.dbRevertedValue()
    #@db().default(obj).save()
    obj = 院内专科指标简单排序.dbValue()
    for indicator, arr of obj
      switch 
        when indicator in direction.逐步提高
          @dbSet(indicator, arr)
        when indicator in direction.逐步降低
          @dbSet(indicator, arr)
    @dbSave()

    #console.log direction





class 院内专科指标评分排序 extends 院内分析报告

class 院内专科指标评分雷达图 extends 院内分析报告

class 院内专科BCG散点图 extends 院内分析报告

class 院内专科梯队Topsis评分 extends 院内分析报告

class 院内专科梯队表格 extends 院内分析报告
  


class 对标分析报告 extends 分析报告
  @rawDataToIndicators: ->
    @dbClear().save()
    units = 对标资料库.dbDictKeys()
    指标维度 = 指标维度库.dbValue()
    对标项 = ['均1','均2','某A','某B']
    informal = true
    for dataName, dimension of 指标维度 when dataName?     
      for entityName in units
        for item in 对标项
          key = item
          otherData = 对标资料库.getData({entityName, dataName, key, informal})
          @dbSet("#{entityName}.#{dataName}.#{key}", otherData) #if otherData
    
    @dbSave()
    console.log "对标分析报告: 指标数据移动完毕"
    return this    




# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports,并且可以在class定义区域下方编写生产脚本

class 生成器 extends CaseSingleton

  @dataPrepare: ->
    this
      .showDBs()
      .readExcel()
      .showUnitNames()
      ._tryGetSomeData()
      .showUnitNames()
      .checkForAllIndicators()
      .showMissingIndicatorsOrDataProblems()
      .exportRawDataToReportDB()
      .simpleLocalIndicatorOrdering()
      .localIndicatorSameDirection()
      .localIndicatorScoreSort()
      .localIndicatorRadarChart()
      .localIndicatorBCGChart()
      .localTeamsTable()
      .localReport()
      .compareReport()




  # 获取最新资料,若有Excel源文件,则同时会生成json文件
  @readExcel: ->
    console.log {院内资料库,对标资料库,指标维度库,指标导向库,名字ID库}
    v.fetchSingleJSON() for k, v of {院内资料库,对标资料库,指标维度库,指标导向库,名字ID库}
    return this



  # 查看各自 db, 以及log
  @showDBs: ->
    console.log {db: v.dbValue()} for k, v of {院内资料库,院内分析报告,对标资料库,对标分析报告,别名库,缺漏追踪库,指标维度库,名字ID库,SystemLog}
    console.log {log: v.logdb().value()} for k, v of {院内资料库,院内分析报告,对标资料库,对标分析报告,别名库,缺漏追踪库,指标维度库,名字ID库}
    return this



  # 看看有多少科室数据
  @showUnitNames: ->
    localUnits = 院内资料库.localUnits()
    compareUnits = 对标资料库.dbDictKeys()
    years = 院内资料库.years()
    console.log {localUnits, compareUnits, years}
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
    console.log { 
      院内资料: 院内资料库.logdb().value()
      对标资料: 对标资料库.logdb().value()
      缺漏追踪: 缺漏追踪库.dbDictKeys()
    }
    return this



  # 研究 院内资料库
  # 先将指标计算结果存入报告db
  @exportRawDataToReportDB: ->
    院内分析报告.rawDataToIndicators()
    对标分析报告.rawDataToIndicators()
    return this

  
  

  # 院内专科指标简单排序存储备用
  @simpleLocalIndicatorOrdering: ->
    院内专科指标简单排序.dataPrepare()
    return this

  

  @localIndicatorSameDirection: ->
    院内专科指标同向评分.dataPrepare()
    return this


  @localIndicatorScoreSort: ->
    院内专科指标评分排序.dataPrepare()
    return this


  @localIndicatorRadarChart: ->
    院内专科指标评分雷达图.dataPrepare()
    return this


  @localIndicatorBCGChart: ->
    院内专科BCG散点图.dataPrepare()
    return this



  @localTeamsTable: ->
    院内专科梯队表格.dataPrepare()
    return this


  @localReport: ->
    院内分析报告.newReport()
    return this


  @compareReport: ->
    对标分析报告.newReport()
    return this


  # 院内专科指标按照评分简单排序













# --------------------------------------- 以下为测试代码 ---------------------------------------- #

# 将测试代码写成 function 加入到class method
# 将以上db工具function转移到 jsonUtils 文件中,並重启coffee测试行命令,重新测试

#生成器.run()

生成器
  #.showDBs()
  #.readExcel()
  #.showUnitNames()
  #._tryGetSomeData()
  #.checkForAllIndicators()
  #.showMissingIndicatorsOrDataProblems()
  #.exportRawDataToReportDB()
  #.simpleLocalIndicatorOrdering()
  .localIndicatorSameDirection()
  #.localIndicatorScoreSort()
  #.localIndicatorRadarChart()
  #.localIndicatorBCGChart()
  #.localTeamsTable()
  #.localReport()
  #.compareReport()




#院内分析报告.newReport()

#console.log 院内专科指标简单排序.dataPrepare()
#console.log 指标导向库.导向指标集()



# 先rename keys
###
# 修改平均住院日 2018年数据
for uname, idx in 院内分析报告.dbDictKeys()
  key = "#{uname}.平均住院日.y2018"
  院内分析报告.dbSet(key, 院内分析报告.dbValue(key)/(idx+1))
  console.log {uname, 平均住院日:院内分析报告.dbValue(key)}

院内分析报告.dbSave()
###




















###
testDB = ->
  院内资料库.fetchSingleJSON() #

testMore = ->
  for each in [对标资料库, 院内资料库,院内分析报告,对标分析报告]
    # be careful! [].push(each.name) will return 1 other than [each.name]
    #  .get('list')
    #  .push(each.name)
    obj = {"key","value"}
    console.log { 
      #obj: each.fetchSingleJSON() 
      dbp: each._dbPath(),
      d: each.db() 
    }
    #console.log each.name

  console.log {
    data: 院内资料库.db()
  }

testDataManager = ->
  storm_db = 院内资料库.db().get("医院")
  console.log {出院患者手术占比: DataManager.getData({dataName:"出院患者手术占比", storm_db, key:"2018年" })}
  console.log {出院患者手术占比:院内资料库.getData({entityName:"胸外科", dataName:"出院患者四级手术占比", key:"2019年"})}

#testDB()
#testMore()
testDataManager()
###

###

###