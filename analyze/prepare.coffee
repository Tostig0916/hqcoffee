class DataManager
    # read data from dictionary
    # funcOpts should include the name of indicator you want to read out
    @getData: (funcOpts) ->
        {dataName, dictionary} = funcOpts
        dictionary[dataName] ? this[@funcName(funcOpts)](funcOpts) #"no data"



    @funcName: (funcOpts) ->
      {dataName} = funcOpts
      "求#{dataName}"


    @toBeImplemented: (funcOpts) ->
      console.log "function #{@funcName(funcOpts)} needs to be implemented!"
      return null
 
 
    @求c: (funcOpts) ->
        {dictionary} = funcOpts
        @getData({dataName:'a',dictionary}) + @getData({dataName:'d',dictionary})


    @求b: (funcOpts) ->
        @toBeImplemented(funcOpts)


    @求d: (funcOpts) ->
        {dictionary} = funcOpts
        @getData({dataName:'a', dictionary})



module.exports = {
  DataManager
}




# abstract information from json
#dataName = 3
obj = {dataName: "sjskk", name: 'what', age: 35, unit:{name:"neike", staff:15}}
#dataName = obj.dataName
#name = obj.name
{dataName,name, unit:{staff}} = obj

correctNames = {
    
}

# dictionary
json = {
    sjskk: 35
    hkkk: 23
    a: 300
    e: 400
}

data = DataManager.getData({dataName:'c', dictionary:json})

console.log {data}

#console.log json['c']