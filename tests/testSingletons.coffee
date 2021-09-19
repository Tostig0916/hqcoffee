path = require 'path'
{
  IndicatorDimensionSingleton, DimensionIndicatorSingleton, CommonNameSingleton
} = require path.join __dirname, '..', 'toJSON', 'singletons'


IndicatorDimensionSingleton.fetchSingleJSON({rebuild:false})

#console.log {
#  CommonNameSingleton: CommonNameSingleton.addPairs({
#    dict:{"某指标别名":"某指标"}, keep:false
#  })
#}
json = DimensionIndicatorSingleton.abstract()
#console.log json 

