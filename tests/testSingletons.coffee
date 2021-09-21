path = require 'path'
{
  AnyCaseSingleton
  AnyGlobalSingleton
  别名库
  指标维度库
  名字ID库
} = require path.join __dirname, '..', 'toJSON', 'singletons'


test = ->
  for each in [
    别名库
    指标维度库
    名字ID库
    ]
    console.log { obj: each.name, dbp: each._dbPath(), d: each.db()}

test()

#指标维度库.fetchSingleJSON()
#console.log 指标维度库.reversedJSON()
#console.log 别名库.fetchSingleJSON()

