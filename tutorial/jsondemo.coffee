a = {}
a.name = "jk"
a.age = 53
a["a c d"] = "acd"
a.pn = "8613333"
a.tool = { name: "phone", version: "3s" }
a.tool.version = a.age + Number(a.pn)

square = -> 
cube   = -> square() * 3

  
console.log(cube)