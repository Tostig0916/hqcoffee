e2j = require 'convert-excel-to-json'
fs = require 'fs'
JU = require './jsonUtils'
# use __dirname and __filename to create correct full path filename
path = require 'path' 
pptxgen = require 'pptxgenjs'
xlsx = require 'json-as-xlsx'




class IndicatorDefVersion
	# 无法直接加class properties，只能这样曲折设置
	@addVersion: (version) ->
		@versions ?= {}
		@versions[version.versionName] ?= version

	@versionCount: ->
		(v for k,v of @versions).length

	
	
	constructor: (funcOpts) ->
		# 此处为可因版本而异的属性, 
		# 其中 评是指定量指标中，要求逐步提高或降低的指标，理论上说，这项属性应该是各版本一致的，如此设计是为防止万一
		
		{@versionName, @序号, @计量单位, @二级指标, @一级指标, @测, @评} = funcOpts
		
		#IndicatorDefVersion.addVersion(this)
		@constructor.addVersion(this)







class IndicatorDef
	@fromMannualFile: (funcOpts) ->
		json = JU.jsonizedExcelData(funcOpts)
		indicators = {}
		for versionName, mannual of json
			for k, obj of mannual
				key = k.replace('▲','') 
				indicators[key] ?= new this(obj)
				indicators[key].versions.push(new IndicatorDefVersion({
					versionName: versionName 
					序号: obj.序号
					二级指标: obj.二级指标
					一级指标: obj.一级指标
					计量单位: obj.计量单位
					测: /▲$/.test(obj.指标名称)
					评: /(降低|提高)/.test(obj.指标导向)
				}))
				# console.log key, obj
		
		# json 只是用来查看和纠错的, instance objects 则应每次从原始文件生成
		{folder,basename,needToRewrite} = funcOpts
		JU.write2JSON({folder,basename:"#{basename}Dict", needToRewrite, obj:indicators})
		return indicators






	###
	# 各版本独立陈列，备考  
	@seperatedFromMannualFile: (funcOpts) ->
		json = JU.jsonizedExcelData(funcOpts)
		indicators = {}
		for version, mannual of json
			indicators[version] = {}
			for key, obj of mannual 
				instance = new this(obj)
				indicators[version][key] = instance
				# console.log key, obj
		return indicators
	###


	constructor: (funcOpts) ->
		# 以下指标在不同的版本中都是一致的，否则应该放在 IndicatorDefVersion
		{@指标名称, @指标来源='', @指标属性='', @指标导向} = funcOpts
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
