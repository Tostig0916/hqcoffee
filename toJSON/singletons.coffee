path = require 'path'
{DataManager} = require path.join __dirname,'..', 'analyze','prepare'
{JSONUtils} = require './jsonUtils'
StormDB = require 'stormdb'


# 抽象class 将共性放在此处
# 所有从Excel转换而来的JSON辅助文件,均为一对一关系,故均使用class一侧编程
class AnySingleton extends JSONUtils
  @dbLog: ->
    SystemLog.db().get(@name)


  @dbLogClear: ->
    SystemLog.db().get(@name).set({})
    return SystemLog.db()


  # 只有从Excel转换来的JSON才可以将参数 rebuild 设置为 true
  @fetchSingleJSON: (funcOpts={}) ->
    {rebuild=false} = funcOpts
    
    opts = @options()
    if rebuild
      opts.needToRewrite = true
      @_json = @getJSON(opts)
    else
      @_json ?= @getJSON(opts)






  @reversedJSON: ->
    dictionary = @fetchSingleJSON()
    # 维度指标
    redict = {} 
    for key, value of dictionary
      (redict[value] ?= []).push(key)
    #console.log {redict}
    redict


    

  @_addPairs: (funcOpts={}) ->
    {dict,keep=false} = funcOpts
    @fetchSingleJSON(funcOpts)
    for key, value of dict when key isnt value
      @_json[key] ?= value
    # 注意,可能会混乱
    if keep
      opts = @options()
      opts.needToRewrite = true
      opts.obj = @_json
      @write2JSON(opts)
    return @_json




  @normalKeyName: ({mainKey}) =>
    newName = 别名库.ajustedName({name:mainKey,keep:true})
    #console.log({mainKey,newName}) if /包括药剂师和临床药师/i.test(mainKey)
    newName




  @options: ->












class AnyGlobalSingleton extends AnySingleton

  @_dbPath: ->
    path.join __dirname, "..", "data","JSON" ,"#{@name}.json"



  @options: ->
    # 此处不可以记入变量,是否影响子法随宜重新定义?
    @_options ?= {
      folder: 'data'
      basename: @name
      header: {rows: 1}
      mainKeyName: "数据名"
      columnToKey: {'*':'{{columnHeader}}'}
      sheetStubs: true
      needToRewrite: false #true
      unwrap: true #false 
      refining: @normalKeyName
    }






# 别名正名对照及转换
class 别名库 extends AnyGlobalSingleton

  # 获取正名,同时会增补更新别名表
  @ajustedName: (funcOpts={}) ->
    {name,keep=false} = funcOpts
    json = @fetchSingleJSON()
    correctName = json[name]
    switch
      when correctName? then correctName
      else switch
        # 正名须去掉黑三角等特殊中英文字符,否则不能作为function 名字
        when /[*()（、）/▲\ ]/i.test(name)
          console.log("#{name}: 命名不应含顿号") if /、/i.test(name)
          correctName = (each for each in name when not /[*()（、）/▲\ ]/.test(each)).join('')
          dict = {"#{name}":"#{correctName}"}
          @_addPairs({dict,keep}) #unless /、/i.test(name)
          #console.log {name, correctName}
          correctName
        else
          name



  @normalKeyName: ({mainKey}) =>
    return mainKey






# 此表为 singleton,只有一个instance,故可使用类侧定义
# 指标维度表
class 指标维度库 extends AnyGlobalSingleton
    






class 名字ID库 extends AnyGlobalSingleton




class 简称库 extends AnyGlobalSingleton




class SystemLog extends AnyGlobalSingleton




# 咨询案例
class AnyCaseSingleton extends AnySingleton
  # @_dbPath 涉及到目录位置,似乎无法在此设置

  # 用于获取或计算指标数据
  @getData: (funcOpts) ->
    # 分别为单位(医院,某科),数据名,以及年度
    {entityName, dataName, key} = funcOpts
    funcOpts.storm_db = @db().get(entityName)
    funcOpts.log_db = SystemLog.db().get(@name)
    DataManager.getData(funcOpts)













module.exports = {
  #AnySingleton
  AnyCaseSingleton
  #AnyGlobalSingleton
  
  SystemLog
  别名库
  指标维度库
  名字ID库
}

