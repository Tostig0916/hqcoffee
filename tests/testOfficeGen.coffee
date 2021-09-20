###
path = require 'path'

# there's some bug in this package, give up
OfficeGenUtils = require path.join __dirname, '..', 'useofficegen', 'officegenUtils'
{JSONUtils}  = require path.join __dirname, '..', 'toJSON', 'jsonUtils'


funcOpts = {
  basename: "officegentest"
  sheetName: "雷达图"
  headerRows: 1
  sheetStubs: true
  needToRewrite: false #true
  mainKeyName: "科室名"
}

funcOpts.json = JSONUtils.getJSON(funcOpts)    

OfficeGenUtils.createPPT(funcOpts)

# createPPT({json})
###