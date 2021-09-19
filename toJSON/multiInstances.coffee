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




module.exports = {
}
