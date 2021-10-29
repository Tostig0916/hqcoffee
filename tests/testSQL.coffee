alasql = require 'alasql'
# from json

# this lib has too many issues

alasql.promise([
    "select * from json('./SystemLog')"
]).then((results)->
    console.log {results}
).catch(console.log)

test = ->
    alasql "create table cities (city string, pop number)"
    alasql "insert into cities value ('paris',223444), ('berlin',35174124), ('Madrid',33353)"
    res = alasql "select * from cities where pop < 35000000 order by pop desc"
    console.log {res}