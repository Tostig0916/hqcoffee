# 数字化医院管理咨询工具

## Excel 数据处理及制作PPT

### 目标

1. 读取数据源，数据源包括 Excel 表格，JSON等，根据用户需要优先完成Excel读取
2. 数据分析
   1. 这部分拟在系统内完成，不依赖office，以便使用node的强大功能
   2. 由于实现输出Excel功能，亦可支持在Excel中计算分析，则可混合使用，兼容旧工作流程
3. 数据展示，
   1. 制作传统的Excel图表，优点方便嵌入PPT
   2. 或采用node所支持的制图库，优点支持slidejs，但要能输出到PPT、Word文档
4. 制作文档
   1. 图表嵌入PPT
   2. 根据数据分析结果自动制作Word文档

### 经过试用，较好的库

1. Excel-JSON 互相转化，读入输出Excel文件：
   1. convert-excel-to-json
   2. json-as-xlsx
   3. alasql <https://github.com/agershun/alasql> in memory database, using SQL, too many issues to use
2. PPT程序化制作
   1. pptxgenjs 排版需要探索功能究竟有多强，图形较全
   2. officegen 存在bug故暂时不好用
3. Word、PDF、md等文件格式生成和转换
   1. pandoc

## 安装方法

无论是Mac/Linux/Windows系统,除了第0步git,其主要安装顺序是一样的,

0. git Windows系统需要安装git官方的客户端,带有Git Bash,可通过任何电脑管家之类的软件或直接搜索bing.com找Windows git

1. vscode 通过官方网站下载安装,Windows系统可通过电脑管家等安装
2. nodejs.org 通过官方网站下载安装
3. coffeescript.org 通过官方网站,查看下载安装方法,简单说就是在git bash中运行 `npm i -g coffeescript`
4. 确定想要安装本项目的文件夹,例如Windows e盘git目录,或其他操作系统~/git目录,先在git bash 进入该目录,然后运行 `git clone 你的代码库地址`, 其中你的代码库地址,是在GitHub账户中,你所fork的这个项目页面上,有code绿色按钮,点开第一项,先复制好即可执行clone命令
5. `cd hqcoffee; npm i`

## 使用方法

### 用法说明

待续

### 注意事项

1. 指标数据填报表,需要使用"数据名"作为表头,而不用其他的如"项目"之类表头
2. 数据名中不应含标点符号(特殊字符),仅可包含汉字英文字母和数字,数字不应该出现在开头,例如"55岁以下员工比例"须改为"五十五岁以下员工比例"或"年龄55以下员工比例"
3. "医护比"等比例指标,其数值写成 x/y 而不是x:y, 否则转换成JSON时会出错
4. 一个指标名仅对应一个数值,不能使用"导师所带硕士/博士人数"然后数值为"6/3",这是常识性错误,须拆分成两个指标
5. 指标名排序是根据字符顺序从小到大排序,除此以外,数值包含年份,均按照从大到小排序,统一顺序以便处理. sort两种用法,数字和文本分别使用 sort((a,b) -> b - a) 以及 sort((a,b) -> if b < a then -1 else 1) 均为倒序.由于文本无法用减法,所以用比较大小的方式,逻辑是一样的.


## TODO
### 对标报告与院内报告统一

对标报告其实逻辑上与院内报告是雷同的.之所以区分,是因为传统习惯,以及数据表设计缺陷.如果将对标单位统一命名,例如医院,是本医院,医院对标均1,医院对标均2,医院对标某A,医院对标某B,依次类推,则可将所有数据置于同一电子表格的不同sheet内,其结构完全一样,分析过程也没有不同,只需挑选其中的对象即可,不需要另外设计代码


## 行业标准

#### 国内

   国家标准查询 <http://hbba.sacinfo.org.cn/>

   卫健委 <http://www.nhc.gov.cn/>

#### 国际

   世卫 IDC-11 <http://www.nhc.gov.cn/ewebeditor/uploadfile/2018/12/20181221160228191.xlsx>

## 其他

### tutorial

<https://youtu.be/2LhoCfjm8R4>

### sql 99

目前没有用SQL.有一个库,但经过测试bug太多,放弃.
sql 99 tutorial <https://crate.io/docs/sql-99/en/latest/>

### 设置 git upstream

how to fetch origin updates to a forked rep

<https://devopscube.com/set-git-upstream-respository-branch/>

in short:

``` bash
   git remote add upstream https://github.com/emptist/hqcoffee.git
   git branch --remote
   git fetch upstream
   git merge upstream/main 
   git merge upstream/dev

```

### why .gitignore not work

``` bash

   git rm -r --cached . 
   git add .
   git commit -m 'fixed ignore files'

```

### change hosts on Mac 

```bash
   
   sudo killall -HUP mDNSResponder
```