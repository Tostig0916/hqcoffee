excel = require 'exceljs'

workbook = new excel.Workbook()

workbook.creator = 'Me'
workbook.lastModifiedBy = 'Her'
workbook.created = new Date(1985, 8, 30)
workbook.modified = new Date()
workbook.lastPrinted = new Date(2016, 9, 27)
#// Set workbook dates to 1904 date system
workbook.properties.date1904 = true
# Force workbook calculation on load
workbook.calcProperties.fullCalcOnLoad = true

workbook.views = [
  {
    x: 0, y: 0, width: 10000, height: 20000,
    firstSheet: 0, activeTab: 1, visibility: 'visible'
  }
]

t = 0 
switch t
  when 0  
    sheet = workbook.addWorksheet('My Sheet')
  when 1
    #// create a sheet with red tab colour
    sheet = workbook.addWorksheet('My Sheet', {properties:{tabColor:{argb:'FFC0000'}}})
  when 2
    #// create a sheet where the grid lines are hidden
    sheet = workbook.addWorksheet('My Sheet', {views: [{showGridLines: false}]})
  when 3
    #// create a sheet with the first row and column frozen
    sheet = workbook.addWorksheet('My Sheet', {views:[{state: 'frozen', xSplit: 1, ySplit:1}]})
  when 4
    #// Create worksheets with headers and footers

    sheet = workbook.addWorksheet('My Sheet', {
      headerFooter:{firstHeader: "Hello Exceljs", firstFooter: "Hello World"}
    })

  else
    #// create new sheet with pageSetup settings for A4 - landscape
    worksheet =  workbook.addWorksheet('My Sheet', {
      pageSetup:{paperSize: 9, orientation:'landscape'}
    })

