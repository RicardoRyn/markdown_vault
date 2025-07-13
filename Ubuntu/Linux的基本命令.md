# 一、切换bash和tcsh

shell是一个脚本语言，是壳，通过shell告诉计算机做什么

bash是shell语言的衍生版；bash从0开始数，tcsh从1开始数

`echo $0`可以知道当前是`bash`还是`tcsh`

`chsh -s /bin/tcsh`后重启，可以将shell切换成tcsh

命令行可以追根溯源，实验出错可以从这里面寻找原因



# 二、bash下的基本操作

## （一）通配符

例如一个文件夹下有多个文件

```txt
sub-01
sub-02
sub-03
...
sub-98
sub-99
sub-100
```

`*`通配符会显示`sub-`开头的所有文件夹

`??`通配符会显示`sub-`后两位整数的文件夹（即不包括`sub-100`）

## （二）变量切片

bash下的变量切片

```bash
#!/bin/bash
while read rjx
do
    echo ${rjx:0:17}  # 表示从0开始，后17个字符
    echo ${rjx:18:2}  # 表示从18开始，后2个字符
done < unsuccessful_connec_list.txt
```

`${varible#string}`从左往右，删除最短的一个以string结尾的子串，即截取第一个string子串之后的字符串
`${varible##string}`左往右，删除最长的一个以string结尾的子串，即截取最后一个string子串之后的字符串
`${varible%string}`从右往左，删除最短的一个以string开头的子串，即截取最后一个string子串之前的字符串
`${varible%%string}`从右往左，删除最长的一个以string开头的子串，即截取第一个string子串之前的字符串

```bash
STR=abc123bcd456123abc777
echo ${STR#*123}    #bcd456123abc777
echo ${STR##*123}    #abc777
echo ${STR%123*}   #abc123bcd456
echo ${STR%%123*}   #abc
```



## （三）命令

### 1. 常用命令

`/`代表根目录

`~`代表家目录

`.`代表当前目录

`..`代表父目录

`#`代表 root权限

`$`代表普通用户

pwd：打印当前目录

cd：更改目录

ls：list，返回当前目录所有文件和文件夹

ls -lrt：按照时间倒序查看文件list；rt表示reverse time

cat：查看txt内容（查看全部内容）；cat myFile.txt | sort：按数字或字母顺序对文本进行排序；还可以将两个文本文件首尾相连

打开一些图形界面的命令（出现一些可交互式的软件）时，可以在命令末尾加空格再加一个`&`，可以让命令在后台运行，同时保证终端可用。还有一种办法就是使用`ctrl+z`使前台命令休眠，启用终端，最后可以输入`bg`再次唤醒前台。

- `cat test1.txt test2.txt > test3.txt`

head：查看txt内容（只查看开头5行内容）；head -10：查看开头10行内容

tail：查看txt内容（只查看末尾5行内容）；tail -10：查看末尾10行内容

less：与 more 类似，但使用 less 可以随意浏览文件，但若使用了 less 时，就可以使用 [pageup] [pagedown] 等按 键的功能来往前往后翻看文件，更容易用来查看一个文件的内容！`d`表示下一页，`u`表示上一页；输入`/`后再输入指定内容可进行查找；`q`退出

**cp**：复制

- **cp <文件名> <复制地方>**

- ```bash
  cp -r /file1/ \
  	/file2/  # 会在file2文件夹下创建一个file1文件夹，并包含其中所有内容
  ```

**mv**：移动

- **mv <文件名> <移动地方>**

**mkdir**：新建文件夹

- mkdir <文件名>（在当前目录创建文件夹）
- mkdir -p <创建地方>/<文件名>（在指定目录创建指定文件夹）

**rm**：删除

- rm <文件名>
- 在图形界面删除文件会进入回收站，但使用rm命令行删除文件会直接在磁盘中消失（慎重使用该命令）

**rmdir**：删除文件夹

- rmdir <空文件夹>

- 只能删除空文件夹
- 如果文件夹里有东西，则无法删除

**rm -rf** ：删除非空文件夹及其子目录

- rm -rf <非空文件夹>

- r是递归，f是强制，不仅要删除该文件夹，还要删除其子文件的意思，递归着删除（谨慎使用）

**echo**：返回指定变量的值

- ```bash
  sub=sub01  # sub赋值为sub01，等号两边不可加空格
  echo ${sub}  # 返回sub的值,{}也可以不加
  ```

- 不加$，就会返回普通的字符串“sub”，不会将其视为变量

- csh和tcsh中给变量赋值的语法稍有不同

- ```csh 
  set sub = sub01  # sub赋值为sub01
  echo $sub  # # 返回sub的值
  ```

**seq**：

- ```bash
  seq -w 1 15  # 返回一个序列，-w会自动检测最长的值的长度是多少，然后保证返回的值具有相同的长度（这里返回01、02、03直到15）
  ```

**tee**：

- 我们可以把输出重定向到文件中，比如 ls > a.txt，这时我们就不能看到输出了，如果我们既想把输出保存到文件中，又想在屏幕上看到输出内容，就可以使用tee命令了。tee命令读取标准输入，把这些内容同时输出到标准输出和（多个）文件中

- 用“|”或“|&”隔开两个命令之间形成一个管道，左边命令的**标准输出（|）**或者标**准错误输出（|&）**信息流入到右边命令的标准输入，即左边命令的标准输出作为右边命令的标准输入。

