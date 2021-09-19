JU = require './jsonUtils'

hsj = '▲'

# 抽象class 将共性放在此处
# 所有从Excel转换而来的JSON辅助文件,均为一对一关系,故均使用class一侧编程
class AnySingleton
  # 只有从Excel转换来的JSON才可以将参数 rebuild 设置为 true
  @fetchSingleJSON: (funcOpts={}) ->
    {rebuild=false} = funcOpts
    
    opts = @options()
    if rebuild
      funcOpts.needToRewrite = true
      @_json = JU.getJSON(opts)
    else
      @_json ?= JU.getJSON(opts)




  @addPairs: (funcOpts) ->
    {dict,keep=false} = funcOpts
    @fetchSingleJSON(funcOpts)
    for key, value of dict when key isnt value
      @_json[key] ?= value
    # 注意,可能会混乱
    if keep
      opts = @options()
      opts.needToRewrite = true
      opts.obj = @_json
      JU.write2JSON(opts)
    return @_json
    

  @options: ->










# 别名正名对照及转换
class CommonNameSingleton extends AnySingleton
  @options: ->
    {
      folder: 'data'
      basename: '别名表'
      headerRows: 1
      sheetStubs: true
      needToRewrite: false #true
      mainKeyName: "指标名称"
      unwrap: true #false 
    }

  @ajustedName: (funcOpts) ->
    {name,keep=false} = funcOpts
    json = @fetchSingleJSON()
    correctName = json[name]
    switch
      when correctName? then correctName
      else switch
        # 正名须去掉黑三角等特殊中英文字符,否则不能作为function 名字
        when /[()（）/▲\ ]/i.test(name)
          correctName = (each for each in name when not /[()（）/▲\ ]/.test(each)).join('')
          dict = {"#{name}":"#{correctName}"}
          @addPairs({dict,keep})
          #console.log {name, correctName}
          correctName
        else
          name




# 此表为 singleton,只有一个instance,故可使用 class 一侧定义
# 指标维度表
class IndicatorDimensionSingleton extends AnySingleton
  @options: ->
    {
      basename: "指标维度表"
      #sheets: ["indicators"]
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      mainKeyName: "指标正名"
      unwrap: true #false
      refining: ({json}) ->
        # 维度指标
        {indicators} = json
        cleanObj = {}
        for key, value of indicators when not /[、]/i.test(key)
          cleanObj[CommonNameSingleton.ajustedName({name:key,keep:true})] = value
        return json.indicators = cleanObj
    }






# 各维度,及指标
class DimensionIndicatorSingleton extends AnySingleton
  
  # 从指标-维度 JSON 产生维度-指标 JSON
  @abstract: (funcOpts={}) ->
    {indicators=IndicatorDimensionSingleton.fetchSingleJSON()} = funcOpts
    # 维度指标
    dimensions = {} 
    for key, value of indicators
      (dimensions[value] ?= []).push(key)
    #console.log {dimensions}
    @_json = dimensions
    




module.exports = {
  CommonNameSingleton
  DimensionIndicatorSingleton
  IndicatorDimensionSingleton
}
