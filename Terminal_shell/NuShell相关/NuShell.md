# NuShell 简单介绍

```nu
ls | length  # 打印出当前目录下文件数量
ls **/*.ipynb  # 列出所有嵌套在当前目录下的非隐藏文件
ls -a **/*.nu

ls | sort-by modified | reverse  # 打印所有文件，并按最新更该的顺序排序
ls | where size > 5b  # 打印大小大于5b的文件
ls | where name =~ rm  # =~表示使用正则表达式
ls *dilate_4 | each { |i1| ls $i1.name | each { |i2| ls ( $i1.name | $i2.name ) | where name =~ csv | each { |i3| cp $i3.name ( $i2.name | path join "threshold75" ) } } }

# ^echo表示调用外部命令，而不是nushell内置的echo
ls | get name| each { |i| ^echo $i }  # 从ls的内容中获取name，即所有文件的名字。然后each，遍历打印这些名字
ls | each { |i| $"文件($i.name)的大小为($i.size)" } | save rm_rjx.txt
ls | where type == dir | each { |i| touch ($i.name | path join "rm_rjx.txt") }  # 在当前目录的文件夹下新建rm_rjx.txt文件

ls | sort-by size | reverse | first | get name | cp $in ../  # 命令有时会接受一个参数而不是管道输入，于是提供内置变量$in

# 背景：当前目录下有3个目录，每个目录中有1个目录以及一堆csv文件。
# 目的：将所有csv文件复制到同级目录中
# 代码逻辑：
#   1. ls出当前目录，并each遍历以及命名变量为i1。
#   2. 再ls出$i1中的所有内容，并where name =~.csv，再对这些内容遍历以及命名变量为i2。
#   3. 此时i1.name为第一级目录名，i2.name为第二级csv名。
#   4. 然后组合i1.name和第二级目录“threshold75”为路径。
#   5. 并通过cp $i2.name $in进行复制操作。
ls |
  each {|i1| ls $i1.name | where name =~ .csv |
  each {|i2| ( $i1.name | path join threshold75) |
  cp $i2.name $in}}

# 经验：each之后就ls（最多增加where来筛选）。ls之后就each继续迭代。
ls | where name =~ "IBP" or name =~ "control" |
  each {|i1| ls $i1.name | where name =~ "self"|  # i1就是IBP和control。但是ls $i1查找其内部的文件，于是过滤self
  each {|i2| ls $i2.name |  # i2就是Glasser/BNA/sphere
  each {|i3| ($i3.name | path join "threshold75" "rm_rjx") |  # i3就是I/E/M
  $in}}}  # 最终操作

^ps  # 外部的ps命令
ps | get name  # 打印当前程序名字
ps | where name == nu.exe  # 打印出nu.exe程序的信息
ps | where name == nu.exe | get cpu  # 打印出nu.exe程序cpu使用量

sys users | get 3.name  # 3是序号

help commands | explore  # 输出很长时，可发送到explore

ls [a-z]*  # 打印第一个字母是小写的文件

cd ...  # 返回父目录的父目录

let x = if true {-1} else {1}
```

高级通配符（\*，?，[]），以及：

```nu
let rjx = 'rm_rjx'
let rjx_glob = ($"*($rjx)*" | into glob)
ls $rjx_glob
# 或者
let rjx = 'rm_rjx'
ls ...(glob $"*($rjx)*")  # ...：这是 Nushell 中的命令展开语法，它会将 glob 返回的结果传递给 ls 命令。


ls | where name =~ network | each { |i| $i.name | path join "*" | into glob | rm $in }
```

取代`curl`命令，nushell 有自己的`http get`：

```nu
http get https://api.github.com/repos/nushell/nushell/contributors | select login contributions
```

nushell 只会返回一个值：

```nu
def latest-file [] {
    echo "Returning the last file"
    ls | sort-by modified | last
}
latest-file  # 只返回最后一个值

def latest-file [] {
    print "Returning last file"
    ls | sort-by modified | last
}
latest-file  # print和echo不一样。echo会返回值，但是print只会打印

40; 50; 60  # 只会显示60
```

把 nusehll 想象成编译性语言：