- ```bash
  1d_tool.py -show_cormat_warnings -infile X.xmat.${subj}.BLOCK.FN.1D |& tee out.cormat_warn.txt
  
  bash @rm_rjx.sh |& tee run_information.txt  # 包括标准输入和标准输出都能写进run_information.txt文件中
  bash @rm_rjx.sh 2>&1 | tee run_information.txt  # 包括标准输入和标准输出都能写进run_information.txt文件中，和上面一条等价
  bash @rm_rjx.sh &> | tee run_information.txt  # 报错
  ```
  
- ```bash
  ls -l | tee -a rm_rjx.txt  # 追加模式
  
  # 如果你有更复杂的命令，或者是多行脚本，也可以将其输出通过管道传递给 tee：
  {
      echo "Listing current directory contents:"
      ls -l
      echo "Disk usage:"
      df -h
  } | tee rm_rjx.txt
  ```

dpkg：

在使用 `dpkg` 安装 `.deb` 包时，默认情况下，它会将软件安装到系统的预定义位置。`dpkg` 本身并不支持将软件安装到指定的路径，因为它遵循 Debian 的文件系统层次结构标准（FHS）。

```bash
sudo dpkg -i packagename.deb  # 可以安装.deb的文件；-i是安装install的意思
dpkg -L packagename  # 不需要加.deb；显示一个包安装到系统里面的文件目录信息
dpkg -r packagename  # 不需要加.deb；删除软件包（保留其配置信息）
dpkg -P packagename  # 不需要加.deb；删除一个包（包括配置信息）
```

basename：后面跟一个路径的时候，只输出最后的文件名字，而不显示前面的路径`basename /media/ricardo/jojo/RJX/test_HCPPipelines/macaque_data/test_01/RawData/T1w.nii.gz`得到`T1w.nii.gz`字眼



### 2. printf命令

一种格式化输出方式

---

```bash
printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 166.1234
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876
```

结果如下：

```bash
姓名     性别   体重kg
郭靖     男      66.12
杨过     男      48.65
郭芙     女      47.99
```

`%s %c %d %f` 都是格式替代符，`％s` 输出一个字符串，`％d` 整型输出，`％c` 输出一个字符，`％f` 输出实数，以小数形式输出。

`%-10s` 指一个宽度为 10 个字符（`-` 表示左对齐，没有则表示右对齐），**任何字符都会被显示在 10 个字符宽的字符内，如果不足则自动以空格填充，但超过也会将内容全部显示出来**。

`%-4.2f` 指格式化为小数，其中 .2 指保留2位小数。

### 3. sed命令

用于文本编辑的命令

---

写一个文本名为`hello.sh`的文本，包含以下内容：

```bash
#!/bin/bash

echo "Hello, my name is Andy. Here is the name Andy again."
```

你可以用`sed`命令将Andy替换成Bill，只需键入：

```bash
sed "s|Andy|Bill|g" Hello.sh  # s表示swap（交换），g表示global

# sed 命令可以使用任何字符作为文件分隔符；例如：sed "s/name/last name/g" Hello.sh
```

注意并不会改变脚本中的内容，脚本中依旧是Andy，只是在终端中输出的是Bill，如果你想要获得改变了的脚本，需要重定向：

```bash
sed "s|Andy|Bill|g" Hello.sh > Hello_Bill.sh
```

如果要编辑脚本并覆盖它，需要`-i`和`-e`命令：

```bash
sed -i -e "s|Andy|Bill|g" Hello.sh  # i表示in-place（就地），即在原文件中更改，e是让-i和Macintosh操作系统一起工作，没有就会报错，在Linux系统里好像不需要-e
```

---

现有名为`Name.sh`的脚本，内容如下：

```bash
#!/bin/bash

echo "Hi, my name is CHANGENAME."
```

键入：

```bash
for name in Andy John Bill; do
  sed -i -e "s|CHANGENAME|${name}|g" Names.sh > ${name}_Names.sh
done
```

即可创建多个脚本

---

```bash
sed "/name/d" Hello.sh  # d表示delete，会删除name所占的那一整行
```

得到结果：

```bash
#!/bin/bash

```

### 4. grep命令

global search regular expression(RE) and print out the line；全局正则表达式搜索及打印

grep 指令用于**查找内容**包含指定的范本样式的文件，如果发现某文件的内容符合所指定的范本样式，预设 grep 指令会把含有范本样式的那一行显示出来

若不指定任何文件名称，或是所给予的文件名为 **-**，则 grep 指令会从标准输入设备读取数据

### 5. awk命令

#### （1）awk中的内置变量

| 变量名   | 描述                                               |
| -------- | -------------------------------------------------- |
| FILENAME | 当前输入文档的名称                                 |
| FNR      | 当前输入文档的当前行号，尤其当有多个输入文档时有用 |
| NR       | 输入数据流的当前行号                               |
| NF       | 当前记录（行）的字段（列）个数                     |
| FS       | 字段分隔符，默认为空格或Tab制表符                  |
| OFS      | 输出字段分隔符，默认为空格                         |
| ORS      | 输出记录分隔符，默认为换行符\n                     |
| RS       | 输入记录分隔符，默认为换行符\n                     |

