# abstract information from json
#indicatorname = 3
obj = {indicatorname: "sjskk", name: 'what', age: 35, unit:{name:"neike", staff:15}}
#indicatorname = obj.indicatorname
#name = obj.name
{indicatorname,name, unit:{staff}} = obj

correctNames = {
    
}

# database
json = {
    sjskk: 35
    hkkk: 23
    a: 300
    b: 400
}

class Process
    # read data from database
    # funOpts should include the name of indicator you want to read out
    @demo_get_data: (funcOpts={}) ->
        {indicatorname,database} = funcOpts
        database[indicatorname] ? this["calc_#{indicatorname}"](funcOpts) #"no data"

    @calc_c: (funcOpts={}) ->
        {database} = funcOpts
        #"function calcC has to be defined"
        #database.a + database.b
        a = @demo_get_data({indicatorname:'a',database:database})
        b = @demo_get_data({indicatorname:'d',database})
        a + b

    @calc_b: (funcOpts={}) ->
        "function calc_#{funcOpts.indicatorname} has to be defined"
        
    @calc_d: (funcOpts={}) ->
        {database} = funcOpts
        a = @demo_get_data({indicatorname:'a', database})



data = Process.demo_get_data({indicatorname:'c', database:json})

console.log {data}

#console.log json['c']