```nu
# 例子1：
# 在一个expression中不能运行（例如一行命令，一个代码块，一个脚本）
"print hello" | save rm_rjx.nu; source rm_rjx.nu  # 报错，因为需要先parse，再evaluate
# 分开写就可以
"print hello" | save rm_rjx.nu  # 先编译，再执行
source rm_rjx.nu  # 再编译，再执行

# 例子2：
let my_path = "~/nushell-files"; source $"($my_path)/common.nu"  # 报错，对于第2个命令，不evaluate就不会知道变量名，不知道变量名也就不能parse（之狼循环）
# 解决办法
const my_path = "~/nushell-files"; source $"($my_path)/common.nu"  # 将my_path定义成一个constant，就可以解决这个问题

# 例子3：
if ("test1/rm_rjx.nu" | path exists) { cd test1; source rm_rjx.nu }
# 修改：
if ("test1/rm_rjx.nu" | path exists) { cd test1; source test1/rm_rjx.nu }
```

这也意味着 nushell 不能像 bash 一样执行`eval`命令。

使用`par-each`来并行化操作，提高效率：

```nu
ls *.txt | each { |i| echo $"这是文件：($i.name)" }  # 低效
ls *.txt | par-each { |i| echo $"这是文件：($i.name)" }  # 高效
```

nushell 的 record 数据类型，类似于 python 里的字典：

```nu
{'name': 'nu', 'stars': 5, 'language': 'Python'} | upsert language 'Rust'  # 给record中添加键值对
```

数据可以转换成其他格式：

```nu
[one two three] | to yaml
[one two three] | to json
```

打印 nushell 中的 table 数据：

```nu
# 第1种写法：先统一声明head，再描述每个数据
[[framework, language]; [Django, Python] [Laravel, PHP]]
[[head1 head2 head3];[a1 a2 a3] [b1 b2 b3] [c1 c2 c3]]

# 第2种写法：直接声明每个数据，并附带head
[
 {name: 'Robert' age: 34 position: 'Designer'}
 {name: 'Margaret' age: 30 position: 'Software Developer'}
 {name: 'Natalie' age: 50 position: 'Accountant'}
] | select name age
```

nushell 中将字符串根据符号进行分割：

```nu
let string_list = "one,two,three" | split row ","
```

判断数据是否具有某些字符串，并输出 bool 值：

```nu
"Hello, world!" | str contains "o, w"  # true
{ ColA: test, ColB: 100 } | str contains 'e' ColA  # record中判断某个key的值中是否包括指定字符
[[ColA ColB]; [test 100]] | str contains -i 'E' ColA  # table中判断某列中是否包括指定字符，-i表示忽略大小写
```

# 数据类型

## 快速查找
### 1. 字符串

字符串插值：

```nu
echo $"6乘以7等于(6 * 7)"
```

分割字符串：

```nu
    let string_list = "one,two,three" | split row ","
    ```

判断字符串中是否存在指定字符：

```nu
"Hello, world!" | str contains "o, w"
```

根据指定字符连接字符串：

```nu
[zero one two] | str join ','  # 将列表中的元素按照某个分隔符组合成字符串
```

字符串索引：

```nu
'abcdefg' | str substring 0..4  # 结果包括第0个字符，也包括索引为4个字符，即abcde
'abcdefg' | str substring 0..<4  # 结果包括第0个字符，不括索引为4的字符，即abcd
```

按照指定列名，对字符串进行编译：

```nu
'Nushell 0.80' | parse '{aaa} {bbb}'  # 结果是一个table，head就是aaa和bbb
```

将逗号分隔字符编译成 csv：

```nu
"acronym,long\nAPL,A Programming Language" | from csv  # 能够将“\n”识别成回车
```

文本彩色化：

```nu
$'(ansi purple_bold)This text is a bold purple!(ansi reset)'
```

nushell 允许裸字符串：

```nu
echo hello  # 和“echo "hello"”一样
echo hello world  # 和“echo "hello world"”不一样，通过describe来查看
```

### 2. 列表

**增**：

```nu
[foo bar baz] | insert 1 'beeze'  # 在索引为1的位置插入指定元素
[foo bar baz] | prepend 1998  # 在列表开头插入指定元素
[foo bar baz] | append 1998  # 在列表末尾插入指定元素
```

