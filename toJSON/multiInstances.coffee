JU = require './jsonUtils'


# 抽象class 将共性放在此处
# 所有从Excel转换而来的JSON辅助文件,与某instance均为一对一关系,故均使用instance一侧编程
class AnyInstance
  # 只有从Excel转换来的JSON才可以将参数 rebuild 设置为 true
  showInstanceJSON: (funcOpts={}) ->
    {rebuild=false} = funcOpts
    
    funcOpts = @options()
    if rebuild
      funcOpts.needToRewrite = true
      @_json = JU.getJSON(funcOpts)
    else
      @_json ?= JU.getJSON(funcOpts)

  options: ->





class CompanyComparingSource extends AnyInstance
  constructor: (funcOpts) ->
    {@dataFilename} = funcOpts


    

  options: ->
    {
      folder: 'data'
      basename: @dataFilename
      #sheets: ["symbols"] # keep it free
      mainKeyName: "id" # must use id to get data
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      unwrap: true #false
      
      # 将id转换为数据的正名
      #refining: ({json}) ->
      #  # 维度指标
      #  {symbols} = json
      #  cleanObj = {}
      #  for key, value of symbols when not /[、]/i.test(key)
      #    cleanObj[CommonNameSingleton.ajustedName({name:key,keep:true})] = value
      #  return json.symbols = cleanObj
    }





module.exports = {
}