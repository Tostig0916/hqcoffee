###
  将本文件复制粘贴到新项目文件夹,並填写客户名即可
###
path = require 'path'

{AnyCaseSingleton} = require path.join __dirname, '..','..', 'toJSON', 'singletons'


class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "山东中医药大学附属医院"

  @_dbhost: ->
    CaseSingleton



  @_dbPath: ->
    path.join __dirname, "#{@dbCategory()}.db.json"



  @_setDefaultData: ->
    super()
    db = @db()
    db.set("source", {})
    db.set("report", {})
    #db.save()

  
  @dbSource: ->
    @_dbSource ?= @db().get("source")


  @dbReport: ->
    @_dbReport ?= @db().get("report")



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
  for each in [对标资料库, 院内资料库]
    # be careful! [].push(each.name) will return 1 other than [each.name]
    each.dbSource().set("list", [each.name]) 
    #  .get('list')
    #  .push(each.name)
    each.dbReport().set("file", each.name)
    obj = {"key","value"}
    each.dbReport().set("obj", obj)
    console.log { 
      obj: each.name, 
      dbp: each._dbPath(), 
      db: each.db(), 
      source: each.dbSource().get('list').value()
      _source: each._dbSource.value()
      report: each.dbReport().value()
      _report: each._dbReport.value()
    }
    #console.log each.name


testSource = ->
  source = 院内资料库.dbSource()
  keys = (key for key, value of source.value())
  if keys.length is 0
    console.log "no source"
    source.set(院内资料库.fetchSingleJSON())#.save()
    console.log {source: source.value(), logs: 院内资料库.db().get('logs').value()}
  else
    console.log {keys}

testSource()
