path = require 'path'
alias = require path.join __dirname, '..', 'data','JSON', '别名表'
data = require path.join __dirname, '..', 'data','JSON', 'demoData'

  
# please give me data of DRGs组数(组)

console.log {data: data["DRGs组数(组)"]}

console.log {data: data[alias["DRGs组数(组)"].正名]}