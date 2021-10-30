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
   3. alasql <https://github.com/agershun/alasql> in memory database, using SQL
2. PPT程序化制作
   1. pptxgenjs 排版需要探索功能究竟有多强，图形较全
   2. officegen 存在bug故暂时不好用
3. Word、PDF、md等文件格式生成和转换
   1. pandoc

### 注意事项

1. 指标数据填报表,需要使用指标名称作为表头,而不用其他的如项目之类表头
1. 医护比等比例指标,数值写成 x/y 而不是x:y, 否则转换成JSON时会出错

### 行业标准

#### 国内

   国家标准查询 <http://hbba.sacinfo.org.cn/>

   卫健委 <http://www.nhc.gov.cn/>

#### 国际

   世卫 IDC-11 <http://www.nhc.gov.cn/ewebeditor/uploadfile/2018/12/20181221160228191.xlsx>

### 其他

#### tutorial
<https://youtu.be/2LhoCfjm8R4>

#### sql 99
sql 99 tutorial <https://crate.io/docs/sql-99/en/latest/> 

#### upstream

how to fetch origin updates to a forked rep

https://devopscube.com/set-git-upstream-respository-branch/

in short:
```
   git add upstream https://github.com/emptist/hqcoffee/hqcoffee.git
   git branch --remote
   git fetch upstream
   git merge upstream/main 
   git merge upstream/dev
```