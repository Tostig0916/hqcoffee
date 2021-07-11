class Indicator
  constructor: (funcOpts) ->
    {@name, @indicatorValue} = funcOpts
    if indicatorInfo?
      {@indicatorUnit, @guidance, @source, @definition} = indicatorInfo




class IndicatorValue
  constructor: (funcOpts) ->
    {@date, @number} = funcOpts





module.exports = {
  Indicator,
  IndicatorValue
}