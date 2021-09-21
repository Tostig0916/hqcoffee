###
  将本文件复制粘贴到新项目文件夹,並填写客户名即可
###
path = require 'path'

{AnyCaseSingleton} = require path.join __dirname, '..','..', 'toJSON', 'singletons'


class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "山东中医药大学附属医院测试"


  # 必须置于此处,以便随客户文件夹而建立数据库文件
  @_dbPath: ->
    path.join __dirname, "#{@name}.db.json"

  



  @options: ->
    @_options ?= {
      dbOnly: true
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
  院内资料库.data()




test2 = ->
  for each in [对标资料库, 院内资料库,院内分析报告,对标分析报告]
    # be careful! [].push(each.name) will return 1 other than [each.name]
    #  .get('list')
    #  .push(each.name)
    obj = {"key","value"}
    console.log { 
      obj: each.fetchSingleJSON() 
      #dbp: each._dbPath(), 
      #d: each.db_data()#.value(),
      #l: each.db_logs().value()
    }
    #console.log each.name

  console.log {
    data: 院内资料库.db_data().value()
  }


testDB()
