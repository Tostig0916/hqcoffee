###
  将本文件复制粘贴到新项目文件夹,並填写客户名即可
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





  @getData: (funcOpts) ->
    {entityName, dataName, key} = funcOpts
    funcOpts.storm_db = @db().get(entityName)
    DataManager.getData(funcOpts)








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





# 本程序引用其他库,但其他库不应引用本文件,故不设置 module.exports