#### （2）常规用法

a，w，k分别表示创建这个命令的3位作者的名字。强大的文本分析命令，相对于`grep`的查找，`sed`的编辑

`awk`在对数据分析并生成报告时显得尤为强大。简单来说就是将文本内容逐行读入，空格和制表符将每行切片，切开的部分再进行各种分析处理

```bash
awk '{命令}' 文件
```

假设现有一文本文件`log.txt`内容如下

```bash
2 this is a test
3 Are you like awk
This's a test
10 There are orange,apple,mongo
```

1. 键入：

```bash
awk '{print $1,$4}' log.txt  # $1表示第一个字段，$4表示第四个字段，$0表示整行字段
```

1. 终端显示：

```bash
2 a
3 like
This's
10 orange,apple,mongo
# 因为每行会按 空格 或 TAB 分割，所以该命令会输出文本中的1、4项
```

2. 键入：

```bash
awk 'NR==2{print $3}' log.txt  # NR后指定打印第几行，这里是第2行，打印第3列
```

2. 终端显示：

```bash
you
```

3. 键入：

```bash
awk '{printf "%-8s %-10s\n" $1 $4}' log.txt
# 如果报错就试试以下代码
awk '{printf "%-8s %-10s\n",$1,$4}' log.txt
```

3. 终端显示：

```bash
2        a
3        like
This's
10       orange,apple,mongo
```

#### （3）进阶用法

例如有file文件，内容如下：

```text
the dog: a big dog and a litter dog
the cat: a big cat and a litter cat
the rat: a big rat and a litter rat
```

##### 第1种

`-F`后可以跟特定符号，表示以该符号为界限，将每行分成不同部分

键入：

```bash
awk -F: '{print $2}' file  # 会读取file中每行，然后根据”:“来将其分段（冒号前为一段，冒号后为一段，不包括冒号本身），然后打印第2段；如果没有-F选项，则默认空格、制表符、换行符；-F后面可以直接跟冒号，也可以接空格再接冒号
```

终端会打印：

```text
a big dog and a litter dog
a big cat and a litter cat
a big rat and a litter rat
```

##### 第2种

可同时使用多个命令

```bash
awk -F: '{$1="Description:";print $0}' file  # 注意这里补上了冒号
```

终端显示：

```txt
Description: a big dog and a litter dog
Description: a big cat and a litter cat
Description: a big rat and a litter rat
```

---

##### 第3种

如果你想使用的命令过多，可以另写一个脚本来保存这些命令，例如了灵写一个脚本名为`script1`，那内容如下：

```bash
{
$1="Description:"
print $0
}
```

然后使用awk时可以直接用上面的脚本，只需使用`-f`选项，键入：

```bash
awk -F: -f script1 file
```

终端显示：

```txt
Description: a big dog and a litter dog
Description: a big cat and a litter cat
Description: a big rat and a litter rat
```

##### 第4种

1. 可以使用关键字`BEGIN`来在处理前进行预处理，例如键入：

```bash
awk -F: 'BEGIN{printf "处理前加上这么一句话\n"};{print $2}' file  # 实测中间的”；“也可以用空格代替
```

1. 终端显示：

```bash
处理前加上这么一句话
a big dog and a litter dog
a big cat and a litter cat
a big rat and a litter rat
```

2. `FS`表示输入字段分隔符，键入：

```bash
awk 'BEGIN{FS=":"};{print $1 $2}' file
```

2. 终端显示：

```txt
the dog a big dog and a litter dog
the cat a big cat and a litter cat
the rat a big rat and a litter rat
```

##### 第5种

类似关键字`END`用于在处理后执行命令，键入：

```bash
awk -F: '{print $2};END{print "处理后加上这么一句话"}' file
```

终端显示：

```txt
a big dog and a litter dog
a big cat and a litter cat
a big rat and a litter rat
处理后加上这么一句话
```

### 6. mmv命令

批量重命名命令（需要了解正则表达式）

原始ubuntu系统里没有`mmv`命令

需要键入：

```bash
sudo apt-get install mmv
```

例如：

假设文件夹下有以下文件：

```txt
file1.txt
file2.txt
```

键入：

```bash
mmv -n '*' 'new_#1'  # -n表示测试，并不会真正改名，确认无误后再删除“-n”
```

得到：

```bash
new_file1.txt
new_file2.txt
```

再键入：

```bash
mmv -n 'new_file*.txt' '#1'
```

得到：

```bash
1.txt
2.txt
```

### 7. top命令

top -p <PID号>  # 查看特定PID程序所占用资源

watch -n 5 nvidia-smi  # 显示显卡显存等信息

显示参数：

1. PID：进程号
2. USER：进程所有者用户名
3. PR：进程优先级别
4. NI：进程的优先级别数值
5. VIRT：进程占用的虚拟内存值
6. RES：进程占用的物理内存值
7. SHR：进程使用的共享内存值
8. S表示休眠；R表示运行；Z表示僵死；N表示该进程的优先值是负数
9. %CPU：表示该进程占用CPU的百分比
10. %MRM：表示该进程占用物理内存的百分比
11. TIME+：表示该进程启动后占用的总CPU时间
12. Command：进程启动的启动命令名称

按键操作：

