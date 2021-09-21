###
  将本文件复制粘贴到新项目文件夹,並填写客户名即可
###
path = require 'path'

{AnyCaseSingleton} = require path.join __dirname, '..','..', 'toJSON', 'singletons'


class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "山东中医药大学附属医院"


  # 必须置于此处,以便随客户文件夹而建立数据库文件
  @_dbPath: ->
    path.join __dirname, "#{@name}.db.json"

  



  @options: ->
    {
      dirname: __dirname
      basename: @name
      mainKeyName: "指标名"
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      unwrap: true #false
      refining: @normalKeyName
    }





class 院内资料库 extends CaseSingleton
  



class 对标资料库 extends CaseSingleton




class 院内分析报告 extends CaseSingleton
  



class 对标分析报告 extends CaseSingleton









testDB = ->
  for each in [对标资料库, 院内资料库,院内分析报告,对标分析报告]
    # be careful! [].push(each.name) will return 1 other than [each.name]
    #  .get('list')
    #  .push(each.name)
    obj = {"key","value"}
    console.log { 
      obj: each.name, 
      dbp: each._dbPath(), 
      d: each.data(),
      l: each.logs() 
    }
    #console.log each.name

  console.log {data: 院内资料库.data().value()}


testDB()
