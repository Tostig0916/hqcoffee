path = require 'path'

fn = path.join __dirname, '..','..', 'toJSON', 'singletons'
{AnyCaseSingleton} = require fn 

class CaseSingleton extends AnyCaseSingleton
  @_dbPath: ->
    path.join __dirname, 'db.json'

  @_setDefaultData: ->
    @_db.default({options: {
      Client: Client.options()
      Target: Target.options()
    }})
      .set("#{@name}.dirname", __dirname)
      .set("#{@name}.basename", @name)
      .save()

  @options: ->
    {
      dirname: __dirname
      basename: @name
      mainKeyName: "指标名"
      headerRows: 1
      sheetStubs: true
      needToRewrite: true
      unwrap: true #false
      refining: ({json}) ->
        # 维度指标
        {indicators} = json
        cleanObj = {}
        for key, value of indicators when not /[、]/i.test(key)
          cleanObj[CommonNameSingleton.ajustedName({name:key,keep:true})] = value
        return json.indicators = cleanObj
    }





class Client extends CaseSingleton
  



class Target extends CaseSingleton





console.log {options: Client.db().get("options").value()}