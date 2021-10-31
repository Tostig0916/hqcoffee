# js 小數點後面數字不可靠,故會丟失賣出點
# 欲比較數字,先用此法轉換成文字,再作比較
fixTo = 2

fixAll = (obj,n=fixTo)->
  for k, each of obj
    obj[k] = fix(each, n)
  return obj

fix = (x,n=fixTo)->
  k = 10 ** n
  Math.round(x * k) / k

fixString = (s, n=fixTo)->
  fix(Number(s), n)

###
黃金分割定義:
  a/b = a+b/a = 1.618....
so:  
  price [x,y,z] when x < y < z
  a = y-x
  b = z-y
  since a = 1.618*b
  so y-x = 1.618*(z-y)
  so y(1+1.618) = 1.618*z + x
  so y = (1.618*z + x)/2.618
  since 
    1/2.618 --> 0.382
    1.618/2.618 --> 0.618
  so y = 0.618*z + 0.382*x 
so:
###
goldenPoint = (left, right, heavyRight=false)->
  if heavyRight
    fix(left*0.382 + right*0.618)
  else
    fix(left*0.618 + right*0.382)

### 用法
x = (aLineName,pre) ->
  {high,low,open,close} = this
  line = @[aLineName]
  # js 小數點後面數字不可靠,故會丟失賣出點
  {high,low,open,close,line} = fixAll({high,low,open,close,line})
###

module.exports = {fix,fixAll,fixString,goldenPoint}