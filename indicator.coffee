class Indicator
  constructor: (funcOpts) ->
    {@name, @indicatorValue} = funcOpts
    if indicatorDef?
      {@计量单位, @指标导向, @指标来源, @指标属性,@二级指标,@一级指标} = indicatorDef




class IndicatorValue
  constructor: (funcOpts) ->
    {@年度, @数值} = funcOpts





module.exports = {
  Indicator,
  IndicatorValue
}