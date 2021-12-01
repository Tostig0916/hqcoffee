path = require 'path'
{
  SystemLog
  别名库
  三级指标对应二级指标
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

三级指标对应二级指标.fetchSingleJSON()
console.log 三级指标对应二级指标.reversedJSON()
#console.log 别名库.fetchSingleJSON()

