path = require 'path'
{
  AnyCaseSingleton
  AnyGlobalSingleton
  CommonNameSingleton
  IndicatorDimensionSingleton
  SymbolIDSingleton
} = require path.join __dirname, '..', 'toJSON', 'singletons'


test = ->
  for each in [
    AnyCaseSingleton
    AnyGlobalSingleton
  
    CommonNameSingleton
    IndicatorDimensionSingleton
    SymbolIDSingleton
    ]
    console.log { obj: each.name, dbp: each._dbPath(), db: each.db()}

test()

#IndicatorDimensionSingleton.fetchSingleJSON()
#console.log IndicatorDimensionSingleton.reversedJSON()
#console.log CommonNameSingleton.fetchSingleJSON()
#console.log {
#  CommonNameSingleton: CommonNameSingleton.addPairs({
#    dict:{"某指标别名":"某指标"}, keep:false
#  })
#}

