class Indicator
  constructor: (funcOpts) ->
    {@name, @indicatorValue} = funcOpts
    if indicatorDef?
      {@indicatorUnit, @guidance, @source, @definition} = indicatorDef




class IndicatorValue
  constructor: (funcOpts) ->
    {@date, @number} = funcOpts





module.exports = {
  Indicator,
  IndicatorValue
}