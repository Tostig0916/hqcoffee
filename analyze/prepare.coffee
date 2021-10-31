

class DataManagerBase
  @ratio: (startV, endV, n) ->
    if convinient = true
      # 便于评分,保持正数
      Math.pow(endV/startV, 1/n)
    else 
      100 * Math.pow(endV/startV, 1/n) - 100
  

  # read data from dictionary
  # funcOpts should include the name of indicator you want to read out
  @getData: (funcOpts={}) ->
    {entityName, dataName, key, dictionary, dbItem, log_db, regest_db} = funcOpts
    if key?
      @getDataWithKey(funcOpts)
    else
      @getDataDirectly(funcOpts)




  @getDataDirectly: (funcOpts={}) ->
    {entityName, dataName, dictionary, dbItem, log_db, regest_db} = funcOpts

    data = dictionary?[dataName] ? dbItem?.get(dataName)?.value() ? @tryCalculating(funcOpts)
    return data



  # 例如某数据行,有对标对象或年份不同,这些作为key来区分,很常用,也可能是最容易解决的方式
  @getDataWithKey: (funcOpts={}) ->
    # informal 是指医院该填写的数据没有填写,尝试计算解决,但仅可偶尔使用,因增加了程序复杂性,易错
    {entityName, dataName, key, dictionary, dbItem, log_db, regest_db, informal=false} = funcOpts

    switch
      when dictionary? and dictionary[dataName]? and dictionary[dataName][key]?
        dictionary[dataName][key]
      
      # 客户应填数据未填,尝试通过计算获得.此为非常规操作,尽量避免,设置informal为no
      when informal and dbItem? and dbItem.get(dataName)?.value() and dbItem.get(dataName).get(key)?.value()
        dbItem.get(dataName).get(key).value()
      
      when dbItem? and dbItem.get(dataName)?.value()?
        dbItem.get(dataName).get(key).value()

      else
        @tryCalculating(funcOpts)




  # todo: when not informal what should we do? 
  @tryCalculating: (funcOpts) ->
    {entityName, dataName, key, log_db, regest_db, informal=false} = funcOpts
    
    return null unless informal

    try
      funcName = @_funcName(funcOpts)
      this[funcName](funcOpts)

    catch error
      unless log_db.get(funcName)?.value()?
        log_db.set(funcName,"(funcOpts={})-> #Math.random();@toBeImplemented(funcOpts) # #{entityName}#{key}").save()

        regarr = regest_db.get(dataName)
        regest_db.set(dataName,[]) unless regarr.value()?.length? 
        regarr.push(entityName + (key ? "")).save()
      
      null  # use null as returning





  # don't change, almost correct!
  @getData_origin: (funcOpts={}) ->
    {entityName, dataName, key, dictionary, dbItem, log_db, regest_db} = funcOpts
    data = dictionary?[dataName] ? dbItem?.get(dataName)?.value() ? \
      try
        funcName = @_funcName(funcOpts)
        this[funcName](funcOpts)

      catch error
        @tryCalculating(funcOpts)
        ###
        unless log_db.get(funcName)?.value()?
          log_db.set(funcName,"(funcOpts={})-> #Math.random();@toBeImplemented(funcOpts) # #{entityName}#{key}").save()

          regarr = regest_db.get(dataName)
          unless regarr.value()?.length? then regest_db.set(dataName,[]) 
          regarr.push(entityName+key).save()
        
        null  # use null as returning
        ###
    # 这行不对,如果通过计算解决,以上代码并未定位到具体年份或对标相关的数值,故无法计算    
    if key? then data?[key] else data





  @_funcName: (funcOpts={}) ->
    {entityName, dataName, key, regest_db} = funcOpts
    funcName = "求#{dataName}"
    #console.log {部门: entityName+key, 现在使用: funcName}
    ###
    regarr = regest_db.get(dataName)
    unless regarr.value()?.length? then regest_db.set(dataName,[]) 
    regarr.push(entityName+key).save()
    ###
    funcName





  @toBeImplemented: (funcOpts={}) ->
    console.log {
      function: "#{@_funcName(funcOpts)}", needs: "implementing!"
    }
    return NaN
    #Error("function: #{@_funcName(funcOpts)} not implemented!")




  @求b: (funcOpts={}) ->
    @toBeImplemented(funcOpts)


  
  #@求出院患者四级手术占比: (funcOpts={}) ->
  #    @toBeImplemented(funcOpts)

  
  @求c: (funcOpts={}) ->
    funcOpts.dataName = "a"
    a = @getData(funcOpts)
    
    funcOpts.dataName = "b"
    b = @getData(funcOpts)
    a + b






