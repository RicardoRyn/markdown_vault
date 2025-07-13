R是S语言的另外一种实现，S语言已经进化成S-PLUS商业软件

但是R语言完全免费，其开发者之一名为Ross和Robert

R语言的优势：

![image-20240416230032187](..\..\typora_images\image-20240416230032187.png)

32位软件更快，但是最大只支持3G内存，64位则不限制内存，一般使用64位软件

`D:\R\R-4.3.3\bin\x64`下有`Rterm.exe`，类似于linux的R的控制台一致

不管是哪种系统平台，R软件都有3种运行方式：

1. 交互式（windows打开R软件就是交互式）
2. R脚本（`rm_rjx.R`）
3. R工作空间（`rm_rjx.RData`类似于在其他软件中，新建一个工作Project）

`getwd()`：打印目前工作目录

`D:\R\R-4.3.3\etc\Rprofile.site`文件记录了R的默认配置，可以自定义修改：

- 设置工作目录
- 加载常用的包
- 加载用户编写的函数
- 设置默认的CRAN下载网站
- 执行其他各种常见任务

在`Rprofile.site`文件的末尾加上

```R
.First()  # 表示在开始时自动执行，比如可加载某些包
.Last()  # 表示在结束时自动执行，比如执行一些清理操作
```

`RStudio`，一个R语言的集成环境IDE

`RStudio`中，数据集是粉色的，函数是蓝色的，数据框是一个表格图标

控制台中键入：

```R
plot(runif (50))
```

可以在右下角`Plots`窗口中看到绘制的图像

右下角切换成`Packages`窗口，则可以看到R语言中已有的软件包，勾选的包是载入到内存的包

在左下角控制台中可以使用`ctrl+上箭头`，来查找历史命令

使用`esc`键可以终端操作

使用`alt+shift+k`键可以查看所有的快捷键

# 一、开始R工作空间

设置工作目录

```R
setwd(dir="G:/R/R_data")
list.files()  # 查看目录下文件
dir()  # 查看目录下文件，与上一条命令等价
```

赋值：

```R
x <- 3  # 不推荐使用等号来赋值，不装逼，而且在假设检验中可能会有混淆，可以使用alt -来快速输入
x <<- 5  # 强制赋值给一个全局变量
y <- sum(c(1,2,3,4,5))  # 求1，2，3，4，5的均值
```

`ls()`：查看当前工作空间中已经定义的变量

`ls.str()`：不仅列出定义的变量，还会列出内容

`str(rm_rjx)`：列出名为”rm_rjx“的变量的内容

`ls(all.names = TRUE)`：能够列出`.`开头的隐藏变量，”TRUE“要大写

`rm(rm_rjx)`：删除名为”rm_rjx“的变量

`rm(rm_rjx1, rm_rjx2)`

`rm(list=ls())`：删除所有变量

`save.image()`：保存当前工作空间，但不会保存图片

## 安装R包

```R
install.packages("vcd")  # 安装名为“vcd”的包
```

通常情况下，R包安装位置可以不用改，因为**C盘文件夹的downloaded_packages在关闭R或RStudio时会自动删除下载的二进制压缩包，无需担心R包下载过多会影响C盘容量**。
故实际情况下，可以设置**.libPaths()**即可

```R
.libPaths()  # 显示库所在的位置
library()  # 显示库中所有包的名字
```

## 载入包

```R
library(vcd)  # 载入“vcd”包，系统中已经有关于该包的关键字，所以不需要使用引号，没有则报错并终止执行
require(vcd)  # 也是载入“vcd”包，与上一条命令等价，没有不会报错，只会返回False
```

其实R软件本身也是由几个独立的包构成的：

![image-20240417230939740](..\..\typora_images\image-20240417230939740.png)

```R
help(package="vcd")  # 列出有关vcd包的帮助文档
library(help="vcd")  # 也可以列出有关vcd包的一些基础命令
ls("package:vcd")  # 列出vcd包中所有的函数
data(package="vcd")  # 可以列出vcd包中包含的所有数据集

detach("package:vcd")  # 从内存中移除vcd包
remove.packages("vcd")  # 从硬盘中彻底删除vcd包，用的不多
```

## 移植R包到新设备中

在旧设备上：

```R
Rpack <- installed.packages()[,1]  # 打印所有安装的包的名字
save(Rpack,file="Rpack.Rdata")  # 将该名字保存到名为“Rpack.Rdata”的文件中
```