**改**：

```nu
[1, 2, 3, 4] | update 1 10  # 在索引为1的位置更改元素
```

**查**：

```nu
[cammomile marigold rose forget-me-not] | first 2  # 列出列表最前的2个元素
[cammomile marigold rose forget-me-not] | last 2  # 列出列表最后的2个元素
```

enumarete：

```nu
[a b c d e f g] | enumerate | each { |elt| $"这是索引：($elt.index)，这是元素：($elt.item)" }
```

reduce：

```nu
[1 2 3 4] | reduce {|elt, acc| $elt + $acc}  # 累计加和，结果是10
[1 2 3 4] | reduce -f 1 { |elt, acc| $acc + $elt }  # --fold，添加初始值
```

列表拥有索引：

```nu
[1 2 3 4].2  # 索引为2的元素是3
```

any 判断任意元素的行为，返回 bool 值：

```nu
[Mercury Venus Earth Mars Jupiter 6 Uranus Neptune] | any {|i| $i | str starts-with "E"}  # 如果有任意元素以“E”开头，则返回true
```

遍历判断列表中的元素是否满足某个条件：

```nu
let cond = {|x| $x < 0}
[1998 -12 9 1] | take while $cond  # 结果返回-12，因为只有-12小于0
[1998 -12 9 1] | take while $cond  # 结果返回1998，因为遍历到-12的时候就满足了条件，但是不会包括-12
```

### 3. 表

**增**：

```nu
let $a = [[first_column second_column third_column]; [foo bar snooze]]
let $b = [[first_column second_column third_column]; [hex seeze feeze]]
$a | append $b  # 表头相同，可以直接append
```

**删**

```nu
let teams_scores = [[team score plays]; ['Boston Celtics' 311 3] ['Golden State Warriors', 245 2]]
$teams_scores | drop column  # 删除最后一列
```

### 4. 文件

使用默认编辑器来打开文件

```nu
start rm_rjx.txt
```

在文件后增加内容：

```nu
"hello world" | save --a rm_rjx.txt
```

递归查找文件

```nu
glob **/*.{sh,py} --depth 2  # 递归查找当前目录及其子目录中扩展名为 .sh 或 .py 的文件，但限制递归深度不超过两层。
# 注意：这里的**/*表明了当前目录下的所有文件，不限深度，深度限制只来源于后面的--depth
```

Nushell 的文件监视命令，用于监听文件系统变化并触发指定操作（高级，不懂）：

```nu
watch . --glob=**/*.rs {|| cargo test }  # 运行“cargo test”命令，然后检测当前目录下所有文件
```

### 5. 自定义命令（类似函数）

例如：

```nu
def greet [name: string] {
    $"hello ($name)"
}

# 默认参数
def greet [name = "rjx"] {
    $"hello ($name)"
}

# 位置参数（必填）和标志参数（可选）
def greet [
    name: string
    --age: int
] {
    [$name $age]
}

# 标志参数可缩写
def greet [
    name: string
    --age (-a): int
    --twice
] {
    if $twice {
        [$name $age $name $age]
    } else {
        [$name $age]
    }
}

# 接受任意数量的位置参数
def greet [...name: string] {  # 定义函数 greet，接受任意数量的字符串参数
    print "hello all:"          # 打印固定提示语
    for $n in $name {           # 遍历所有传入的参数
        print $n                # 逐个打印参数内容
    }
}
greet earth mars jupiter venus
```

### 6. 变量

nushell 中的变量是==不可变变量==：

```nu
# let：声明一个不可变变量
let i = 1998
do {let i = 12; $i}  # 这是一个阴影变量shadowing variable，仅在当前scope中生效
$i  # 出了上面的scope，i回到1998

# mut：声明一个可变变量
mut i = 1998
$mut += 1
$mut

# nushll中，闭包、嵌套函数不能捕获 可变变量
# nushll中，闭包使用{}创建，闭包类似于 函数+环境上下文
# 闭包不能修改外部定义的可变变量
mut x = 0
[1 2 3] | each { $x += 1 }  # 报错，闭包不能捕获外部的 可变变量

let x = 0
[1 2 3] | each { $x += 1 }  # 报错，不可变变量 不可直接修改

let x = 0
[1 2 3] | each { $x = $x + 1 }  # 显示3次1999，因为每次闭包x的值都为1998（不可修改）
```

