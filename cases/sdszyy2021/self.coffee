###
  将本文件复制粘贴到新项目文件夹,並填写客户名即可
###
path = require 'path'

fn = path.join __dirname, '..','..', 'toJSON', 'singletons'
{AnyCaseSingleton} = require fn 

class CaseSingleton extends AnyCaseSingleton
  @customerName: ->
    "山东中医药大学附属医院"

  @_dbhost: ->
    CaseSingleton



  @_dbPath: ->
    path.join __dirname, 'db.json'



  @_setDefaultData: ->
    db = @db()
    db.default({customer: @customerName()})
    db.set("source", {"Client":{}, "Target":{}})
    db.set("report", {"Client":{}, "Target":{}})
    #db.save()

  
  @dbSource: ->
    @db().get("source").get(@name)


  @dbReport: ->
    @db().get("report").get(@name)



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





class Client extends CaseSingleton
  



class Target extends CaseSingleton






test = ->
  for each in [Target, Client]
    console.log { obj: each.name, dbp: each._dbPath(), db: each.dbSource().value()}
    #console.log each.name
test()