然后在新设备上：

```R
# 使用load函数打开上面保存的文件并存入Rpack变量中
for (i in Rpack) install.packages(i)  # 遍历安装R包
```

## 帮助文档

```R
help(sum)  # 查看sum函数的帮助文档
?plot  # 也是查看sum函数的帮助文档，与上一条等价
args(plot)  # 查看plot函数需要的参数

example(mean)  # 给出mean函数的示例
example(hist)  # 查看绘图的示例
```

专门有关R问题的网站：[rseek.org - rstats search engine](https://rseek.org/)

# 二、R内置数据集

```R
data()  # 显示R中内置的数据集
data(package=.packages(all.available=TRUE))  # 显示R中所有包里可用的数据集

data(Chile, package="car")  # 在不导入“car”包的情况下，加载“Chile”数据集
```

这些数据集包括了R使用中的大部分数据类型：

- 向量
- 矩阵
- 列表
- 因子
- 数据框
- 时间序列

`G:\R\learning_materials\R内置数据集.pdf`中显示了一些常用数据集的含义

例如有以下5个数据集：

1. state.abb：向量，美国50个州的双字母缩写
2. state.area：向量，美国50个州的面积
3. state.name：向量，美国50个州的全称
4. state.division：因子，美国50个州的分类，共9个类别
5. state.region：因子，美国50个州的地理分类

```R
state <- data.frame(state.name, state.abb, state.area, state.division, state.region)  # 将5个类似向量的数据合并成一个数据框，并保存在名为“state”的变量中
heatmap(volcano)  # 将“volcano”数据集画成热图
```

# 三、数据结构

R中的数据类型：

1. 数值型：直接计算，加减乘除
2. 字符串型：可以连接、转换、提取
3. 逻辑型：真、假
4. 日期型

![image-20240418002702685](..\..\typora_images\image-20240418002702685.png)

![image-20240418002713830](..\..\typora_images\image-20240418002713830.png)

 ![image-20240418002742440](..\..\typora_images\image-20240418002742440.png)

## 1. 向量

用函数c来创建向量c可以表示concatenate、collect、combine

**向量的所有元素必须是同一类型，不能混合**

```R
x <- c(1, 2, 3, 4, 5)
y <- c("one", "two", "three")
z <- c(TRUE, FALSE, T, F)
a <- c(1:100)  # 和python不同，包括1，也包括100
b <- seq(from=1, to=100)  # 和上一条等价
c <- seq(from=1, to=100, by=2)  # 间距为2
d <- seq(from=1, to=100, length.out=10)  # 生成10数字，组成一个向量（等差序列）

e <- rep(2, 5)  # 5个2组成的向量
f <- rep(x, 5)  # 把之前的x向量重复5次
g <- rep(x, each=3)  # 1，1，1，2，2，2，3，3，3，4，4，4，5，5，5
h <- rep(x, each=3, times=2)  # 1，1，1，2，2，2，3，3，3，4，4，4，5，5，5, 1，1，1，2，2，2，3，3，3，4，4，4，5，5，5
i <- rep(x, c(2,4,6,1,3))  # 让x中5个元素的每一个分别对应重复“2，4，6，1，3”次
```

 查看向量中元素的类型：

```R
a <- c(1, 2, "one")  # "1", "2", "one"
mode(a)  # "character"
```

只有1个值的向量也称为标量

```R
a <- 2
b <- 3
c <- "hello, world"
d <- TRUE

a;b;c;d
```

R中使用向量化编程，在统计中效率更高，十分常用 ，类似于python中的numpy

 ### 向量索引

``` R
x <- c(1:100)  # R语言中包括1也包括100
length(x)  # 打印向量长度
x[1]  # 获取向量x中的第一个元素值，R语言中从1开始，不是从0开始
x[0]  # interger(0)，因为0不是正整数
x[-19]  # 除了第19个元素，剩下的所有元素都会被输出
x[c(4:18)]  # 输出第4个和第18个元素
x[c(1,23,45,67,89)]

y <- c(1:10)
y[c(T,F,T,T,F,T,F,F,T,F)]  # 通过逻辑值来索引向量
y[c(T,F,F)]  # 循环使用“T,F”来判断
y[c(T,F,T,T,F,T,F,F,T,F,T)]  # 多出来的一个值是NA，即缺失值
y[c(T,F,T,T,F,T,F,F,T,F,F)]  # 即使多出来的一个，但是是F，所以没有索引到任何值
y[y>5]  # 输出向量中>5的元素
y[y>5 & y<9]  # 注意，不能写成“y[5<y<9]”

z <- c("one", "two", "three", "four", "five")
"one" %in% z  # TRUE

names(y) <- c("rjx1", "rjx2", "rjx3", "rjx4", "rjx5", "rjx6", "rjx7", "rjx8", "rjx9", "rjx10")  # y向量之后会加上一个名字
y["rjx4"]
```

### 增，删，改，查

```R
x <- c(1:100)
x[101] <- 101  # 既可以增，也可以改，也是查
x[102:105] <- 102:105  # 如果没有被赋值的元素，则是缺失值NA
append(x = x, values = 1998, after = 7)  # 在x向量的第5个索引值后面插入1998

x <- c(1:100)
x <- x[-c(1:3)]  # 删除x向量中1:3索引的值
```

### 向量运算

```R
x <- 1:10
y <- rep(2, 10)
z <- c(1,2)

x+1  # 所有元素+1
x+y
x+z  # z被循环使用，但是如果x元素个数不是z元素个数的整数倍，则会报错
x**y  # 幂运算
x%%y  # 取模，返回x除以y的余数
x%/%y  # 整除运算

x>y  # 返回的向量全部是布尔值

c(1,2,3) %in% c(1,2,2,4,5,6)  # TRUE TRUE FALSE
```

使用函数进行向量运算：

```R
x <- -5:5

abs(x)  # 返回向量绝对值
sqrt(c(4,9,16))  # 取平方根
log(c4,8,16), base=2)  # 对数，不加底默认为自然对数
log10(c(10,100,1000))

ceiling(c(-2.3, 3,14))  # -2, 4，向上取整，可等
floor(c(-2.3, 3,14))  # -3, 3，向下取整，可等
trunc(c(-2.3, 3.14))  # -2, 3，返回整数部分
round(c(-2.3, 3.14))  # -2, 3，四舍五入取整
round(c(-2.3, 3.14), digits=2)  # -2.30  3.14，保留2位小数
signif(c(-2.3, 3.14), digits=2)  # -2.3  3.1，保留2位有效数字

x <- 1:100
max(x)
min(x)
range(x)  # 1,100，返回最大值和最小值
mean(x)
median(x)
var(x)
sd(x)
prod(x)  # x中所有元素的积

quantile(x)  # 计算最小值，25%数，中位数，75%分位数，最大值
quantile(x, c(0.3, 0.5, 0.7))  # 计算30%分位数，中位数，70%分位数

x <- c(1,4,3,7,8,9,6,7)
which.max(x)# 返回向量x中最大值的索引
which(x==7)  # 返回向量中7对应的索引值
which(x>5)
```



## 2. 矩阵

R语言中， 可以使用`heatmap`函数直接对矩阵进行画图

```R
heatmap(state.x77)

m <- matrix(1:20,4,5)  # 构建4行5列矩阵，元素值从1到20，如果分配不均则报错。默认沿着列排列
m <- matrix(1:20, 4, 5, byrow = T)  # 沿着行排列
m <- matrix(1:20,4)  # 如果只给行数，则自动为列分配，

rnames <- c("R1", "R2", "R3", "R4")
cnames <- c("C1", "C2", "C3", "C4", "C5")
dimnames(m) <- list(rnames, cnames)  # 给m矩阵加上index和header

x <- 1:20
dim(x) <- c(4,5) # 将向量x变成4行5列的矩阵

x <- 1:20
dim(x) <- c(2,5,2) # 将向量x变成3维数组

```

### 改，查

```R
m <- matrix(1:20,4,5)
rnames <- c("R1", "R2", "R3", "R4")
cnames <- c("C1", "C2", "C3", "C4", "C5")
dimnames(m) <- list(rnames, cnames)

m[1,2]  # 第1行，第2列的元素
m["R1", "C3"]  # 根据名字来索引，先行后列
m[1,c(2,3,4)]  # 第1行，第2、3、4列的元素
m[c(2:4), c(2,3,4)]

m[2,]  # 第2行，所有列，注意后面需要添加一个逗号
m[2]  # 第2行第1个值
m[,3]  # 第3列，所有行，注意前面需要添加一个逗号

m[-1,2]  # 除了第1行的第2列
```

### 矩阵运算

```R
m <- matrix(1:20,4,5)
n <- matrix(21:40,4,5)
a <- matrix(1:9,3,3)

m*n  # 矩阵内积（点积），对应元素相乘
m %*% n  # 矩阵乘法
```

使用函数运算：

```R
colSums(m)  # 计算矩阵m中每列的和
rowSums(m)
colMeans(m)
rowMeans(m)

diag(n)  #返回方阵对角线上的值
t(m)  # 转置
```



## 3. 数组

类似于多维度的矩阵，每个元素必须同类型

```R
dim1 <- c("A1", "A2")
dim2 <- c("B1", "B2", "B3")
dim3 <- c("C1", "C2", "C3", "C4")
x <- array(1:24, c(2,3,4), dimnames=list(dim1,dim2,dim3))
```

## 4. 列表

在R中，列表是最复杂的一种数据结构

向量和矩阵都要求数据类型一致，但是列表则没有这种要求

`state.center`是R中一个默认的列表数据集

```R
a <- 1:20
b <- matrix(1:20,4)
c <- mtcars  # 这是R中自带的一个数据框
d <- "This is a test list"

mlist <- list(a,b,c,d)
mlist <- list(rm_rjx1=a,rm_rjx2=b,rm_rjx3=c,rm_rjx4=d)  # 为列表中的每个元素添加一个名称
```

### 增，查，删

```R
a <- 1:20
b <- matrix(1:20,4)
c <- mtcars  # 这是R中自带的一个数据框
d <- "This is a test list"
list(rm_rjx1=a,rm_rjx2=b,rm_rjx3=c,rm_rjx4=d) 

mlist[1]  # 查找列表mlist的第1个元素，
mlist[c(1,4)]  # 查找列表mlist的第1个和第4个元素
mlist["rm_rjx3"]
mlist$rm_rjx3  # 等价于上一条

class(mlist[1])  # "list"
class(mlist[[1]])  # "integer"

# 在列表中增加元素
mlist[5] <- iris  # 报错
mlist[[5]] <- iris
mlist[["rm_rjx5"]] <- iris  # 添加新的元素并命名为“rm_rjx5”
mlist$rm_rjx5 <- irirs  # 等价于上一条，添加新的元素，并命名为“rm_rjx5”

# 删除元素
mlist <- mlist[-5]
mlist[[5]] <- NULL
```

> 注意：`mlist[1]`和`mlist[[1]]`并不一样，前者输出结果是列表的一个子集，因为列表中的元素可以具有不同的数据类型，所以其子集也是列表。但是后者输出结果是该元素本身的数据类型。

## 5. 数据框

矩阵都要求数据类型一致，但是数据框则没有这种要求

数据框形状上很像矩阵，但是是比较规则的列表，除了表头数据框每一列必须同一类型，每一行可以不同

```R
iris  # 就是一个数据框结构的数据集
state <- data.frame(state.name, state.abb, state.region, state.x77)
```

### 查

```R
state[1]  # 数据框的第一列（不包括index）
state[c(1,2)]
state["Alabama",]  # 特定行
state[,"state.abb"]  # 特定列
state$Alabama  # 特定列，等价于上一条
state["Alabama", "state.abb"]  # 特定cell
```



```R
# 绘制身高体重图
plot(women$height, women$weight)

# 使用线性回归
lm(weight ~ height, data=women)
```

每次使用`$`加载所需数据框的列也很麻烦，R语言使用`attach`函数来加载数据框到R搜索目录中

```R
attach(mtcars)  # 此后直接敲数据框列的名字就可以了，而不需要使用$
colnames(mtcars)
mpg  # mtcars数据框中的一列

detach(mtcars)  # 取消加载该数据框
```

也可以使用`with`函数

```R
with(mtcars, {mpg})  # 也是一种不使用$来加载数据框对应列的方法
with(mtcars, {sum(mpg)})  # 求mtcars数据框中，mpg列的和
```

## 6. 因子

R语言中非常重要的一种数据结构

变量分类：

1. 名义型变量
2. 有序型变量
3. 连续型变量

R语言中，名义型变量和有序型变量就被称为因子（factor），这些分类变量的可能值被称为level，由level构成的向量就被称为因子

**因子的最大一个作用就是用来分类，计算频数和频率**

```R
?mtcars  # 查看数据框mtcars的说明
mtcars$cyl  # 气缸数，可以用来分类
table(mtcars$cyl)  # 使用table函数来对cyl进行频数统计
# 指mtcars这个数据框中的cyl这一列就是一个因子，而其中的4，6，8则是3个level

# 自己新建一个因子
f <- factor(c("red", "red", "green", "blue", "green", "blue", "blue"))
f  # 还会给出因子的level

week <- factor(c("Mon", "Fri", "Thu", "Wed", "Mon", "Fri", "Sun"))  # level并没有顺序
week
week <- factor(c("Mon", "Fri", "Thu", "Wed", "Mon", "Fri", "Sun"), ordered=T, levels=c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))  # level有了顺序（从小到大）
week

fcyl <- factor(mtcars$cyl)  # fcyl就是一个因子
plot(mtcars$cyl)  # 散点图，因为输入是向量
plot(factor(mtcars$cyl))  # bar图，因为输入的是因子

num <- 1:100  # 向量
cut(num, c(seq(0, 100, 10)))  # 将向量num每10个数为一组，进行分组，从而变成因子
```



# 四、处理缺失值

R语言中，NA表示缺失值，not available

**缺失值 不等于 值为0**

NaN表示不可能的值（例如0/0）

Inf表示无穷，分为正无穷（例如1/0）和负无穷（例如-1/0）

```R
1 + NA  # NA
NA == 0  # NA

a <- c(NA, 1:49)
sum(a)  # NA
mean(a)  # NA
sum(a, na.rm=T)  # 1225
mean(a, na.rm=T)  # 25，将NA值移除，整个向量元素数量为49，而不再是50

# 判断数据集中是否有缺失值
is.na(a)  # 返回一组逻辑值，在原值为NA的地方标为TRUE
is.nan(0/0)  # TRUE
is.infinite(1/0)  # TRUE
is.infinite(-1/0)  # TRUE

# 删除缺失值
c <- c(NA, 1:20, NA, AN)
d <- na.omit(c)  # 删除掉向量c中的每一个缺失值

# 在数据框中，会直接删除含有缺失值的sample，即删除一整行
airquality  # 该数据框中含有NA值
na.omit(airquality)  # 删除含有NA值的一整行
```

![image-20240422235611825](..\..\typora_images\image-20240422235611825.png)



# 五、字符串

![image-20240423000213929](..\..\typora_images\image-20240423000213929.png)

字符串相关函数：

```R
nchar("hello world")  # 11， 空格也算一个字符串
nchar(month.name)  # 返回每个月份名字的字符数量
length(month.name)  # 12，返回向量中元素的数量
nchar(c(12, 2, 345))  # 2 1 3

paste("Everybody", "loves", "stats")  # "Everybody loves stats"
paste("Everybody", "loves", "stats", sep="-")  # "Everybody-loves-stats"
names <- c("Moe", "Larry", "Curly")
paste(names, "loves stats")  # 结构是每个名字分别与“loves stats”相连

temp <- substr(x=month.name, start=1, stop=3)  # 提取每个月份名字前3个字母作为简写
toupper(temp)  # 可以将字符串转换成大写
tolower(temp)  # 可以将字符串转换成小写

# 以下需要结合正则表达式，fixed参数就是选择是否使用正则表达式，自己查去吧
sub()  # 替换
gsub()  # 全局替换
grep()  # 查找，类似于linux

x <- c("b", "A+", "AC")
match("AC", x)  # 不支持正则表达式

path <- "/usr/local/bin/R"
strsplit(path, "/")  # "", "usr", "local", "bin", "R"，返回的是一个列表，而不是向量
path2 <- "/usr/local/bin/python"
strsplit(c(path, path2), "/")  # 可以一次性对向量中的每个元素来进行分割，所以需要用列表来存储

# outer函数的使用
face <- 1:13
suit <- c("spades", "clubs", "hearts", "diamonds")
outer(suit, face, FUN=paste, sep="-")  # 生成4x13=52张扑克牌
```

# 六、时间与日期

```R
class(presidents)  # "ts"，这是一个时间序列，虽然看着像数据框
presidents$Qtr1  # 报错，因为不是数据框，所以不能这么写

class(airmiles)  # "ts"
Sys.Date()  # 查看当前时间，打印结果是一个时间类，而不是数字或者文本
class(Sys.Date())  # "Date"

a <- "2024-4-27"
class(a)  # "character"
b <- as.Date(a, format="%Y-%m-%d")
class(b)  # "Data"

seq(as.Date("2017-01-01"), as.Date("2017-07-05"), by=5)


sales <- round(runif(48, min=50, max=100))  # runif用来生成随机数，round用来取整。也就是生成48个50~100的随机整数（R语言中，包括50也包括100），这里表示每个月的销售额
ts(sales, start=c(2010,5), end=c(2014, 4), frequency=12)  # frequency为1表示以年为单位，12表示以月份为单位，4表示以季度为单位。
```



# 七、数据输入

## 1. 键盘输入

```R
# 手动输入
data <- data.frame(patientID=character(0), age=numeric(0), diabetes=character(), status=character())  # 先定义数据都是什么类型
data <- edit(data)  # 在window中会弹出一个窗口，然后可以手动输入数据
fix(data)  # 类似上面，会直接保存为data变量
```



## 2. 读取文件

```R
data <- read.table("G:/R/learning_materials/input.txt")  # 默认空格分隔
class(data)  # "data.frame"
head(data)  # 显示文件头几行
tail(data)  # 显示文件尾几行

data = read.table("G:/R/learning_materials/input.csv", sep=",", header=TRUE)  # header默认为FALSE

data = read.table("G:/R/learning_materials/input 1.txt", header=TRUE, skip=5)  # 跳过前5行的注释信息，直接从第六行读取
data = read.table("G:/R/learning_materials/input 1.txt", header=TRUE, skip=5, nrows=10)  # 跳过5行，第6行为表头，然后再读取10行

x <- read.table("clipboard", header=T, sep='\t')  # 直接读取剪贴板里的内容，赋值到x变量中。
readClipboard()  # 打印出剪贴板里的内容

readLines("G:/R/learning_materials/input.csv", n=5)
scan("G:/R/learning_materials/scan.txt", what=list(rm_rjx1=character(3), rm_rjx2=numeric(0), rm_rjx3=numeric(0)))
```

# 八、保存数据

# 1. 保存数据

```R
x <- rivers
write(x, file="x.txt")  # 可以写变量

x <- read.table("G:/R/learning_materials/input.txt", header=T)
write.table(x, file="x.txt", row.names=FALSE)  # 如果加入了绝对路径，则必须保证路径存在，否则会报错。“append=T”选项可以表示为追加，而不是覆盖文件。
write.table(mtcars, gzfile("newfile.txt.gz"))  # 可以直接写成压缩文件格式
```

# 2. 读写R格式文件

R格式文件有很多优势：

1. 自动压缩处理
2. 存储对象相关R元数据
3. 因子、日期、时间等属性

```R
# .RDS文件，用来保存单个数据文件
iris
saveRDS(iris, file="iris.RDS")  # 存储为.RDS文件，用来保存单个数据
x <- readRDS("iris.RDS")

# .RData文件，用于保存整个project项目内容（不包括图片文件）
load(".RData")  # 读取“.RData”文件，会覆盖同名变量，需要注意
save(iris, iris3, file="iris.RData")  # 保存部分对象
save.image()  # 保存当前工作空间中的所有对象
```



# 九、数据转换

```R
cars32 <- read.csv("G:/R/learning_materials/mtcars.csv", header=T)
class(cars32)  # "data.frame"

# 矩阵 --> 数据框
class(state.x77)  # "matrix" "array"
dstate.x77 <- as.data.frame(state.x77)  # 变换数据类型并存进新的变量
class(dstate.x77)  # "data.frame"

# 数据框 --> 矩阵
x <- as.matrix(data.frame(state.region, state.x77))

# 向量 --> 矩阵
x <- state.abb
dim(x) <- c(5,10)
class(x)  # "matrix" "array"

# 向量 --> 因子
x <- state.abb
as.factor(x)

# 数据框的每一行也都是数据框
state <- data.frame(x, state.region, state.x77)
class(state)  # "data.frame"
y <- state["Alabama",]
class(y)  # "data.frame"
unname(y)  # 去除列名

# 数据框 --> 列表
z <- unlist(unname(y))
class(z)  # "character"
```

