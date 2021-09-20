path = require 'path'
StormDB = require 'stormdb'
engine = new StormDB.localFileEngine( "./db.json")

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
db = new StormDB(engine)

db.default({settings:{}})

db.get("settings")
  .set("key", "value")
  .save()

console.log {
  settings: db.get("settings").value(), key: db.get("settings").get("key").value()
}

###
alias = require path.join __dirname, '..', 'data','JSON', '别名表'
data = require path.join __dirname, '..', 'data','JSON', 'demoData'

  
# please give me data of DRGs组数(组)

console.log {data: data["DRGs组数(组)"]}

console.log {data: data[alias["DRGs组数(组)"]]}
###