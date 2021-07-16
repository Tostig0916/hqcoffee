e2j = require 'convert-excel-to-json'
fs = require 'fs'
ju = require './jsonUtils'
# use __dirname and __filename to create correct full path filename
path = require 'path' 
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'




class IndicatorDefVersion
  # 无法直接加class properties，只能这样曲折设置
  @addVersion: (version) ->
    IndicatorDefVersion.versions ?= {}
    IndicatorDefVersion.versions[version.versionName] ?= version
  
  @versionCount: ->
    (v for k,v of IndicatorDefVersion.versions).length

  constructor: (funcOpts) ->
		# 此处为可因版本而异的属性, 
		# 其中 评是指定量指标中，要求逐步提高或降低的指标，理论上说，这项属性应该是各版本一致的，如此设计是为防止万一
    {@versionName, @序号, @测, @评} = funcOpts
    IndicatorDefVersion.addVersion(this)





class IndicatorDef
	@fromMannualFile: (funcOpts) ->
		json = ju.jsonizedData(funcOpts)
		indicators = {}
		for versionName, mannual of json
			for k, obj of mannual
				key = k.replace('▲','') 
				indicators[key] ?= new IndicatorDef(obj)
				indicators[key].versions.push(new IndicatorDefVersion({
					versionName: versionName 
					序号: obj.序号
					测: /▲$/.test(obj.指标名称)
					评: /(降低|提高)/.test(obj.指标导向)
				}))
				# console.log key, obj
		return indicators


	@saveToJSONFile: (funcOpts) ->
		ju.write2JSON(funcOpts)

	###
	# 各版本独立陈列，备考  
	@seperatedFromMannualFile: (funcOpts) ->
		json = ju.jsonizedData(funcOpts)
		indicators = {}
		for version, mannual of json
			indicators[version] = {}
			for key, obj of mannual 
				instance = new IndicatorDef(obj)
				indicators[version][key] = instance
				# console.log key, obj
		return indicators
	###


	constructor: (funcOpts) ->
		# 以下指标在不同的版本中都是一致的，否则应该放在 IndicatorDefVersion
		{@指标名称, @指标来源='', @指标属性='', @指标导向} = funcOpts
		#[@name, @source, @guidance] = [@指标名称, @指标来源, @指标导向]
		@指标名称 = @指标名称.replace('▲','')
		@versions = []



	isValuable: ->
		/(降低|提高)/.test(@指标导向) 



	description: ->
		arr = ("版本:#{each.versionName}, 序号:#{each.序号}, 监测:#{each.测}" for each in @versions)
		return "指标:#{@指标名称}, 可评价:#{@isValuable()}, #{arr}"




module.exports = {
  IndicatorDef
  IndicatorDefVersion
}