1. shift + p：根据CPU使用大小进行排序
2. shift + t：根据时间、积累时间排序
3. shift + m：根据内存占用量进行排序
4. q：退出top
5. t：切换进程和CPU状态信息
6. m：切换显示内存信息
7. c：切换显示命令名称和完整命令行
8. shift + w：将当前设置写入`~/.toprc`文件中，这是写入top设置的推荐方法

### 8. bash中的数学计算

#### let

使用let进行计算，变量前可以不加`$`

```bash
let a=1+1
echo $a  # 2

let a++
echo $a  # 3，表示a自增1

let a--
echo $a  # 2，表示a自减1

let a+=2
ehco $a  # 4，表示a自加2

let a=a**2
echo $a  # 16，表示a的2次方
```

#### [  ]和((  ))（常用）

使用`[ ]`和`((  ))`进行计算，变量前可以不加`$`

```bash
a=1
b=2
c=$[a+b]
d=$((a+b))
```

#### expr

使用expr进行计算

只能进行整数运算，不支持浮点数

运算符两边必须加上空格，否则会被视为字符串

```bash
a=1
b=2

c=`expr a+b`  # 加号两边 不加空格，最后会被视为字符串
echo $c  # a+b

c=`expr a + b`  # 报错

d=`expr $a+$b`  # 加号两边 不加空格，最后会被视为字符串
echo $d  # 1+2

e = `expr $a + $b`  # 加号两边 加上空格，最后会被当成变量来识别
echo $e  # 3
```

```bash
# expr的另一种用法
expr index "abcdefg" 'b'  # 2，终端直接返回对应的下标

a=(sub01 sub02 sub03)
expr index $a 'sub02'  # 1，终端直接返回对应的下标
```

#### bc（常用）

`bc`是一个用于数学运算的高级工具，包含了大量的选项，可以进行精密的计算。可以设置浮点数精度、进制转换、计算平方根。

直接输入`bc`，可以进入bc环境，然后可以输入表达式直接进行计算，也可以设置一些选项例如`scale=5`，表示设定输入小数精度为5

输入`quit`或者按`Ctrl+d`可以退出`bc`环境

`bc`也可以接受字符串来进行计算。同样可以设定小数精度、进制转换。

```bash
echo "4 * 0.6" | bc  # 2.4
echo "4*0.6" | bc  # 2.4

echo "scale=3; 1/3" | bc  # 0.333

echo "obase=2; 7" | bc  # 111，二进制的7就是111
echo "obase=2; 11+1" | bc  # 111，二进制的12就是1100

echo "sqrt(100)" | bc  # 10

a=$(echo "scale=3; 1/3" | bc)  # “a=$()”是指将命令的输出赋值给变量“a”的语法，会执行括号内的命令，并将值赋值给变量a，即"a=0.333"

# HCP脚本中的数学运算
echo "$SmoothingFWHM / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l  # $SmoothingFWHM / (2 * (2 * ln(2))**0.5)，其中“-l”表示加载数学库并设置默认的精度

if [[ `echo "${Sigma} > 0" | bc -l | cut -f1 -d.` == "1" ]]  # “cut -f1 -d.”的作用是提取第一个字段，以“.”作为分隔符，合起来就是提取整数部分的内容。
```



### 9. paste命令

现有2个文件`file1.txt`和`file2.txt`

`file1.txt`：

```text
apple
banana
grape
```

`file2.txt`：

```text
red
yellow
purple
```

键入：

```bash
paste -d ',' file1.txt file2.txt > file3.txt
```

`file3.txt`：

```text
apple,red
banana,yellow
grape,purple
```

### 10. rsync命令

rsync是Linux系统下的数据镜像备份工具。使用快速增量备份工具Remote Sync可以远程同步，支持本地复制，或者与其他SSH、rsync主机同步。

已支持跨平台，可以在Windows与Linux间进行数据同步数据同步/7231454?fromModule=lemma_inlink)。

简单理解，可以当作升级版`cp`使用

1. **-a**：等价于-rlptgoD（7个命令），是最常用的选项
2. -r：递归
3. -l：--links，创建软连接
4. -p：--perms，保留权限
5. -t：--times，同步时间戳
6. -g：--group，同步组
7. -o：--owner，保留owner
8. -D：保留设备文件及其他特殊文件
9. -d：只保留目录树结构
10. **-v**：显示同步的详细信息
11. **-P或--progress**：显示传输进度
12. **--relative**：保留相对路径结构
13. **--partial**：存已传输的部分文件，当复制过程突然中断时，下次可以继续
14. **--append-verify**：表示当文件部分传输时，从下次从中断的地方继续传输，而不是重新开始，并验证文件是否一致


```bash
rsync -av \
	--exclude='Results/' \  # 除了“Results/”文件夹下的所有内容，都同步/复制
	${current_dir}/${subj}/MNINonLinear/ \  # 源数据
	${path}/${subj}/MNINonLinear/  # 目的位置rsync命令
	
rsync -a -P --relative --partial --append-verify \
	${subj}/Diffusion/topup \
    ${current_dir}/
```

### 11. find命令

`find`命令可以帮助查找指定类型的文件，并且跟`-exec`还可以对这些文件进行制定操作

```bash
# 把A文件夹中的所有文件移动到A文件夹中的B文件夹内
find /path/to/A -maxdepth 1 -type f -exec mv {} /path/to/A/B \;
```

