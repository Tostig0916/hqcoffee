class TryingCoffee2 
  constructor: (funcOpts={}) ->
    {@name} = funcOpts

  #@[computed]: -> "hello #{@name}"


tr = new TryingCoffee2({name: 'excel'})
#console.log tr.computed