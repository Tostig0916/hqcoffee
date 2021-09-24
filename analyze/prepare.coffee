

class DataManager
    # read data from dictionary
    # funcOpts should include the name of indicator you want to read out
    @getData: (funcOpts={}) ->
      {entityName, dataName, key, dictionary, storm_db, log_db} = funcOpts
      data = storm_db?.get(dataName)?.value() ? dictionary?[dataName] ? \
      try
        funcName = @_funcName(funcOpts)
        this[funcName](funcOpts) #"no data"
      catch error
        #console.log {funcName, needs: "to be added!"}
        #"to be added!"
        ##{funcName}: 
        unless log_db.get(funcName)?.value()?
          log_db.set(funcName, "(funcOpts={}) -> @toBeImplemented(funcOpts)  # #{entityName}#{key}")
            .save()
        null

      if key? then data?[key] else data




    @_funcName: (funcOpts={}) ->
      {entityName, dataName, key, regest_db} = funcOpts
      funcName = "求#{dataName}"
      console.log {主体: entityName+key, 现在使用: funcName}
      regarr = regest_db.get(funcName)
      #console.log length: regarr.value().length
      unless regarr.value().length? then regest_db.set(funcName,[]) 
      regarr.push(entityName+key).save()
      funcName





    @toBeImplemented: (funcOpts={}) ->
      console.log {
        function: "#{@_funcName(funcOpts)}", needs: "implementing!"
      }
      return NaN
      #Error("function: #{@_funcName(funcOpts)} not implemented!")
 
 



    @求b: (funcOpts={}) ->
        @toBeImplemented(funcOpts)


    
    #@求出院患者四级手术占比: (funcOpts={}) ->
    #    @toBeImplemented(funcOpts)

    
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



# DataManagerDemo.demo()