> `-maxdepth 1`：表示只查找当前文件夹中的内容，不递归进入子文件夹
> `-type f`：表示只匹配文件
> `-exec mv {} /path/to/A/B \;`：表示对每个匹配到的文件，执行`mv`命令，将其移动到B文件夹中，其中`\`表示转义符，把`;`转译，代表命令结束



## （四）语句

### 1. 条件语句

#### 一般用法

if：判断

`if [  ]`是bash的传统方式，

1. `[]`内部需要用空格来分隔参数
6. 但是不支持模式匹配（通配符）

`if [[  ]]`是bash的扩展语法，拥有更强大的功能，**（推荐）**

1. 不需要用空格来分隔参数
2. 支持更多的语法，例如正则表达式匹配和模式匹配
3. 支持字符串和整数的比较
4. 允许使用逻辑运算符`&&`和`||`，以及`=~`来进行正则表达式

更具体来说：

1. **字符串条件**
   - `-n STRING`：判断字符串是否非空 non-zero。
   - `-z STRING`：判断字符串是否为空 zero。
   - `STRING1 == STRING2`：判断两个字符串是否相等。
   - `STRING1 != STRING2`：判断两个字符串是否不相等。
2. **数值条件**
   - `-eq`：等于（equal）。
   - `-ne`：不等于（not equal）。
   - `-lt`：小于（less than）。
   - `-le`：小于或等于（less than or equal）。
   - `-gt`：大于（greater than）。
   - `-ge`：大于或等于（greater than or equal）。
3. **文件条件**
   - `-e FILE`：判断文件是否存在。
   - `-f FILE`：判断文件是否为普通文件。
   - `-d FILE`：判断文件是否为目录。
   - `-r FILE`：判断文件是否可读。
   - `-w FILE`：判断文件是否可写。
   - `-x FILE`：判断文件是否可执行。
   - `-s FILE`：判断文件是否为空（文件大小大于零）。
   - `-h FILE` 或 `-L FILE`：判断文件是否为符号链接。
4. **逻辑操作**
   - `! EXPRESSION`：逻辑非，判断表达式是否为假。
   - `EXPRESSION1 -a EXPRESSION2`：逻辑与，当两个表达式都为真时为真。
   - `EXPRESSION1 -o EXPRESSION2`：逻辑或，当任一表达式为真时为真。

```bash
if [ "${struct:0:1}" == "#" ];then                                 
	foo=0                   
elif [ -z "$struct" ];then  # 判断变量struct是否为空，“-z”表示是否为空
	foo=0
fi
```

```bash
  if [[ -e sub01 ]]; then  # -e代表exist，即判断sub01文件夹是否存在，如果结果为真，then...
  echo "sub01 already exist"
  else
  mkdir sub01
  fi  # if反过来就是fi，表示该条件语句已经写完了，按回车执行
```


```bash
if [[ -e sub-01_T1w_brain_f02.nii.gz ]]; then
        echo “Skull-stripped brain exists”
elif [[ -e sub-01_T1w.nii.gz ]]; then  # 这里也要写 then
        echo “Original anatomical brain exists”
else
        echo “Neither the skull-stripped nor the original brain exists”
fi
```

```bash
if [[ -e sub-01_T1w.nii.gz && -e sub-01_T1w_f02_brain.nii.gz ]]; then  # &&表示两者都存在才为True
        echo “Both files exist”
else
        echo “One or more files do not exist”
fi
```

```bash
if [[ -e sub-01_T1w.nii.gz || -e sub-01_T1w_f02_brain.nii.gz ]]; then  # ||表示其中一者存在就为True
        echo “At least one of the files exists”
else
        echo “Neither of the files exists”
fi
```

```bash
if [[ ! -e sub-01_T1w_f02_brain.nii.gz ]]; then  # !表示不存在才为True
        echo “The skull-stripped brain doesn’t exist”
else
        echo “The skull-stripped brain does exist”
fi
```

```bash
if [[ ${hemi} =~ lh_ ]]; then  # 如果hemi变量里包括字符串“lh_”，则执行以下语句
	DriveSuma -com viewer_cont -key 'Ctrl+left' -key a
elif [[ ${hemi} =~ rh_ ]]; then
	DriveSuma -com viewer_cont -key 'Ctrl+right' -key a
fi
```

#### if命令配合定向输入符号

`tee`：`tee` 命令会读取标准输入的数据，然后将其写入一个或多个文件，并且也会输出到标准输出（即终端）。

```bash
some_command | tee -a rm_rjx.txt  # 追加模式

# 如果你有更复杂的命令，或者是多行脚本，也可以将其输出通过管道传递给 tee：
{
    echo "Listing current directory contents:"
    ls -l
    echo "Disk usage:"
    df -h
} | tee rm_rjx.txt
```

`0`：标准输入 stdin

`1`：标准输出 stdout

`2`：标准错误 stderr

`1>`：把标stdout定向到某某地方

`2>`：把stderr定向到某某地方

`&>`：把stdout和stderr都定向到某某地方（bash特有）

`2>&1`：将标准错误定向到标准输出，一般写在最后（我认为应该等价于`&>`）

`1>&2`：将标准输出定向到标准错误，也就把所有东西都当作错误

`<`：重定向stdin（参见while循环）

`<<`：重定向stdin（here document），没搞懂，待研究

`<<<`：重定向stdin（here string），没搞懂，待研究

```bash
if ls *.csv 1> /dev/null 2>&1; then  # ls如果找到对应文件，返回状态就是0，如果没有找到对应文件，返回状态就是1。但是我们只是想知道有没有文件，并不想要打印出这些文件名字，所以把文件输出内容都丢弃，即“> /dev/null”，“/deb/null”是一个设备文件，它会丢弃写入它的任何数据，并且读取它会立即返回EOF（文件结束符），用于丢弃不需要的数据。
	echo "exist"
