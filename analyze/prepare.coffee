class DataManager
    # read data from dictionary
    # funcOpts should include the name of indicator you want to read out
    @getData: (funcOpts={}) ->
      {dataName, key, dictionary, storm_db} = funcOpts
      data = storm_db?.get(dataName).value() ? dictionary[dataName] ? \
      this[@_funcName(funcOpts)](funcOpts) #"no data"
      if key? then data[key] else data




    @_funcName: (funcOpts={}) ->
      {dataName} = funcOpts
      funcName = "求#{dataName}"
      console.log {funcName}
      funcName



    @toBeImplemented: (funcOpts={}) ->
      console.log "function #{@_funcName(funcOpts)} needs to be implemented!"
      return null
 
 



    @求b: (funcOpts={}) ->
        @toBeImplemented(funcOpts)


    
    
    @求c: (funcOpts={}) ->
        {dictionary} = funcOpts
        a = @getData({dataName:'a',dictionary})
        b = @getData({dataName:'d',dictionary})
        a + b





 class DataManagerDemo extends DataManager
  
    @求d: (funcOpts={}) ->
        {dictionary} = funcOpts
        a = @getData({dataName:'a', dictionary})
        a


    @demo: ->
      # dictionary
      dictionary = {
          d: 35
          h: 23
          a: 300
          e: 400
          f: {
            x: 1
            y: 24
          }
      }

      data = @getData({dataName:'c', dictionary})

      console.log {
        c: @getData({dataName:'c', dictionary})
        d: @getData({dataName:'d', dictionary})
        f: @getData({dataName:'f', dictionary, key:"x"})
      }




module.exports = {
  DataManager
}



# DataManagerDemo.demo()