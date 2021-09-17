JU = require './jsonUtils'


createfile = (funcOpts) ->
  json = JU.jsonizedExcelData(funcOpts)
  JU.write2JSON({folder,basename:"#{basename}Dict", needToRewrite, obj:indicators})

