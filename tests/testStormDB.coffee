path = require 'path'
{MakePPTReport} = require path.join __dirname, '..','usepptxgen', 'pptxgenUtils'
{JSONUtils} = require path.join __dirname, '..', 'toJSON', 'jsonUtils'
{CommonNameSingleton} = require path.join __dirname, '..', 'toJSON', 'singletons'

dbpath = (basename) -> 
  path.join __dirname, '..', 'data', 'JSON', "#{basename}.json"
StormDB = require 'stormdb'
engine = new StormDB.localFileEngine(dbpath("demoData"))
db = new StormDB(engine)

### 如果要加密就不能用 .json 作为文件扩展名了
engine = new StormDB.localFileEngine( "./db.stormdb", {
  serialize: (data) -> 
    #// encrypt and serialize data
    encrypt(JSON.stringify(data))
  
  deserialize: (data) -> 
    #// decrypt and deserialize data
    JSON.parse(decrypt(data))
  
})
###

#db.default({settings:{}})

console.log DRGs组数: db.get("DRGs组数").value()
json = CommonNameSingleton.fetchSingleJSON()
#db.set("别名表",json).save()
#console.log db.get("别名表").value()
f = ({key, value} for key, value of db.get("别名表").value()).filter (obj) ->
  #console.log obj.key, obj.value
  obj.value.length < 5

console.log {f}
#console.log {
#  settings: db.get("settings").value(), key: db.get("settings").get("key").value()
#}

###
alias = require path.join __dirname, '..', 'data','JSON', '别名表'
data = require path.join __dirname, '..', 'data','JSON', 'demoData'

  
# please give me data of DRGs组数(组)

console.log {data: data["DRGs组数(组)"]}

console.log {data: data[alias["DRGs组数(组)"]]}
###