常数变量 constant viable，是不可变的，并且在parse期间就能够evaluate

```nu
const file = 'path/to/file.nu'
source $file
```

使用`?`，来禁止报错

```nu
let files = (ls)
$files.name?.2?  # 如果没有索引为2的文件，也不会报错

# 上面代码等价于
ls | get name?.2?  # 如果没有索引为2的文件，也不会报错
```

将管道的结果分配给变量

```nu
let big_files = (ls | where size > 1g)
$big_files
```

### 7. 模块

使用内联模块，指直接定义在当前文件中的模块，而不是单独放在另一个文件或外部库中的模块：

```nu
module greetings {
    export def hello [name:string] {
        $"hello ($name)!"
    }
    export def hi [name:string] {
        $"hi ($name)!"
    }
}

use greetings hello  # 使用greetings模块中的hello函数
hello rrr
use greetings hi  # 使用greetings模块中的hi函数
hi jjj
```

使用脚本中的模块，新建“greetings.nu”脚本，写入：

```nu
export-env {
    $env.RJX = "这是greetings.nu的变量，变量名叫做 RJX"
}

export def hello [name: string] {
    $"你好 ($name)！"
}
```

导入脚本模块，并在当前环境中使用它的环境：

```nu
use greetings.nu  # 使用模块
greetings hello rrr  # 调用函数/命令
```

## 基础数据类型

### 1. 整数，小数

```nu
1998 | describe  # 可以查看一个值的类型
0xff | describe  # 十六进制
0o77 | describe  # 八进制
0b11 | describe  # 二进制
"1" | describe
1.2 | describe
'1.2' | descibe
'他说："你能帮我拿下杯子吗？"' | describe
```

定义变量时可以指定类型：

```nu
let i: int = 1
let i: float = 1.2
let i: string = "1998"

let num = -2
if $num < 0 { print "这是个负数" }
```

使用 `into type` 来将一个字符串转换为另一种类型：

```nu
"1" | into int
"1.2" | into float
```

### 2. 字符串

```nu
let a: string = "World"
$"hello ($a)"
```

### 3. 布尔值

```nu
let rm_rjx: bool = (2 > 1)
$mybool
```

布尔值通常用于控制流程

### 3. Dates 日期

```nu
date now
date now | format date '%s'
```

### 4. Durations 持续时间

```nu
3.14day
30day / 1sec
```

### 5. Files 文件大小

```nu
0.5kB  # 500B
1GiB / 1B  # 1073741824
```

### 5. Range 范围

```nu
1..5
1..<5
```

### 6. Cell Paths单元格路径

```nu
let cp = $.2
[ foo bar goo glue ] | get $cp  # 索引为2的元素
```

### 7. Closures 闭包

闭包是一个匿名函数，通常称之为lambda函数，接受参数并使用其作用域外的变量

```nu
let compare_closure = {|a| $a > 5}  # 这是一个闭包
let original_list = [ 40 -4 0 8 12 16 -16 ]
$original_list | filter $compare_closure
```

### 8. Bindary data 二进制数据

`0x[ffffff]`、`0o[01234567]`、`0b[01010101010]`分别表示十六进制、八进制、二进制数据

```nushell
open nushell_logo.jpg
| into binary
| first 2
| $in == 0x[ff d8]
```

## 结构化数据类型

### 1. Lists 列表

列表可以写成`[a, b, c]`，也可以写成`[a b c]`。

### 2. Records 记录

类似于python中的字典，一系列的键值对。

```nushell
let my_record = {name: "zhangsan", age: 18}
let my_record = {name: "zhangsan" age: 18}
$my_record | describe  # record<name: string, age: int>

$my_record | get name | describe  # string，只是字符串
$my_record | select name | descripvebe  # record<name: string>，仍然是个record
```

### 3. Table 表

具有行列的二维容器，每个单元格可以储存任何`基本/结构化数据类型`

```nushell
let my_table = [{x:12, y:15}, {x:3, y:6}]
$my_table | get 0
$my_table | get x
```

## 其他数据类型

### 1. Any 任何

