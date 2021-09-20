{JSONUtils} = require './jsonUtils'
path = require 'path'
StormDB = require 'stormdb'


# 抽象class 将共性放在此处
# 所有从Excel转换而来的JSON辅助文件,均为一对一关系,故均使用class一侧编程
class AnySingleton extends JSONUtils
  @db: ->
    switch
      when not @_dbhost?
        null
      when @_dbhost()._db?
        @_dbhost()._db
      else 
        engine = new StormDB.localFileEngine(@_dbPath())
        @_dbhost()._db = new StormDB(engine)
        @_dbhost()._setDefaultData()
        @_dbhost()._db




  @_dbPath: ->
    console.log "_dbPath is not implemented in #{@name}"
    null    


  @_setDefaultData: ->
    console.log "_setDefaultData is not implemented in #{@name}" 





  # 只有从Excel转换来的JSON才可以将参数 rebuild 设置为 true
  @fetchSingleJSON: (funcOpts={}) ->
    {rebuild=false} = funcOpts
    
    opts = @options()
    if rebuild
      funcOpts.needToRewrite = true
      @_json = JSONUtils.getJSON(opts)
    else
      @_json ?= JSONUtils.getJSON(opts)





  @reversedJSON: ->
    dictionary = @fetchSingleJSON()
    # 维度指标
    redict = {} 
    for key, value of dictionary
      (redict[value] ?= []).push(key)
    #console.log {redict}
    redict


    

  @addPairs: (funcOpts={}) ->
    {dict,keep=false} = funcOpts
    @fetchSingleJSON(funcOpts)
    for key, value of dict when key isnt value
      @_json[key] ?= value
    # 注意,可能会混乱
    if keep
      opts = @options()
      opts.needToRewrite = true
      opts.obj = @_json
      JSONUtils.write2JSON(opts)
    return @_json




  @normalKeyName: ({mainKey}) =>
    CommonNameSingleton.ajustedName({name:mainKey,keep:true})




  @options: ->






# 咨询案例
class AnyCaseSingleton extends AnySingleton
  


  @options: ->
    {
      folder: 'case'
      #subfolder: '' # 填写项目客户拼音简称,含年份
      header: {rows: 1}
      columnToKey: {'*':'{{columnHeader}}'}
      sheetStubs: true
      needToRewrite: false #true
      unwrap: true #false
      refining: @normalKeyName
    }









class AnyGlobalSingleton extends AnySingleton
  ###
  @db: ->
    switch
      when AnyGlobalSingleton._db? #@_db?
        AnyGlobalSingleton._db
      else
        dbPath = path.join __dirname, '..', 'data', 'db.json'
        engine = new StormDB.localFileEngine(dbPath)
        AnyGlobalSingleton._db = new StormDB(engine)
        @_setDefaultData()
        AnyGlobalSingleton._db
  ###

  @_dbhost: -> 
    AnyGlobalSingleton
  


  @_dbPath: ->
    path.join __dirname, '..', 'data', 'db.json'
      

  @_setDefaultData: ->
    @db().default({settings: {}}).save()



  @options: ->
    {
      folder: 'data'
      header: {rows: 1}
      columnToKey: {'*':'{{columnHeader}}'}
      sheetStubs: true
      needToRewrite: false #true
      unwrap: true #false 
    }






# 别名正名对照及转换
class CommonNameSingleton extends AnyGlobalSingleton
  @options: ->
    if @_options?
      @_options
    else
      opt = super()
      opt.sheets = ["symbols"]
      opt.mainKeyName = "指标名称"
      opt.basename = "别名表"
      #console.log opt
      @_options = opt



  # 获取正名,同时会增补更新别名表
  @ajustedName: (funcOpts={}) ->
    {name,keep=false} = funcOpts
    json = @fetchSingleJSON()
    correctName = json[name]
    switch
      when correctName? then correctName
      else switch
        # 正名须去掉黑三角等特殊中英文字符,否则不能作为function 名字
        when /[()（、）/▲\ ]/i.test(name)
          console.log("#{name}: 命名不应含顿号") if /、/i.test(name)
          correctName = (each for each in name when not /[()（、）/▲\ ]/.test(each)).join('')
          dict = {"#{name}":"#{correctName}"}
          @addPairs({dict,keep}) #unless /、/i.test(name)
          #console.log {name, correctName}
          correctName
        else
          name






# 此表为 singleton,只有一个instance,故可使用类侧定义
# 指标维度表
class IndicatorDimensionSingleton extends AnyGlobalSingleton
  @options: ->
    {
      folder: 'data'
      basename: "指标维度表"
      sheets: ["indicators"] # sheet 须命名为 indicators
      mainKeyName: "指标正名"
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      unwrap: true #false
      refining: @normalKeyName  
    }





class SymbolIDSingleton extends AnyGlobalSingleton
  @options: ->
    {
      folder: 'data'
      basename: "数据名id表"
      sheets: ["symbols"] # sheet should be named as this
      mainKeyName: "数据名"
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      unwrap: true #false
      refining: @normalKeyName
    }







module.exports = {
  #AnySingleton
  AnyCaseSingleton
  AnyGlobalSingleton
  
  CommonNameSingleton
  IndicatorDimensionSingleton
  SymbolIDSingleton
}

