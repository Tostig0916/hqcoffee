path = require 'path'

fn = path.join __dirname, '..','..', 'toJSON', 'singletons'
{AnyCaseSingleton} = require fn 

class CaseSingleton extends AnyCaseSingleton
  @_dbPath: ->
    path.join __dirname, 'db.json'



  @_setDefaultData: ->
    @_db.default({customer: "山东中医药大学附属医院"}).save()




  @options: ->
    {
      dirname: __dirname
      basename: @name
      mainKeyName: "指标名"
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      unwrap: true #false
      refining: @correctIndicator
    }





class Client extends CaseSingleton
  



class Target extends CaseSingleton





console.log {options: Client.db().get("customer").value()}