e2j = require 'convert-excel-to-json'
JU = require './jsonUtils'

#fs = require 'fs'
#path = require 'path' 
#pptxgen = require 'pptxgenjs'
#xlsx = require 'json-as-xlsx'

class IndicatorDefCategory
	constructor: (funcOpts) ->
		{@name} = funcOpts
		@subs = []   
	
	addInfo: (funcOpts) ->
		{subName} = funcOpts
		@subs.push(subName) unless subName in @subs

	description: ->
		"#{@name},#{@subs.join(",")}" 




class IndicatorDefVersion	
	
	constructor: (funcOpts)->
		{@versionName} = funcOpts
		@categoryOne = {} #{name, category}
		@categoryTwo = {}

	addInfo: (funcOpts) ->
		{indicatorKey,一级指标,二级指标} = funcOpts
		@categoryOne[一级指标] ?= new IndicatorDefCategory({name: 一级指标})
		@categoryTwo[二级指标] ?= new IndicatorDefCategory({name: 二级指标})

		@categoryOne[一级指标].addInfo({subName:二级指标})
		@categoryTwo[二级指标].addInfo({subName:indicatorKey})




class IndicatorDefInfoByVersion
	# 无法直接加class properties，只能这样曲折设置
	@addVersion: (funcOpts) ->
		@versions ?= {}
		{versionName} = funcOpts
		@versions[versionName] ?= new IndicatorDefVersion(funcOpts)
		@versions[versionName].addInfo(funcOpts)


	@versionArray: ->
		(each for key, each of @versions)


	@versionCount: ->
		(v for k,v of @versions).length

	

	constructor: (funcOpts) ->
		# 此处为可因版本而异的属性, 
		# 其中 评是指定量指标中，要求逐步提高或降低的指标，理论上说，这项属性应该是各版本一致的，如此设计是为防止万一
		
		{@versionName,@indicatorKey,@序号, @计量单位, @二级指标, @一级指标, @测, @评} = funcOpts
		
		@constructor.addVersion(this)







class IndicatorDef
	@fromMannualFile: (funcOpts) ->
		json = JU.jsonizedExcelData(funcOpts)
		indicators = {}
		for versionName, mannual of json
			for k, obj of mannual
				key = @fixedKey k.replace('▲','')
				obj.key = key
				indicators[key] ?= new this(obj)
				indicators[key][versionName] = true
				if obj.一级指标?  
					indicators[key].一级指标 ?= obj.一级指标
				if obj.二级指标?  
					indicators[key].二级指标 ?= obj.二级指标
				
				indicators[key]["#{versionName}监测"] = /▲$/.test(obj.指标名称)

				indicators[key].versions.push(new IndicatorDefInfoByVersion({
					versionName
					indicatorKey: key 
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
		{data, settings} = @dataSettings4Excel {arr:(v for k, v of indicators)}
		JU.write2Excel({folder,basename:"#{basename}Analyze", needToRewrite, data, settings})
		JU.write2JSON({folder,basename:"#{basename}Dict", needToRewrite, obj:indicators})
		JU.write2JSON({folder,basename:"#{basename}Versions", needToRewrite, obj: IndicatorDefInfoByVersion.versions})
		return indicators



	@fixedKey: (k)->
		switch 
			when k in ["人员经费占比","人员支出占业务支出比重"] 
				"人员经费占比(人员支出占业务支出比重)"
			when k in ["万元收入能耗占比","万元收入能耗支出"]
				"万元收入能耗占比(~能耗支出)"
			when k in ["国家组织药品集中采购中标药品金额占比","国家组织药品集中采购中标药品使用比例"]
				"国家组织药品集中采购中标药品金额占比(~药品使用比例)"
			when k in ["医疗盈余率","收支结余"]
				"医疗盈余率(收支结余)"
			else k




	@dataSettings4Excel: (funcOpts) ->
		{arr} = funcOpts
		data = [
			{
				sheet: '国考指标体系'
				columns: [
					{label:'准确名称', value:'key'}
					#{label:'指标名称', value:'指标名称'}
					{label:'矢量', value:'可评价'}
					{label:'二级指标', value: '二级指标'}
					{label:'一级指标', value: '一级指标'}
					{label:'指标来源', value: '指标来源'}
					{label:'指标属性', value: '指标属性'}
					{label:'计量单位', value: '计量单位'}
					{label:'指标导向', value: '指标导向'}
					{label:'三综监', value: '三级综合监测'}
					{label:'三中监', value:'三级中医监测'}
					{label:'二综监', value: '二级综合监测'}
					{label:'三综', value: '三级综合'}
					{label:'三中', value: '三级中医'}
					{label:'二综', value: '二级综合'}
				]
				content: arr 
			}
		]
		settings = {
			extraLength: 3
			writeOptions: {}
		}
		
		{data, settings}





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
		# 以下指标在不同的版本中都是一致的，否则应该放在 IndicatorDefInfoByVersion
		{@key, @指标名称, @指标来源='', @指标属性='', @计量单位, @指标导向} = funcOpts
		@可评价 = /(降低|提高)/.test(@指标导向)
		@一级指标 = @二级指标 = null
		@三级综合 = @二级综合 = @三级中医 = @三级综合监测 = @二级综合监测 = @三级中医监测 = false
		@versions = []



	isValuable: ->
		/(降低|提高)/.test(@指标导向) 



	description: ->
		arr = ("版本:#{each.versionName}, 序号:#{each.序号}, 监测:#{each.测}" for each in @versions)
		return "指标:#{@指标名称}, 可评价:#{@isValuable()}, #{arr}"




module.exports = {
  IndicatorDef
  IndicatorDefInfoByVersion
}
