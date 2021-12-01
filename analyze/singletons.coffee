path = require 'path'
{JSONUtils} = require './jsonUtils'
StormDB = require 'stormdb'


# 抽象class 将共性放在此处
# 所有从Excel转换而来的JSON辅助文件,均为一对一关系,故均使用class一侧编程
class StormDBSingleton extends JSONUtils

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
    # keep 则保存json 文件
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





  # 依赖结构形态,使用前先观察一下结构是否一致
  @renameKey: (funcOpts) ->
    {dict, theClass} = funcOpts
    ###
    {
      '2016年': 'y2016'
      '2017年': 'y2017'
      '2018年': 'y2018'
      '2019年': 'y2019'
      '2020年': 'y2020'
      '2021年': 'y2021'
    }
    ###
    obj = theClass.dbValue()
    for unit, collection of obj
      for indicator, data of collection
        for key, value of data
          if dict[key]?
            theClass.dbSet("#{unit}.#{indicator}.#{dict[key]}", value) 
            theClass.dbDelete("#{unit}.#{indicator}.#{key}")

    theClass.dbSave()






  @normalKeyName: ({mainKey}) =>
    # keep 则保存json文件
    别名库.ajustedName({name:mainKey,keep:true})


  @options: ->












class AnyGlobalSingleton extends StormDBSingleton

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
      needToRewrite: true
      unwrap: true #false 
      renaming: @normalKeyName
    }






# 别名正名对照及转换
class 别名库 extends AnyGlobalSingleton

  # 获取正名,同时会增补更新别名表
  @ajustedName: (funcOpts={}) ->
    {name,keep=false} = funcOpts
    json = @fetchSingleJSON()
    switch
      when (correctName = json[name])?
        console.log {name, correctName}
        correctName
      
      else switch
        # 正名须去掉黑三角等特殊中英文字符,否则不能作为function 名字
        when /[*↑↓()（、）/▲\ ]/i.test(name)
          console.log("#{name}: 命名不应含顿号") if /、/i.test(name)
          cleanName = (each for each in name when not /[*↑↓()（、）/▲\ ]/.test(each)).join('')
          unless (correctName = json[cleanName])?
            dict = {"#{name}":"#{cleanName}"}
            @_addPairs({dict,keep}) #unless /、/i.test(name)
          #console.log {name, correctName}
          correctName ? cleanName
        else
          name


  # 别名库自己无须改名
  @normalKeyName: ({mainKey}) =>
    return mainKey


  @_dbPath: ->
    path.join __dirname, "..", "data","JSON" ,"别名库.json"

  @options: ->
    super()
    @_options.basename = '别名库'
    @_options.needToRewrite = false
    @_options.rebuild = false
    return @_options



  @fetchSingleJSON: (funcOpts={}) ->
    {rebuild=false} = funcOpts    
    opts = @options()
    opts.needToRewrite = false

    if rebuild
      @_json = @getJSON(opts)
    else
      @_json ?= @getJSON(opts)





# 此表为 singleton,只有一个instance,故可使用类侧定义
###
# 指标维度表
class 三级指标对应二级指标 extends AnyGlobalSingleton
    

class 指标导向库 extends AnyGlobalSingleton
  @导向指标集: ->
    @dbRevertedValue()
###

class 名字ID库 extends AnyGlobalSingleton




class 简称库 extends AnyGlobalSingleton




#class 缺漏追踪库 extends AnyGlobalSingleton















module.exports = {
  StormDBSingleton
  #AnyGlobalSingleton  
  别名库
  名字ID库
}

