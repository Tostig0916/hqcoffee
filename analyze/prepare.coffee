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
      console.log {现在使用: funcName}
      funcName



    @toBeImplemented: (funcOpts={}) ->
      console.log {
        function: "#{@_funcName(funcOpts)}", needs: "implementing!"
      }
      return NaN
      #Error("function: #{@_funcName(funcOpts)} not implemented!")
 
 



    @求b: (funcOpts={}) ->
        @toBeImplemented(funcOpts)


    
    
    @求c: (funcOpts={}) ->
        funcOpts.dataName = "a"
        a = @getData(funcOpts)
        
        funcOpts.dataName = "b"
        b = @getData(funcOpts)
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



# 
DataManagerDemo.demo()