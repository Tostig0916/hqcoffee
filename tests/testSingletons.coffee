path = require 'path'
{
  SystemLog
  别名库
  指标三级对二级
  名字ID库
} = require path.join __dirname, '..', 'analyze', 'singletons'


testLog = ->
  sl = SystemLog
  db = sl.db()
  
  sl.logdb(new Date(), "message")
  sl.logdbs()
  db.save()
  
  sl.dbClear()
    .save()

testLog()

指标三级对二级.fetchSingleJSON()
console.log 指标三级对二级.reversedJSON()
#console.log 别名库.fetchSingleJSON()