else            
    echo "no exist"
fi 
```

`/dev/null`（位桶、黑洞）的使用场景：

1. 当你不需要某个命令的输出的时候，就可以将其重定向到`/dev/null`，这样可以防止输出在显示在终端或者写入到文件

#### 判断内容是否为空

```bash
# HCPPipline/NHPPipelines/PreFreeSurfer/scripts/AnatomicalAverage.sh脚本里的语法
if [ X$output = X ] ; then                                                                                        
  echo "The compulsory argument -o MUST be used"
  exit 1;
fi
```



### 2. 循环语句

for：循环遍历

- ```bash
  for i in 1 2 3 4 5
  do
  	echo $i
  done  # 表示循环语句已经写完，按回车执行循环
  ```

- ```bash
  for sub in sub01 sub02 sub03
  do
  	mkdir $sub
  done  # 在当前目录依次创建三个指定文件夹
  ```

- ```bash
  for i in `seq 1 12`  # 遍历1到12
  do
  	mkdir sub$i  # 这里的sub是字符串，后面会读变量i的值
  done
  ```

- ```bash
  for i in `seq -w 1 11`  # -w是零填充，确保都是两位数
  do
  	mkdir sub$i
  done  # 确保创建文件名为sub01而不是sub1
  ```

```bash
#!/bin/bash  
#这一行被称为shebang，它表示以下代码应使用 bash shell 进行解释并遵循 bash 语法。shebang 总是写在文件的第一行，以#和!开头，后面是用于解释代码的 shell 的绝对路径。


basedir=/mnt/hgfs/G/FC_demo
for subj in sub-01 sub-02 sub-03 sub-04 sub-05
do
	# dataset fMRI: Audiovisual Valence Congruence downloaded from openneuro
	# Somehow afni think it's in TLRC space, but it's in ORIG space
	# first step, fix it!

	# Change space from TLRC to ORIG
	3drefit -space ORIG $basedir/$subj/${subj}_func_${subj}_task*bold.nii

	# convert timing files from BIDS to AFNI format
	timing_tool.py -multi_timing_3col_tsv \
		$basedir/$subj/${subj}_func_${subj}_task-affect_run-*events.tsv \
		-write_multi_timing $basedir/$subj/AFNI_timing.
done
```

#### `$@`与`$*`

简单来说：

- 使用 `$*` 时，所有参数被视为一个字符串，并按照空格进行分割
- 使用 `"$@"` 时，每个参数保持独立并且完整

---

**情况1**

```bash
#!/bin/bash
# 现在有名为@rm_rjx.sh的脚本，内容如下
for i in $@
do
    echo $i
done
```

执行脚本`bash @rm_rjx.sh "aaa" "111 bbb" ccc`，终端显示：

```txt
aaa
111
bbb
ccc
```

---

**情况2**

```bash
#!/bin/bash
# 现在有名为@rm_rjx.sh的脚本，内容如下
for i in "$@"
do
    echo $i
done
```

执行脚本`bash @rm_rjx.sh "aaa" "111 bbb" ccc`，终端显示：

```txt
aaa
111 bbb
ccc
```

---

**情况3**

```bash
#!/bin/bash
# 现在有名为@rm_rjx.sh的脚本，内容如下
for i in $*
do
    echo $i
done
```

执行脚本`bash @rm_rjx.sh "aaa" "111 bbb" ccc`，终端显示：

```txt
aaa
111
bbb
ccc
```

---

**情况4**

```bash
#!/bin/bash
# 现在有名为@rm_rjx.sh的脚本，内容如下
for i in "$*"
do
    echo $i
done
```

执行脚本`bash @rm_rjx.sh "aaa" "111 bbb" ccc`，终端显示：

```txt
aaa 111 bbb ccc
```

---

```bash
# bash里的数组，以及“@”和“*”

# 第一种
a=(sub_01 sub_02 sub_03 sub_04 sub_05)  # bash里的常用数据类型，数组
echo ${a[2]} # sub_03，根据下标获取对应元素

