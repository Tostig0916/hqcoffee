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
  别名库
  指标维度库
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
      needToRewrite: true #true
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
ynzlk = 院内资料库
ynbg = 院内分析报告
dbzlk = 对标资料库
dbbg = 对标分析报告
bmk = 别名库
zbwdk = 指标维度库
mzidk = 名字ID库

# 将测试代码写成 function 加入到class method
# 将以上db工具function转移到 jsonUtils 文件中,並重启coffee测试行命令,重新测试

# 查看
#console.log {ynzlk,ynbg,dbzlk,dbbg}

# 试图获取数据,若有Excel源文件,则同时会生成json文件
# v.fetchSingleJSON() for k, v of {ynzlk,ynbg,dbzlk,dbbg,SystemLog}

# 查看各自 db
#console.log {db: v.dbValue()} for k, v of {ynzlk,ynbg,dbzlk,dbbg,bmk,zbwdk,mzidk}

# 清空 log
#SystemLog.dbClear().save()
#SystemLog.db().get(ynzlk.name).set("y",{a:1}).save()

# 研究 院内资料库
# 将结果存入报告db
#console.log ynbg.dbValue()
#ynbg.dbClear()
#console.log ynbg.dbDefault(ynzlk.dbValue()).save()

# 看看有多少科室数据
#console.log {单位:ynbg.dbDictKeys()}

# 测试一下 getData 平均住院日
#[entityName,dataName,key] = ['医院','编制床位','Y2018']
#[entityName,dataName,key] = ['心内科','平均住院日', 'Y2018']
#console.log {entityName,dataName,key,data: ynbg.getData({entityName,dataName,key})}
# 看缺多少指标数据,需要用数据计算
##
[entityName,dataName,key] = ['医院','平均住院日', 'Y2020']
zbwd = zbwdk.dbValue()
ynbg.dbClear().save()
for indicator, dimension of zbwd
  dataName = indicator
  ynbg.getData({entityName:'医院',dataName,key})
##

# ynbg.dbClear().save()

###
for indicator, dimension of zbwd
  dataName = indicator
  for entityName in ynbg.dbDictKeys()
    ynbg.getData({entityName, dataName, key})
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
obj = ynbg.dbValue()
for unit, collection of obj
  for indicator, data of collection
    for key, value of data
      if dict[key]?
        ynbg.dbSet("#{unit}.#{indicator}.#{dict[key]}", value) 
        ynbg.dbDelete("#{unit}.#{indicator}.#{key}")

ynbg.dbSave()
newObj = ynbg.dbValue()
###

###
# 修改平均住院日 2018年数据
for uname, idx in ynbg.dbDictKeys()
  key = "#{uname}.平均住院日.y2018"
  ynbg.dbSet(key, ynbg.dbValue(key)/(idx+1))
  console.log {uname, 平均住院日:ynbg.dbValue(key)}

ynbg.dbSave()
###

# 将资料库转换成为 []

###
arr = ynbg.dbAsArray()
console.log arr
ynbg.dbClear().save()
ynbg.dbDefault({data:arr}).save()
###

# 根据平均住院日 y2018 数据排序
#ynbg.db().get("data").sort((a,b)-> a.平均住院日.y2018 - b.平均住院日.y2018)
#ynbg.dbSave()
#console.log ynbg.db().get('data').get(0).value().unitName #.平均住院日.y2018




















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