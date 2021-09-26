###
  用于边测试边开发的 test driven developing
  功能完善后,将本文件代码部分复制粘贴 self.coffee 即可作为各项目的基础程序文件

  开发流程为,在terminal 运行 
  ```
    coffee -w cases/goodhostpital2021/testSelf.coffee
  ```
###
path = require 'path'

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







class 院内资料库 extends CaseSingleton
  @localUnits: ->
    @dbDictKeys()
  
  @dataNames: -> 
    (k for k, v of 院内资料库.dbValue()[@localUnits[0]]) 
  
  @years: -> 
    years = (k for k, v of 院内资料库.dbValue()[@localUnits[0]][dataNames[0]] when /^y/i.test(k))
    years = years.sort((x,y)-> if x > y then -1 else 1)

 
 
 
 
  # 仅用于建水县的一份国考数据资料,但是演示了一种定制程序的方法
  @normalKeyName: (funcOpts) =>
    {mainKey} = funcOpts
    if mainKey? and /测试/i.test(@customerName())
      newName = mainKey.split('.')[-1..][0]
      funcOpts.mainKey = newName  
    super(funcOpts)





class 对标资料库 extends CaseSingleton





class 院内报告库 extends CaseSingleton


  class 院内专科指标简单排序库 extends 院内报告库


  class 院内专科指标同向评分库 extends 院内报告库

  class 院内专科指标评分排序库 extends 院内报告库

  class 院内专科指标评分雷达图库 extends 院内报告库

  class 院内专科BCG散点图库 extends 院内报告库

  class 院内专科梯队Topsis评分库 extends 院内报告库

  class 院内专科梯队表格库 extends 院内报告库
  


class 对标报告库 extends CaseSingleton





# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports,并且可以在class定义区域下方编写生产脚本

class 生成器 extends CaseSingleton

  @run: ->
    this
      .showDBs()
      .readExcel()
      .showUnitNames()
      ._tryGetSomeData()
      .showUnitNames()
      .checkForAllIndicators()
      .showMissingIndicatorsOrDataProblems()
      .exportRawDataToReportDB()
    




  # 获取最新资料,若有Excel源文件,则同时会生成json文件
  @readExcel: ->
    console.log {院内资料库,对标资料库,指标维度库,指标导向库,名字ID库}
    v.fetchSingleJSON() for k, v of {院内资料库,对标资料库,指标维度库,指标导向库,名字ID库}
    return this



  # 查看各自 db, 以及log
  @showDBs: ->
    console.log {db: v.dbValue()} for k, v of {院内资料库,院内报告库,对标资料库,对标报告库,别名库,缺漏追踪库,指标维度库,名字ID库,SystemLog}
    console.log {log: v.logdb().value()} for k, v of {院内资料库,院内报告库,对标资料库,对标报告库,别名库,缺漏追踪库,指标维度库,名字ID库}
    return this



  # 看看有多少科室数据
  @showUnitNames: ->
    localUnits = 院内资料库.localUnits()
    dataNames = 院内资料库.dataNames() 
    years = 院内资料库.years()

    compareUnits = 对标资料库.dbDictKeys()
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
    院内报告库.dbClear().save()
    对标报告库.dbClear().save()
    ###
    院内报告库.dbDefault(院内资料库.dbValue()).save()
    对标报告库.dbDefault(对标资料库.dbValue()).save()
    console.log {院内报告库:院内报告库.dbValue(), 对标报告库:对标报告库.dbValue()}
    ###
    @showUnitNames()
    指标维度 = 指标维度库.dbValue()
    对标项 = ['均1','均2','某A','某B']
    informal = true
    for dataName, dimension of 指标维度 when dataName?
      for entityName in 院内资料库.dbDictKeys()
        for year in @years
          key = year
          ownData = 院内资料库.getData({entityName, dataName, key, informal})
          院内报告库.dbSet("#{entityName}.#{dataName}.#{key}", ownData) #if ownData
      for entityName in 对标资料库.dbDictKeys()
        for item in 对标项
          key = item
          otherData = 对标资料库.getData({entityName, dataName, key, informal})
          对标报告库.dbSet("#{entityName}.#{dataName}.#{key}", otherData) #if otherData
    院内报告库.dbSave()
    对标报告库.dbSave()
    console.log "指标数据移动完毕"
    return this

  
  

  # 院内专科指标简单排序存储备用


  # 院内专科指标同向化及评分


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




# 先rename keys
###
# 修改平均住院日 2018年数据
for uname, idx in 院内报告库.dbDictKeys()
  key = "#{uname}.平均住院日.y2018"
  院内报告库.dbSet(key, 院内报告库.dbValue(key)/(idx+1))
  console.log {uname, 平均住院日:院内报告库.dbValue(key)}

院内报告库.dbSave()
###

# 将资料库转换成为 []

###
arr = 院内报告库.dbAsArray()
console.log arr
院内报告库.dbClear().save()
院内报告库.dbDefault({data:arr}).save()
###

# 根据平均住院日 y2018 数据排序
#院内报告库.db().get("data").sort((a,b)-> a.平均住院日.y2018 - b.平均住院日.y2018)
#院内报告库.dbSave()
#console.log 院内报告库.db().get('data').get(0).value().unitName #.平均住院日.y2018




















###
testDB = ->
  院内资料库.fetchSingleJSON() #

testMore = ->
  for each in [对标资料库, 院内资料库,院内报告库,对标报告库]
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