###
  将本文件复制粘贴到新项目文件夹,並填写客户名即可
###
path = require 'path'

{AnyCaseSingleton} = require path.join __dirname, '..', '..', 'toJSON', 'singletons'
{DataManager} = require path.join __dirname,'..', '..', 'analyze','prepare'

class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "山东中医药大学附属医院测试"


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
  @normalKeyName: (funcOpts) =>
    {mainKey} = funcOpts
    if mainKey? and /测试/i.test(@customerName())
      newName = mainKey.split('.')[-1..][0]
      funcOpts.mainKey = newName  
    super(funcOpts)





class 对标资料库 extends CaseSingleton




class 院内分析报告 extends CaseSingleton
  



class 对标分析报告 extends CaseSingleton









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

testDB()
#testMore()
#testDataManager()