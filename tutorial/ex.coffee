###
a = {}
a.name = "yani"
a.age = 1
a.age = a.age+5
a.age += 51
a.tools = []
a.tools.push "iphone"
a.tools.push "pc"
a.oneAddOne = (x,y) ->
 x+y 
# keys -> vars 
# name = a.name 
{name,age} = a
###

class A 
  constructor: (funcOpts)->
    {@name,@age} = funcOpts


a = new A({name:"o",age:5}) 
class Animal
  constructor: (funcOpts)->
    {@name,@age} = funcOpts

  isOld: (n) ->
    if @age < 0
      console.log 'my age is wrong'
    else 
      @age > n 


animal1 = new Animal({name:"o",age:-5}) 
animal2 = new Animal({name:"dog",age:8}) 


console.log {
  name1: animal1.name 
  age2: animal2.age
  animal1IsOld: animal1.isOld(30)
}
    # A.constructor



f = {}
f.member ="qwe"
f.tall = 100
f.tall +=20
f.q =[]
f.q.push "one"
f.long = 'ten'

###
console.log {
  f
}
###



###
console.log {
  a
  A
  n:a.name.length
  m:a.tools.length
  r:a.oneAddOne(2,5)
  age
  name
}
###