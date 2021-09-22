path = require 'path'
{
  SystemLog
  别名库
  指标维度库
  名字ID库
} = require path.join __dirname, '..', 'toJSON', 'singletons'


testLog = ->
  sl = SystemLog
  db = sl.db()
  
  sl.dbLog(new Date(), "message")
  sl.dbLogs()
  db.save()
  
  sl.dbClear()
    .save()

testLog()

#指标维度库.fetchSingleJSON()
#console.log 指标维度库.reversedJSON()
#console.log 别名库.fetchSingleJSON()

