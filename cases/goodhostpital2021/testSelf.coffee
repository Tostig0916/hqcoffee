###
  用于边测试边开发的 test driven developing
  功能完善后,将本文件代码部分复制粘贴 self.coffee 即可作为各项目的基础程序文件

  开发流程为,在terminal 运行 
  ```
    coffee -w cases/goodhostpital2021/testSelf.coffee
  ```
###
path = require 'path'

{AnyCaseSingleton} = require path.join __dirname, '..', '..', 'toJSON', 'singletons'
{DataManager} = require path.join __dirname,'..', '..', 'analyze','prepare'

class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "建水县人民医院测试"


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




  # 用于获取或计算指标数据
  @getData: (funcOpts) ->
    # 分别为单位(医院,某科),数据名,以及年度
    {entityName, dataName, key} = funcOpts
    funcOpts.storm_db = @db().get(entityName)
    DataManager.getData(funcOpts)








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





# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports



# --------------------------------------- 以下为测试代码 ---------------------------------------- #
ynzlk = 院内资料库
ynfxbg = 院内分析报告
dbzlk = 对标资料库
dbfxbg = 对标分析报告

# 查看
#console.log {ynzlk,ynfxbg,dbzlk,dbfxbg}

# 试图获取数据,若有Excel源文件,则同时会生成json文件
#v.fetchSingleJSON() for k, v of {ynzlk,ynfxbg,dbzlk,dbfxbg}

# 查看各自 db
#console.log {db: v.dbValue()} for k, v of {ynzlk,ynfxbg,dbzlk,dbfxbg}

# 研究 院内资料库
# 将院内资料库转换成为 []
# console.log ({"#{k}": v} for k,v of ynzlk.dbValue())
# 将以上代码写成 function 加入到class method
#console.log ynzlk.dbAsArray()
# 将以上db工具function转移到 jsonUtils 文件中























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