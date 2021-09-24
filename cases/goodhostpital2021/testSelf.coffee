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
  资料阙如
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
  # 仅用于建水县的一份国考数据资料,但是演示了一种定制程序的方法
  @normalKeyName: (funcOpts) =>
    {mainKey} = funcOpts
    if mainKey? and /测试/i.test(@customerName())
      newName = mainKey.split('.')[-1..][0]
      funcOpts.mainKey = newName  
    super(funcOpts)





class 对标资料库 extends CaseSingleton




class 院内分析报告 extends CaseSingleton
  



class 对标分析报告 extends CaseSingleton





# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports,并且可以在class定义区域下方编写生产脚本



# --------------------------------------- 以下为测试代码 ---------------------------------------- #


# 将测试代码写成 function 加入到class method
# 将以上db工具function转移到 jsonUtils 文件中,並重启coffee测试行命令,重新测试

# 查看
#console.log {院内资料库,院内分析报告,对标资料库,对标分析报告}

# 获取最新资料,若有Excel源文件,则同时会生成json文件
v.fetchSingleJSON() for k, v of {院内资料库,院内分析报告,对标资料库,对标分析报告,资料阙如,指标维度库,指标导向库,名字ID库}

# 查看各自 db
#console.log {db: v.dbValue()} for k, v of {院内资料库,院内分析报告,对标资料库,对标分析报告,别名库,资料阙如,指标维度库,名字ID库}

# 添加,再清空 log
#SystemLog.db().get(院内资料库.name).set("y",{a:1}).save()

# 研究 院内资料库
# 先将结果存入报告db
##
#院内分析报告.dbClear().save()
#院内分析报告.dbDefault(院内资料库.dbValue()).save()
#console.log 院内分析报告:院内分析报告.dbValue()
##

# 测试一下 getData 平均住院日
#[entityName,dataName,key] = ['医院','编制床位','Y2018']
#console.log {entityName,dataName,key,data: 院内分析报告.getData({entityName,dataName,key})}

# 看缺多少指标数据,需要用数据计算
# 看看有多少科室数据
#units = 院内分析报告.dbDictKeys()
#console.log {units}
#console.log 院内分析报告.dbLog().value()

###
资料阙如.dbClear().save()
院内分析报告.dbLogClear().save()
zbwd = 指标维度库.dbValue()
#console.log {zbwd}

key = 'Y2020'
for dataName, dimension of zbwd when dataName?
  for entityName in 院内分析报告.dbDictKeys()
    院内分析报告.getData({entityName, dataName, key})
###

# 先rename keys
###
dict = {
  '2016年': 'y2016'
  '2017年': 'y2017'
  '2018年': 'y2018'
  '2019年': 'y2019'
  '2020年': 'y2020'
  '2021年': 'y2021'
}
obj = 院内分析报告.dbValue()
for unit, collection of obj
  for indicator, data of collection
    for key, value of data
      if dict[key]?
        院内分析报告.dbSet("#{unit}.#{indicator}.#{dict[key]}", value) 
        院内分析报告.dbDelete("#{unit}.#{indicator}.#{key}")

院内分析报告.dbSave()
newObj = 院内分析报告.dbValue()
###

###
# 修改平均住院日 2018年数据
for uname, idx in 院内分析报告.dbDictKeys()
  key = "#{uname}.平均住院日.y2018"
  院内分析报告.dbSet(key, 院内分析报告.dbValue(key)/(idx+1))
  console.log {uname, 平均住院日:院内分析报告.dbValue(key)}

院内分析报告.dbSave()
###

# 将资料库转换成为 []

###
arr = 院内分析报告.dbAsArray()
console.log arr
院内分析报告.dbClear().save()
院内分析报告.dbDefault({data:arr}).save()
###

# 根据平均住院日 y2018 数据排序
#院内分析报告.db().get("data").sort((a,b)-> a.平均住院日.y2018 - b.平均住院日.y2018)
#院内分析报告.dbSave()
#console.log 院内分析报告.db().get('data').get(0).value().unitName #.平均住院日.y2018




















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