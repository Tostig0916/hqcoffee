StormDB = require("stormdb")

# start db with "./db.stormdb" storage location
engine = new StormDB.localFileEngine("./db.json")
db = new StormDB(engine)

# set default db value if db is empty
db.default({ users: [] })
# add new users entry
db.get("users").push({ name: "tom" }).save()

# update username of first user
db.get("users")
  .get(1)
  .get("name")
  .set("jeff")
# save changes to db
db.set('worker.name2',"jack")
db.set('Numbers',[1,2,3,4,5])
# db.get('Numbers').filter (x)-> x > 3
console.log db.get('Numbers').value()
db.get('users').filter((obj)-> obj.name is 'tom').save()
console.log db.get('users').value()


console.log db.get('users').get(1).get('name').value()   #.delete(true)
#db.save()
