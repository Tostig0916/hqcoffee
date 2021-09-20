path = require 'path'
{
  IndicatorDimensionSingleton, CommonNameSingleton
} = require path.join __dirname, '..', 'toJSON', 'singletons'


IndicatorDimensionSingleton.fetchSingleJSON()
#console.log IndicatorDimensionSingleton.reversedJSON()
#console.log CommonNameSingleton.fetchSingleJSON()
#console.log {
#  CommonNameSingleton: CommonNameSingleton.addPairs({
#    dict:{"某指标别名":"某指标"}, keep:false
#  })
#}