echo ${#a[@]}  # 5
echo ${a[@]}  # sub_01 sub_02 sub_03 sub_04 sub_05，打印所有，将每个元素作为单独的字符串来处理

echo ${#a[*]}  # 5
echo ${a[*]}  # sub_01 sub_02 sub_03 sub_04 sub_05，打印所有，将所有的元素作为一个字符串来处理

echo ${!a[@]}  # 0 1 2
echo ${!a[*]}  # 0 1 2

for i in {0..4}
do
	echo ${a[${i}]}
done

# 第二种
a=(sub_01 sub_02 sub_03 sub_04 sub_05)
for i in ${!a[@]}; do  # C语言风格的写法
	# i 就是下标，从0开始
	subj=${a[$i]}  # 根据下标获取元素
done

```

```bash
subj_list=(sub_01 sub_02 sub_03 sub_04 sub_05 sub_06 sub_07 sub_09)
 
current_dir=`pwd`
for i in `seq -w 1 ${#subj_list[@]}`
do
    index=`expr ${i} - 1`
    echo -e "\e[1;32m#################################\e[0m" No.${i}: ${subj_list[10#${index}]} "\e[1;32m#################################\e[0m"
    
    
    
    cd ${current_dir}
done
```

> 注意：bash里的直接`echo ${array}`并不能打印出整个数组，而是打印第一个元素
>
> 想要打印整个数组，需要`echo ${array[@]}`
>
> 合并2个数组成为第3个数组可以`array3=(${array1[@]} ${array2[@]})`

while循环

```bash
# 遍历“structureList.txt”中的，每一行，并赋值给变量structstring，然后打印出来
while read structstring
do
    echo ${structstring}
done < ./structureList.txt
```



## （五）打包与解包

### 1. .zip的压缩文件

解压方法：`unzip test_file.zip`，`-d`后跟制定目录

压缩方法：`zip test_file`

### 2. .gz的压缩文件

解压方法：`gunzip test.file.gz`

压缩方法`gzip test.file`

### 3. .bz2的压缩文件

解压方法：`bzip2 -d test.file.bz2`

压缩方法：`bzip2 test.file`

### 4. .tar的打包文件

***（x表示解包，c表示打包，v表示详细信息，f表示指定文件，下同）***

解包方法：`tar -xf CompressedFile.tar -C ./`，其中`-C`后面指定解包路径

打包方法：`tar -cf CompressedFile.tar test.file`

### 5. .tar.gz的压缩文件

***（z表示用gunzip打/解包）***

解压方法：`tar -zxvf CompressedFile.tar.gz -C ./`，其中-C后面指定解压路径;***最常用就是`tar -zvxf CompressedFile.tar.gz -C ./`***

压缩方法：`tar -zcvf CompressedFile.tar.gz test.file`

### 6. .tar.bz2的压缩文件

***（j表示用bzip2打/解包）***

解压方法：`tar -jxf test.file.tar.bz2 -C ./`

压缩方法：`tar -jcf test.file.tar.bz2 test.file`

---

### 7. .rar的压缩文件

解压方法：`rar x test.file.rar`

压缩方法：`rar a test.file.rar test.file`

## （六）bash下的函数

```bash
xxx() {
	cat <<EOF
	hellow world!
EOF
	exit 1
}
```

这行代码定义了一个名为 `xxx` 的函数。函数体从 `{` 开始，到对应的 `}` 结束。

- `cat <<EOF` 表示一个 Here document，它将多行文本作为输入传递给 `cat` 命令，直到遇到结束标记 `EOF`（End Of File）。
- `hellow world!` 是传递给 `cat` 的实际文本内容。在执行时，`cat` 会输出这个内容。
- `EOF` 是结束标记，表示 Here document 的结尾。

这部分代码的作用是输出 `hellow world!`。

退出命令：

```bash
exit 1
```

这行代码表示函数执行后将以状态码 `1` 退出（状态码 `1` 通常表示一个错误或异常情况，成功执行通常返回状态码 `0`）

#### HCP常用函数

```bash
#!/bin/bash
# 以下是名为@rm_rjx.sh脚本的内容
# 假设运行内容为：bash @rm_rjx.sh --aaa=111 --bbb=222 --ccc=333
#
getopt1() {
    sopt="$1"  # 这里的“$1”，位于函数内，是函数后跟的参数，每次调用该函数时，内容都不同，第一次是“--aaa”，第二次是“--bbb”，第三次是“--ccc”
    shift 1  # 假设是第三次调用函数，函数后的参数为“--ccc --aaa=111 --bbb=222 --ccc=333”，shfit 1之后为“--aaa=111 --bbb=222 --ccc=333”
    for fn in $@ ; do  # 这里的“$@”位于函数内，本该对应于“--ccc --aaa=111 --bbb=222 --ccc=333”，但是shfit 1，所以为“--aaa=111 --bbb=222 --ccc=333”
        if [ `echo $fn | grep -- "^${sopt}=" | wc -w` -gt 0 ] ; then  # “--”是一个特殊的选项，用于告诉 grep 选项部分已经结束，接下来的内容都应被视为模式或文件名，即使它们以“-”开头。这在避免模式和选项混淆时特别有用。虽然在这个例子中没有实际需要，但它是一种好的习惯，特别是在处理可能以“-”开头的模式时。
            echo $fn | sed "s/^${sopt}=//"
            return 0
        fi
    done
}       
        
AAA=`getopt1 "--aaa" $@`  # 这里的“$@”位于函数之外，所以是脚本后跟随的参数，即等价于“--aaa=111 --bbb=222 --ccc=333”
BBB=`getopt1 "--bbb" $@`
CCC=`getopt1 "--ccc" $@`
```



## （七）自定义命令

```bash
#!/bin/bash                                                            
#    
# 第一次尝试写一个完整的 bash 命令
     
usage() {
    cat << EOF
    Usage: bash `basename $0` -i <input_file> -m <mask_fuile> -o <output_file>
EOF  
exit 1
}    
     
if [[ $# -eq 0 ]];then
    usage
fi   
     
     
while getopts ":i:m:o:" opts; do  # 第一个“:”表示静默模式，不会自动打印错误，而是方便用户自定义错误。后面的“:”都是表明前一个字母表示的选项需要跟一个参数，即“i:”表示选型“-i”后面需要跟一个参数，“o:”表示“-o”后面需要跟一个参数
    case ${opts} in
        i)
            input_file=${OPTARG}
            ;;
        m)
            mask_file=${OPTARG}
            ;;
        o)
            output_file=${OPTARG}
            ;;
        \?)  # 自定义错误1：如果给了没有指定的参数，例如“-r”，就会走这行，并把“r”这个字母赋值给变量“OPTARG”
            echo "Invalid option: -${OPTARG}"
            usage
            ;;
        :)  # 自定义错误2：如果给了指定的选项但是没有给参数，就会走这行，并把对应的字母，例如“m”赋值给变量“OPTARG” 
            echo "Option -${OPTARG} requires an argument."
            usage
            ;;
    esac
done 
     
# 判断是否指定必须选项
# 自定义错误3：没有指定必须参数，
if [[ -z ${input_file} ]] || [[ -z ${mask_file} ]] || [[ -z ${output_file} ]]; then
    echo "All -i, -m, -o options are required."
    usage
fi   
     
# 判断输入文件是否存在
if [[ ! -f ${input_file} ]]; then
    echo "Input_file does not exist."
    usage
elif [[ ! -f ${mask_file} ]]; then
    echo "Mask_file does not exist."
    usage
fi   
     
WD=rjx_fill_holes_$(date +%Y%m%d_%H%M%S_%N)
mkdir ${WD}
cp ${input_file} ${WD}/input_file.nii.gz
# 以下命令来自于qyc的@atlas_fill.sh脚本里的内容，目的是生成仅在灰质中的个体atlas，并尽量减少空洞
3dcalc -a ${WD}/input_file.nii.gz \
    -expr 'a' \
    -nscale -datum short \
    -prefix ${WD}/atlas_rb_short_warp2std.nii.gz
# modally smooth here instead (can do it above too and then not use '_m1.5' below)
3dLocalstat -stat mode \
    -nbhd 'SPHERE(-1.5)' \
    -prefix ${WD}/atlas_rb_short_warp2std_m1.5.nii.gz \
    ${WD}/atlas_rb_short_warp2std.nii.gz
# fill in remaining areas with nearby values
3dLocalstat -stat nzmode \
    -nbhd 'SPHERE(-8)' \
    -prefix ${WD}/atlas_rb_short_warp2std_nzm8.nii.gz \
    ${WD}/atlas_rb_short_warp2std.nii.gz
3dcalc -a ${WD}/atlas_rb_short_warp2std_m1.5.nii.gz \
    -b ${WD}/atlas_rb_short_warp2std_nzm8.nii.gz \  
    -c ${mask_file} \   
    -expr '(a+not(a)*b*step(c))*c' \
    -prefix ${output_file}
rm -rf ${WD}
     
exit 0

```



# 三、tcsh下的基本操作

## 1. 赋值与for循环

```bash
#!/usr/bin/env tcsh


set subj  = ( sub-02 sub-03 sub-04 sub-05 )  # tcsh下需要用set赋值，等号两边加空格
set gname = demo

# run afni_proc.py to create a single subject processing script
foreach subj ( $subj )
set top_dir = /mnt/hgfs/G/FC_${gname}/${sbuj}

afni_proc.py -subj_id $subj                                        \
        -script proc.$subj -scr_overwrite                          \
        -blocks tshift align tlrc volreg blur mask scale regress   \
        -copy_anat $top_dir/${subj}_anat_${subj}_T1w.nii             \
        -dsets                                                     \
            $top_dir/${subj}_func_${subj}_task-affect_run-1_bold.nii \
            $top_dir/${subj}_func_${subj}_task-affect_run-2_bold.nii \
            $top_dir/${subj}_func_${subj}_task-affect_run-3_bold.nii \
        -tcat_remove_first_trs 0                                   \
        -align_opts_aea -giant_move                                \
        -tlrc_base MNI152_T1_2009c+tlrc                               \
        -volreg_align_to MIN_OUTLIER                               \
        -volreg_align_e2a                                          \
        -volreg_tlrc_warp                                          \
        -blur_size 4.0                                             \
        -regress_stim_times                                        \
            $top_dir/AFNI_timing.times.1.txt                       \
            $top_dir/AFNI_timing.times.2.txt                       \
            $top_dir/AFNI_timing.times.3.txt                       \
            $top_dir/AFNI_timing.times.4.txt                       \
            $top_dir/AFNI_timing.times.5.txt                       \
        -regress_stim_labels                                       \
            VpAp VpAn VnAp VnAn catch                              \
        -regress_basis 'BLOCK(3,1)'                                \
        -regress_censor_motion 0.3                                 \
        -regress_motion_per_run                                    \
        -regress_opts_3dD                                          \
            -jobs 2                                                \
            -gltsym 'SYM: VpAp -VnAn' -glt_label 1 P-N             \
        -regress_make_ideal_sum sum_ideal.1D                       \
        -regress_est_blur_epits                                    \
        -regress_est_blur_errts
end
```