class DataManager extends DataManagerBase

  @求SCI平均影响因子: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  
  
  @求病理医师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
    ###
    funcOpts.dataName = "病理医师人数"
    病理医师人数 = @getData(funcOpts)
    funcOpts.dataName = "医师人数"
    医师人数 = @getData(funcOpts)
    
    return 病理医师人数 / 医师人数 * 100
    ###

  @求博士研究生导师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
    
  @求医师博士占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"

  @求员工博士占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求出院患者三级手术占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求出院患者使用中医非药物疗法比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求出院患者手术占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求出院患者四级手术比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求出院患者微创手术占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求出院患者中药饮片使用率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求次均费用增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求次均药品费用增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求大型医用设备检查阳性率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求点评处方占处方总数的比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求点评中药处方占中药处方总数的比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求电子病历应用功能水平分级: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求儿科医师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求辅助用药收入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师副高职称占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求员工副高职称占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师高级职称占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求国家组织药品集中采购中标药品金额占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求耗材占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求护床比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求护理人员系统接受中医药知识和技能培训比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求基本药物采购金额占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求基本药物采购品种数占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求检查检验收入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求抗菌药物费用占药费总额的百分率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求抗菌药物使用强度DDDs: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求理法方药使用一致的出院患者比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求麻醉医师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每百名卫生技术人员科研成果转化金额: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每百名卫生技术人员科研项目经费: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每百名卫生技术人员中医药科研成果转化金额: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每百名卫生技术人员中医药科研项目经费: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每百名卫生技术人员重点学科重点专科经费投入: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师人均SCI文章数量: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师人均国家级科研项目数量: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师人均国家自然科学基金项目数量: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师人均国内中文核心期刊文章数量: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每百张病床药师人数: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每床出院量: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每床平均住院收入: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每名执业医师日均门诊工作负担: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每名执业医师日均住院工作负担: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每医师门急诊收入: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每医师住院收入: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求每医师住院手术量: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊次均费用增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊次均药品费用增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊患者基本药物处方占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求门诊患者抗菌药物使用率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊患者平均预约诊疗率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊患者使用中医非药物疗法比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊患者预约后平均等待时间: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊患者中药饮片使用率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊散装中药饮片和小包装中药饮片处方比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求门诊收入占医疗收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊中药处方比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求门诊中医医疗服务项目收入占门诊医疗收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求人才培养经费投入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求人员经费占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求日间手术占择期手术比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求省级室间质量评价临床检验项目参加率与合格率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求手术患者并发症发生率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求硕士研究生导师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医师硕士占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求员工硕士占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求特需医疗服务占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求通过国家室间质量评价的临床检验项目数: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求外省住院患者占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求万元收入能耗占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求下转患者人次数: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医床比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医护比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  
  @求医疗服务收入: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 心血管内科Y2020",
    ###
    funcOpts.dataName = '医疗收入' 
    医疗收入 = @getData(funcOpts)
    funcOpts.dataName = '药品收入' 
    药品收入 = @getData(funcOpts)    
    funcOpts.dataName = '耗材收入' 
    耗材收入 = @getData(funcOpts)    
    funcOpts.dataName = '检查检验收入' 
    检查检验收入 = @getData(funcOpts)
    医疗收入 - 药品收入 - 耗材收入 - 检查检验收入
    ###

  @求医疗服务收入三年复合增长率: (funcOpts={})-> #@toBeImplemented(funcOpts)  #Math.random()*100 # 医院Y2020",
    funcOpts.dataName = '医疗服务收入' 
    今医疗服务收入 = @getData(funcOpts)
    
    {key} = funcOpts
    newKey = (key, n) ->
      "Y#{Number(key[1..]) - n}"

    n = 2
    funcOpts.key = newKey(key, n)
    前医疗服务收入 = @getData(funcOpts)
    
    unless 前医疗服务收入?
      n = 1
      funcOpts.key = newKey(key, n)
      前医疗服务收入 = @getData(funcOpts)

    unless 前医疗服务收入?
      return null

    return @ratio(前医疗服务收入, 今医疗服务收入, n)
  



  @求医疗服务收入占全院比重: (funcOpts={})-> #@toBeImplemented(funcOpts)  #Math.random()*100 # 医院Y2020"
    funcOpts.dataName = '医疗服务收入' 
    医疗服务收入 = @getData(funcOpts)
    funcOpts.dbItem = funcOpts.storm_db.get('医院')
    全院医疗服务收入 = @getData(funcOpts)
    return 医疗服务收入 / 全院医疗服务收入 * 100


  @求医疗服务收入占医疗收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
    ###
    funcOpts.dataName = '医疗收入' 
    医疗收入 = @getData(funcOpts)
    funcOpts.dataName = '医疗服务收入' 
    医疗服务收入 = @getData(funcOpts)
    医疗服务收入 / 医疗收入 * 100 - 100
    ###


  @求医疗机构中药制剂收入占药品收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医疗收入增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医疗盈余率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医务人员满意度: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医院感染发生率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医院接受其他医院进修并返回原医院独立工作人数占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医院住院医师首次参加医师资格考试通过率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求疑难危重病例比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求以中医为主治疗的出院患者比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求择期手术患者术前平均住院日: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求员工正高职称占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求中药收入占药品收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求中药饮片收入占药品收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求中医类别执业医师和执业助理医师占执业医师总数比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求中医医师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求重点监控高值医用耗材收入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求重点监控化学药品和生物制品收入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求重点监控药品收入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求重症医师占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求住院次均费用增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求住院次均药品费用增幅: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求住院患者31天非计划再返率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求住院患者基本药物使用率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求住院收入占医疗收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求住院手术患者围手术期中医治疗比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020"
  @求住院中医医疗服务项目收入占住院医疗收入比例: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求资产负债率: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 医院Y2020"
  @求医院在医学人才培养方面的经费投入占比: (funcOpts={}) -> @toBeImplemented(funcOpts)  #Math.random()*100  # 心血管内科Y2020
  
  @求CMI值: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 医院Y2019"
  @求DRGs组数: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 医院Y2019"
  
  @求病床使用率: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 男科Y2020"
  
  @求低风险组病例死亡率: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 医院Y2019"
  
  @求平均住院日: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 男科Y2020"
  
  @求药占比: (funcOpts={})-> @toBeImplemented(funcOpts)  #Math.random()*100 # 中医外治中心Y2019"






class DataManagerDemo extends DataManagerBase
  
  @求d: (funcOpts={}) ->
      {dictionary} = funcOpts
      a = @getData({dataName:'a', dictionary})
      a


  @demo: ->
    # dictionary
    dictionary = {
        d: 35
        h: 23
        a: 300
        e: 400
        f: {
          x: 1
          y: 24
        }
    }

    data = @getData({dataName:'c', dictionary})

    console.log {
      c: @getData({dataName:'c', dictionary})
      d: @getData({dataName:'d', dictionary})
      f: @getData({dataName:'f', dictionary, key:"x"})
    }




module.exports = {
  DataManager
}



# DataManagerDemo.demo()