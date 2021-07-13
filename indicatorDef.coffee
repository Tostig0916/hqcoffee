e2j = require 'convert-excel-to-json'
fs = require 'fs'
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
		# 此处为可因版本而异的属性, 其中 评是指定量指标中，要求逐步提高或降低的指标
    {@versionName, @序号, @测, @评} = funcOpts
    IndicatorDefVersion.addVersion(this)





class IndicatorDef
	@fromMannualFile: (funcOpts) ->
		json = IndicatorDef.jsonizedMannual(funcOpts)
		indicators = {}
		for version, mannual of json
			for k, obj of mannual
				key = k.replace('▲','') 
				indicators[key] ?= new IndicatorDef(obj)
				indicators[key].versions.push(new IndicatorDefVersion({
					versionName: version 
					序号: obj.序号
					测: /▲$/.test(obj.指标名称)
					# 评: /(降低|提高)/.test(obj.指标导向)
				}))
				# console.log key, obj
		return indicators




	# 各版本独立陈列，备考  
	@seperatedFromMannualFile: (funcOpts) ->
		json = IndicatorDef.jsonizedMannual(funcOpts)
		indicators = {}
		for version, mannual of json
			indicators[version] = {}
			for key, obj of mannual 
				instance = new IndicatorDef(obj)
				indicators[version][key] = instance
				# console.log key, obj
		return indicators


	# 将Excel文件转化为JSON文件
	@jsonizedMannual: (funcOpts) ->
		# type could be zh 综合, zy 中医,etc
		{p=__dirname, year=2020} = funcOpts
		# read from mannual file and turn it into a dictionary
		baseName = "indef#{year}"
		excelfileName = path.join p, "#{baseName}.xlsx"
		jsonfilename = path.join p, "#{baseName}.json"

		needToRewrite = false 
		if needToRewrite or not fs.existsSync jsonfilename
			readOpts =
				sourceFile: excelfileName
				header: {rows: 1}
				#sheets: ['Sheet 1']
				columnToKey: {
					'*':'{{columnHeader}}'
				}
			json = IndicatorDef.readFromExcel(readOpts)
			IndicatorDef.write2JSON({jsonfilename,result:json})
		else
			console.log "read from", jsonfilename #, __filename, __dirname
			json = require jsonfilename

		return json


	@readFromExcel: (funcOpts) ->
		# console.log e2j 
		source = e2j funcOpts
		result = {}
		for key, arr of source
			k = key.replace(/\s+/g,'')
			result[k] = {}
			for obj in arr
				# (typeof myVar === 'string' || myVar instanceof String)
				for innerkey, innervalue of obj when (typeof innervalue is 'string') or (innervalue instanceof String)
					obj[innerkey] = innervalue.replace(/\s+/g,'')
				objk = obj.指标名称 #.replace(/\s+/g,'')
				result[k][objk] = obj
		return result 


	@write2JSON: (funcOpts) ->
		{jsonfilename, result} = funcOpts
		jsonContent = JSON.stringify(result)

		fs.writeFile jsonfilename, jsonContent, 'utf8', (err) ->
			if err? 
				console.log(err)
			else
				console.log "json saved at #{Date()}"



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
