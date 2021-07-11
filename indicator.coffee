class Indicator
  constructor: (funcOpts) ->
    {@name, @indicatorValue} = funcOpts
    if indicatorInfo?
      {@indicatorUnit, @guidance, @source, @definition} = indicatorInfo




class IndicatorValue
  constructor: (funcOpts) ->
    {@date, @number} = funcOpts




class indicatorInfo
  @fromMannualFile: (funcOpts) ->
    {path} = funcOpts
    # read from mannual file and turn it into a dictionary

  constructor: (funcOpts) ->
    {@name, @source, @guidance} = funcOpts

module.exports = {
  Indicator,
  IndicatorValue
}