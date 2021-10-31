class IndicatorBase 
  constructor: (funcOpts) ->
    {@key, @weight=0, @value, @score, @ratio}




class DimensionBase extends IndicatorBase
  constructor: (funcOpts) ->
    super(funcOpts)
    @value = @score


class Indicator extends IndicatorBase


class Dimension extends DimensionBase





module.exports = {
  Indicator
  Dimension
}