path = require 'path'

fn = path.join __dirname, '..','..', 'toJSON', 'singletons'
{AnyCaseSingleton} = require fn 

class CaseSingleton extends AnyCaseSingleton
  @_dbPath: ->
    path.join __dirname, 'db.json'

  @_setDefaultData: ->
    @_db.default({options: {
      client: ClientSingleton.options()
      target: TargetSingleton.options()
    }}).save()





class ClientSingleton extends CaseSingleton
  



class TargetSingleton extends CaseSingleton





console.log {options: ClientSingleton.db().get("options").value()}