主要用于类型标注或者签名。匹配任何类型数据，是其他类型的“超集 superset”

### 2. Block 块

一种由neshell关键字使用的句法形式，例如`if`和`for`

```nushell
if true {print 'hello world!'}  # {print 'hello world!'}就是一个块
```

### 3. Nothing (Null) 空

`nothing`类型用于表示一个值的缺失

```nushell
let my_record = {name: zhangsan, age: 18}
$my_record.name?  # 返回“zhangsan”
$my_record.name  # 返回“zhangsan”
$my_record.city  # 报错
$my_record.city?  # 什么都不返回，即返回空
$my_record.city? | describe  # nothing
```

# 加载数据

## open命令

`open`命令返回的不仅仅是文本（字节流）。还可以识别部分类型的文件，例如：
- xlsx / xls
- csv
- tsv
- json
- url
- yaml / yml
- toml
- eml
- ini
- ics
- nuon
- ods
- SQLite databases
- vcf
- xml

```nushell
open README.md  # 依然可以展示文本内容
```

open命令本质上依旧读取一大串字符串，但是可以从中进行解析

## NUON

Nushell Object Notation。仿JavaScript Object Notation (JSON)。即，部分数据结构是有效的NuShell代码，即为一个有效的NUON，例如：

```text
{
  menus: [
    # Configuration for default nushell menus
    # Note the lack of source parameter
    {
      name: completion_menu
      only_buffer_difference: false
      marker: "| "
      type: {
          layout: columnar
          columns: 4
          col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
          col_padding: 2
      }
      style: {
          text: green
          selected_text: green_reverse
          description_text: yellow
      }
    }
  ]
}
```

没错，NUON是JSON的超集，所有JSON都是NUON。并且NUON更人性化：
1. 允许注释
2. 可以不加逗号

****但是，NUON不能表示所有的数据类型。例如，NUON不允许序列化块 serialization of blocks***

## 处理字符串

绝大部分文件都不是NUON。例如`rm_rjx.txt`：

```text
Octavia | Butler | Writer
Bob | Ross | Painter
Antonio | Vivaldi | Composer
```

```nushell
open rm_rjx.txt | lines  # 转成一个list，每行变成一个元素

open rm_rjx.txt | lines | split row "|"  # 转成一个list

open rm_rjx.txt | lines | split column "|"  # 转成一个table

open rm_rjx.txt | lines | split column "|" | str trim  # 转成一个table，并删除周围多余的空格

open rm_rjx.txt | lines | split column "|" R J X | str trim  # 转成一个table，并删除周围多余的空格，并指定每列名
```

如果文件本身的内容服从特定类型，则可以指定结构来open。例如，`Cargo.lock`文件实际上就是一个`toml`文件，我们可以使用`from`命令的`toml`子命令来实现：

```nushell
open Cargo.lock | from toml
```

## 以原始模式打开文件

```nushell
open Interoceptive_processing_network.csv -r
open Interoceptive_processing_network.csv --raw
```

## SQLite 数据库

```nushell
open rm_rjx.db  # 打开整数据库
open rm_rjx.db | get some_table
open rm_rjx.db | query db "select * from some_table"
```

## 获取URL

使用`http get`命令来加载URL，并将内容返回:

```nushell
http get https://blog.rust-lang.org/feed.xml
```

# 管道 Pipelines

nushell的一个核心就是管道。管道三部分：
1. input / source / producer
2. filter
3. output / sink（`$in`变量可以将管道收集到一个值中，作为一个参数来访问）

```nushell
open Cargo.toml | update workspace.dependencies.base64 0.24.2 | save Cargo_new.toml

[1, 2, 3] | $in.1 * $in.2
```

## 多行管道

一行太长放不下，可以放入`()`内。外部命令，如需多行书写，也需要放入`()`中。

```nushell
let year = (
	"01/22/2021" |
	parse "{month}/{day}|{year}" |
	get year
)

$subj_list | each {|sub|
	(
	external_commands -a aaa
	-b bbb
	-c ccc
	)
}
```

## 分号;

分号之后不会产生输出数据。

```nushell
line1; line2 | line3
```

上例中：`line1`的结果正常打印在终端中。`line2 | line3`的数据结果将在`line1`之后显示。