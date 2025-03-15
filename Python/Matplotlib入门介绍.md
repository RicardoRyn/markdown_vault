# Figure的部分
```python
import matplotlib as mpt
import matplotlib.pyplot as plt
import numpy as np
```

## Figure

图布

```python
fig = plt.figure()
fig, ax = plt.subplots()
```

如果键入：

```python
fig, axs = plt.subplots(2, 2)
print(axs)
```

终端显示：

```python
[[<AxesSubplot:> <AxesSubplot:> <AxesSubplot:>]
 [<AxesSubplot:> <AxesSubplot:> <AxesSubplot:>]]
```

## Axes

子图

> 注意区别`axes，ax，子图`和`axis，轴`的区别
>
> 2D图有2个`axis`，3D图有3个`axis`
>
> `axis`可以提供`ticks`和`tick label`

`axes`可以提供`title`，通过`set_title()`

`axes`可以提供`x-label`，通过`set_xlabel()`

`axes`可以提供`y-label`，通过`set_ylabel()`

Axes类，以及其`member functions`都是OOP交互的主要点，有大量的plot方法来定义它们，例如：`ax.plot()`

```python
fig, ax = plt.subplots()
ax.plot([1, 2, 3, 4], [1, 4, 2, 3])
```

## Axis

轴上有`ticks`和`ticklabel`

- `ticks`通过`Locator`来定义

- `ticklabel`通过`Formatter`来定义

## Artist

figure上的每一种“可视化”的元素都被称为`artist`，例如：

- figure
- axes
- axis

也包括：

- Text对象
- Line2D对象
- Collections对象

最后把figure成像呈现出来，所有的artist都会画到“图布”（canvas，我理解就是figure）上

大部分artist都绑定在axes上，一个artist不能被多个axes共享，也不能从一个axes上移到另一个axes上

## 画图方法/函数的输入

画图方法/函数的输入需要是`numpy.array`、`numpy.ma.masked_array`、或者能通过`numpy.asarray`的对象

但是像`pandas`的数据对象和`numpy.matrix`可能不能当作输入

最常见的数据最好是转换成`numpy.array`、`numpy.asarray`，例如：

```python
b = np.matrix([[1, 2], [3, 4]])
b_asarry = np.asarray(b)
```

很多方法也可以解析“addressable对象”，例如字典、`numpy.recarray`、`pandas.DataFrame`

例如：
```python
np.random.seed(19680801)  # 指定一个随机种子码
data = {'a': np.arange(50),  # numpy里的多维数组（numpy.ndarray）
        'c': np.random.randint(0, 50, 50),  # numpy里的多维数组
        'd': np.random.randn(50)}  # numpy里的多维数组
# 变量“data”是一个字典，
data['b'] = data['a'] + 10 * np.random.randn(50)
data['d'] = np.abs(data['d']) * 100

fig, ax = plt.subplots(figsize=(5, 2.7), layout='constrained')  # "constrained"表示ax可以限制在figure中，不需要拖动滑动条来查看完整的ax
ax.scatter('a', 'b', c='c', s='d', data=data)  # “c”表示图像里的每个点的颜色，“s”表示图像里的每个点的半径
ax.set_xlabel('entry a')
ax.set_ylabel('entry b')
```

# 面向对象的pyplot交互

使用Matplotlib基本上有2种方法：

1. 明确地创建Figures和Axes，然后在它们上面调用方法（object-oriented，OO风格）
2. 依赖pyplot自动创建并管理Figures和Axes，然后使用pyplot的方法（pyplot风格）

建议使用OO风格，尤其是对于一些复杂的图，因为方法和脚本可以重复使用；但是pyplot风格对于一些快速交互工作很方便；还有第3种风格，但是这里不多介绍

## OO风格

```python
# 第1步,创建x轴数据
# 数据类型是"numpy.ndarray"
x = np.linspace(0, 2, 100)  # 数据,x从0开始,到2结束,中间平均采取100个点(100个点种包括0和2)

# 第2步,创建figure
# 注意即使在OO风格里面，我们也用“.pyplot.figure”来创建Figure
fig, ax = plt.subplots(figsize=(5, 2.7), layout='constrained')

# 第3步,创建y轴数据
# 数据类型是"numpy.ndarray"
ax.plot(x, x, label='linear')  # 第一个“x”是横坐标；第二个“x”表示“y=x”；“label”表示左上角的图例里蓝线代表“linear”，显示在后面的“legend”里面
ax.plot(x, x**2, label='quadratic')  # 第一个“x”是横坐标，第二个“x”表示“y=x**2”
ax.plot(x, x**3, label='cubic')

# 第4步,创建ax的各种标题与图例
ax.set_xlabel('x label')  # x轴的标题
ax.set_ylabel('y label')  # y轴的标题
ax.set_title("Simple Plot")  # 整个ax的标题
ax.legend();  # 如果前面的数据里没有加“label”，这里不会显示legend，但是会报错，但是报错了还是能出图
```

![Simple Plot](https://matplotlib.org/stable/_images/sphx_glr_usage_003.png)

## pyplot风格

```python
# 第1步,创建x轴数据
# 数据类型是"numpy.ndarray" 
x = np.linspace(0, 2, 100)  # 数据

# 第2步,创建figure
# 这里就没有创建对象fig和对象ax,用的是pyplot风格
plt.figure(figsize=(5, 2.7), layout='constrained')

# 第3步,创建y轴数据
plt.plot(x, x, label='linear')
plt.plot(x, x**2, label='quadratic')
plt.plot(x, x**3, label='cubic')

# 第4步,创建各种标题
plt.xlabel('x label')
plt.ylabel('y label')
plt.title("Simple Plot")
plt.legend();
```

## 第3种风格

即在一些GUI应用种插入Matplotlib，这种完全放弃了pyplot，即使是在figure创建部分

# 签名函数

如果经常需要对不同的数据绘制同一种图，可以使用“signature function”

```python
def my_plotter(ax, data1, data2, param_dict):
    """
    帮助文档：
    """
    out = ax.plot(data1, data2, **param_dict)
    return out

# 定义了一个方法/函数，名叫“my_plotter”
# 这个函数后面可以跟参数1“ax”（之前创建figure时创建的），参数2“data1”（x轴的数据），参数3“data2”（y轴的参数），还有可变参数4“param_dict”（可以输入各种键值对）
# 用法如下：
# 第1步，创建数据
data1, data2, data3, data4 = np.random.randn(4, 100)

# 第2步，创建figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(5, 2.7))  # 这里的“1, 2”应该是表示有1行2列个子图，但我添加了ax3和ax4想展示以下2行2列子图的排列方式发现并不行，原因未知

# 第3步，调用“签名函数”“my_plotter”
my_plotter(ax1, data1, data2, {'marker': 'x'})  # “marker”表示每个点的样式是“x的形状”
my_plotter(ax2, data3, data4, {'marker': 'o'})  # “marker”表示每个点的样式是“o的形状”
# “marker”后面还能跟{'d':菱形,'D':大菱形, 'v':倒三角形,'^':正三角,'<':左三角,'>':右三角, 's':方形, '.':小点, ',':一个像素,'p':正五边形, 'P':粗十字形, '+':细十字形, '1':Y形状, '2':上Y形, '3':左Y形, '4':右Y形}
```

# Artist的风格

更改风格有2种方式：

```python
# 第1步，创建figure
fig, ax = plt.subplots(figsize=(5, 2.7))

# 第2步，创建x轴数据
x = np.arange(len(data1))

# 第3步，更改artist风格
# 第(1)种更改方式
ax.plot(x, np.cumsum(data1), color='blue', linewidth=3, linestyle='--')  # “--”表示虚线
# 第(2)种更改方式
l, = ax.plot(x, np.cumsum(data2), color='orange', linewidth=2)  # “l,”后面的“,”不能少，原因未知；
l.set_linestyle(':')  # “:”表示点线
# 还有{实线:'-', 点横线:'-.', }
```

# 颜色风格

“color”见网页：[Specifying Colors — Matplotlib 3.5.2 documentation](https://matplotlib.org/stable/tutorials/colors/colors.html)

```python
fig, ax = plt.subplots(figsize=(5, 2.7))

# 之前我们用“ax.plot()”来画连续的线图（虽然本质是也是大量的点）
# 现在我们用“ax.scatter()”
ax.scatter(data1, data2, s=50, facecolor='C0', edgecolor='k')  # “facecolor”就是指实心点的颜色，相当于“c='b'”
```

# Linewidths, linestyles, and markersizes

```python
fig, ax = plt.subplots(figsize=(5, 2.7))
ax.plot(data1, 'o', label='data1', markersize='10')
ax.plot(data2, 'd', label='data2')
ax.plot(data3, 'v', label='data3')
ax.plot(data4, 's', label='data4')
ax.legend(loc='upper right');
```

“linestyles”见网页：[Linestyles — Matplotlib 3.5.2 documentation](https://matplotlib.org/stable/gallery/lines_bars_and_markers/linestyles.html)

# 关于label

`set_xlabel`、`set_ylabel`和`set_title`都用来在指定位置添加文本

```python
mu, sigma = 115, 15
x = mu + sigma * np.random.randn(10000)
fig, ax = plt.subplots(figsize=(5, 2.7), layout='constrained')

# 
n, bins, patches = ax.hist(x, 50, density=1, facecolor='C0', alpha=0.75)  # “50”表示柱状图上柱的数量

ax.set_xlabel('Length [cm], 'fontsize=14, color='red')
ax.set_ylabel('Probability')
ax.set_title('Aardvark lengths\n (not really)')
ax.text(75, .025, r'$\mu=115,\ \sigma=15$')  # “75, .025”表示文本位置；“r'$\mu=115,\ \sigma=15$'”表示文本内容，首先“$”和“$”之间的内容好像才会识别转义符“\”，然后“\sigma”表示“σ”；“r”表示后面的“\”式原始字符，而不是python的转义字符
ax.axis([55, 175, 0, 0.03])  # 表示x轴在55到175之间，y轴在0到0.03
ax.grid(True);
```

很多键值对都是通用的，具体见网页[Text properties and layout](https://matplotlib.org/stable/tutorials/text/text_props.html)

## 方程表达式

matplotlib的方程表达式可以用TeX语法（LaTeX）

例如
$$
\sigma_i=15
$$
更多表达式的写法见[Writing mathematical expressions](https://matplotlib.org/stable/tutorials/text/mathtext.html)

## 注释Annotations

```python
fig, ax = plt.subplots(figsize=(5, 2.7), layout='constrained')

t = np.arange(0.0, 5.0, 0.01)
s = np.cos(2 * np.pi * t)
line, = ax.plot(t, s, lw=2)  # “line,”后面的“,”不能少

ax.annotate('local max', xy=(2, 1), xytext=(3, 1.5), arrowprops=dict(facecolor='black', shrink=0.05))  # “xy=(2, 1)”表示箭头指着的点的坐标；“xytext=(3, 1.5)”表示箭头末端的文本所在的坐标；

ax.set_ylim(-2, 2)  # 限制y轴范围为-2到2
```

基础注释见[Basic annotation](https://matplotlib.org/stable/tutorials/text/annotations.html#annotations-tutorial)

进阶注释见[Advanced Annotations](https://matplotlib.org/stable/tutorials/text/annotations.html#plotting-guide-annotation)

## 图例

```python
fig, ax = plt.subplots(figsize=(5, 2.7))
ax.plot(np.arange(len(data1)), data1, label='data1')
ax.plot(np.arange(len(data2)), data2, label='data2')
ax.plot(np.arange(len(data3)), data3, 'd', label='data3')
ax.legend()
```

具体见[Legend guide](https://matplotlib.org/stable/tutorials/intermediate/legend_guide.html)

# 关于轴

每种plot都由2~3个axis，大多是x轴和y轴，轴上主要又有“scale”和“ticks”

## scales

matplotlib可以提供**线性**和**非线性**（例如师兄的幂律分布）的scales

```python
fig, axs = plt.subplots(1, 2, figsize=(5, 2.7), layout='constrained')  # “1, 2”表示一个fig里展示1行2列共2张图
xdata = np.arange(len(data1))
data = 10**data1
axs[0].plot(xdata, data)

axs[1].set_yscale('log')  # 将y轴的scale改成log形式
axs[1].plot(xdata, data)
```

![usage](https://matplotlib.org/stable/_images/sphx_glr_usage_012.png)

更多非线性scale见[Scales](https://matplotlib.org/stable/gallery/scales/scales.html)

这种非线性scale往往需要结合“转换transform”，matplotlib可以完成从“数据空间”到“Axes”的转换，详细见[Transformations Tutorial](https://matplotlib.org/stable/tutorials/advanced/transforms_tutorial.html)

## ticks

### locator和formatter

ticks又有2中属性：locator和formatter

```python
fig, axs = plt.subplots(2, 1, layout='constrained')  # “2, 1”表示一张fig里共展示2行1列共2张图
axs[0].plot(xdata, data1)
axs[0].set_title('Automatic ticks')

axs[1].plot(xdata, data1)
axs[1].set_xticks(np.arange(0, 100, 30), ['zero', '30', 'sixty', '90'])  # “np.arange(0, 100, 30)”表示0到100，中间每30写一个ticklabel，“['zero', '30', 'sixty', '90']”表示要写的ticklabel
axs[1].set_yticks([-1.5, 0, 1.5])  # 如果是纯数字就不需要写指定位置？
axs[1].set_title('Manual ticks');
```

![Automatic ticks, Manual ticks](https://matplotlib.org/stable/_images/sphx_glr_usage_013.png)

不同的scales有不同的locator和formatter，详见[Tick locators](https://matplotlib.org/stable/gallery/ticks/tick-locators.html)和[Tick formatters](https://matplotlib.org/stable/gallery/ticks/tick-formatters.html) 

### 轴上展示日期与字符串

除了数字，轴上的tick也可以展示**日期**与**字符串**

```python
fig, ax = plt.subplots(figsize=(5, 2.7), layout='constrained')
dates = np.arange(np.datetime64('2021-11-15'), np.datetime64('2021-12-25'), np.timedelta64(1, 'h'))
data = np.cumsum(np.random.randn(len(dates)))
ax.plot(dates, data)
cdf = mpl.dates.ConciseDateFormatter(ax.xaxis.get_major_locator())
ax.xaxis.set_major_formatter(cdf)
```

![usage](https://matplotlib.org/stable/_images/sphx_glr_usage_014.png)

日期例子见[Date tick labels](https://matplotlib.org/stable/gallery/text_labels_and_annotations/date.html)

字符串例子见[Plotting categorical variables](https://matplotlib.org/stable/gallery/lines_bars_and_markers/categorical_variables.html)

```python
fig, ax = plt.subplots(figsize=(5, 2.7), layout='constrained')
categories = ['turnips', 'rutabaga', 'cucumber', 'pumpkins']

ax.bar(categories, np.random.rand(len(categories)));
```

![usage](https://matplotlib.org/stable/_images/sphx_glr_usage_015.png)

### 额外的轴

比如左边是y轴的刻度，右边就可以是第条y轴的刻度

有两种方式：

- `twinx`和`twiny`
- `secondary_xaxis`和`secondary_yaxis`

```python
fig, (ax1, ax3) = plt.subplots(1, 2, figsize=(7, 2.7), layout='constrained')  # 注意这里命名为“1”和“3”，因为“2”要留着给另一边的y轴用
l1, = ax1.plot(t, s)  # 注意“l1,”后面有“,”
ax2 = ax1.twinx()  # 创建了一个ax2轴
l2, = ax2.plot(t, range(len(t)), 'C1')
ax2.legend([l1, l2], ['Sine (left)', 'Straight (right)'])  # 这里用ax2和ax1其实都可以

ax3.plot(t, s)
ax3.set_xlabel('Angle [rad]')
ax4 = ax3.secondary_xaxis('top', functions=(np.rad2deg, np.deg2rad))  # 可以直接用函数转化原x轴，实现自动对应
ax4.set_xlabel('Angle [°]')
```

![usage](https://matplotlib.org/stable/_images/sphx_glr_usage_016.png)

有时候两边的tick其实不是对应关系，详见[Plots with different scales](https://matplotlib.org/stable/gallery/subplots_axes_and_figures/two_scales.html)

或者采用“第二轴”的方法，详见[Secondary Axis](https://matplotlib.org/stable/gallery/subplots_axes_and_figures/secondary_axis.html)

# 用颜色映射数据

有时我们想用颜色来从第3个维度展示我们的数据

```python
# 准备数据
data1, data2, data3, data4 = np.random.randn(4, 100)
X, Y = np.meshgrid(np.linspace(-3, 3, 128), np.linspace(-3, 3, 128))
Z = (1 - X/2 + X**5 + Y**3) * np.exp(-X**2 - Y**2)

# 创建图布
fig, axs = plt.subplots(2, 2, layout='constrained')  # “2, 2”表示创建一个2行2列的fig，共有4个axes，“axs”是一个np的多维数组，“axs[0,0]、axs[0,1]、axs[1,0]、axs[1,1]”分别表示4个图

# 第1种创建方法（展示一种无极梯度）
# 简称为pc，即“ax.pcolormesh”
pc = axs[0, 0].pcolormesh(X, Y, Z, vmin=-1, vmax=1, cmap='RdBu_r')  # “vmax”和“vmin”表示colorbar的上下限，更多的cmap见下
fig.colorbar(pc, ax=axs[0, 0])
axs[0, 0].set_title('pcolormesh()')

# 第2种创建方法（展示一种梯度）
# 简称为co，即“ax.contourf”
co = axs[0, 1].contourf(X, Y, Z, levels=np.linspace(-1.25, 1.25, 11))  # “-1.25, 1.25”表示colorbar的上下限，“11”表示包括上下限有11个值，中间就有10个范围，也就是说图上能展示10种颜色
fig.colorbar(co, ax=axs[0, 1])
axs[0, 1].set_title('contourf()')

# 第3种创建方法（没看懂）
# 还是称为pc，但用的是“ax.imshow”
pc = axs[1, 0].imshow(Z**2 * 100, cmap='plasma', norm=mpl.colors.LogNorm(vmin=0.01, vmax=100))  # 最后出现的图和横纵坐标的范围不是很能理解
fig.colorbar(pc, ax=axs[1, 0], extend='both')
axs[1, 0].set_title('imshow() with LogNorm()')

# 第4种创建方法
# 依旧是pc，但是用的是“ax.scatter”
pc = axs[1, 1].scatter(data1, data2, c=data3, cmap='RdBu_r')
fig.colorbar(pc, ax=axs[1, 1], extend='both')  # “extend='both'”会为超出colorbar范围的值设计尖头
axs[1, 1].set_title('scatter()')
```

![pcolormesh(), contourf(), imshow() with LogNorm(), scatter()](https://matplotlib.org/stable/_images/sphx_glr_usage_017.png)

更多的cmap见[Choosing Colormaps in Matplotlib](https://matplotlib.org/stable/tutorials/colors/colormaps.html)，也可以自己创建colorbar[Creating Colormaps in Matplotlib](https://matplotlib.org/stable/tutorials/colors/colormap-manipulation.html)

有时我们希望颜色是非线性映射到图上，就像上图的第3张图一样，详见[Colormap Normalization](https://matplotlib.org/stable/tutorials/colors/colormapnorms.html)

colorbar的放置，纵向放、横向放、每张axes都放、还是整个fig只放一个，详见[Placing Colorbars](https://matplotlib.org/stable/gallery/subplots_axes_and_figures/colorbar_placement.html)

# 多个Axes

可以创建多个fig例如`fig = plt.figure()`或者`fig2, ax = plt.subplots()`

`subplot_mosaic`可以实现复杂的布局

```python
fig, axd = plt.subplot_mosaic([['upleft', 'right'], ['lowleft', 'right']], layout='constrained')
axd['upleft'].set_title('upleft')
axd['lowleft'].set_title('lowleft')
axd['right'].set_title('right');
```

![upleft, right, lowleft](https://matplotlib.org/stable/_images/sphx_glr_usage_018.png)

更多Axes排列方式见[Arranging multiple Axes in a Figure](https://matplotlib.org/stable/tutorials/intermediate/arranging_axes.html)和[Complex and semantic figure composition](https://matplotlib.org/stable/tutorials/provisional/mosaic.html)





---





# Pyplot风格介绍

这个风格是模仿的MATLAB，但是它没有OO风格更加灵活

```python
import matplotlib.pyplot as plt
plt.plot([1, 2, 3, 4])
plt.ylabel('some numbers')
plt.show()
```

![pyplot](https://matplotlib.org/stable/_images/sphx_glr_pyplot_001.png)

```python
plt.plot([1, 2, 3, 4], [1, 4, 9, 16])
```

![pyplot](https://matplotlib.org/stable/_images/sphx_glr_pyplot_002.png)

```python
plt.plot([1, 2, 3, 4], [1, 4, 9, 16], 'ro')
plt.axis([0, 6, 0, 20])
plt.show()
```

![pyplot](https://matplotlib.org/stable/_images/sphx_glr_pyplot_003.png)

一张subplot里绘制多条曲线，键入：

```python
import numpy as np

# evenly sampled time at 200ms intervals
t = np.arange(0., 5., 0.2)

# red dashes, blue squares and green triangles
plt.plot(t, t, 'r--', t, t**2, 'bs', t, t**3, 'g^')  # 在一个subplot里绘制了3条曲线，每条都有不同的风格
plt.show()
```

![pyplot](https://matplotlib.org/stable/_images/sphx_glr_pyplot_004.png)

使用关键字keyword绘制

```python
data = {'a': np.arange(50),
        'c': np.random.randint(0, 50, 50),
        'd': np.random.randn(50)}
data['b'] = data['a'] + 10 * np.random.randn(50)
data['d'] = np.abs(data['d']) * 100

plt.scatter('a', 'b', c='c', s='d', data=data)  # 说明“a”和“b”来自于变量“data”
plt.xlabel('entry a')
plt.ylabel('entry b')
plt.show()
```

![pyplot](https://matplotlib.org/stable/_images/sphx_glr_pyplot_005.png)

一张figure里绘制多个subplot

```python
names = ['group_a', 'group_b', 'group_c']
values = [1, 10, 100]

plt.figure(figsize=(9, 3))

plt.subplot(131)
plt.bar(names, values)

plt.subplot(132)
plt.scatter(names, values)

plt.subplot(133)
plt.plot(names, values)

plt.suptitle('Categorical Plotting')
plt.show()
```

![Categorical Plotting](https://matplotlib.org/stable/_images/sphx_glr_pyplot_006.png)

## 控制一些元素的属性

例如：line有很多属性，例如：宽度、颜色、实虚、平滑度；有以下方法设置其属性

### 1. 使用关键字

```python
plt.plot(x, y, linewidth=2.0)
```

### 2. 使用设置好的Line2D实例的方法

```python
line, = plt.plot(x, y, '-')  # 这里“line”后面有个“,”，相当于把line这个元素转换成了一个单独的对象，后面只需要更改这个对象的属性
line.set_antialiased(False) # 然后就可以更改line的各种属性

# 如果有多条线，则
line1, line2 = plt.plot(x1, y1, x2, y2)
# 或者
lines = plt.plot(x1, y1, x2, y2)
```

### 3. 使用setp

setp：set porperties，设置属性

```python
lines = plt.plot(x1, y1, x2, y2)
# setp可以使用keyword
plt.setp(lines, color='r', linewidth=2.0)
# setp也可以使用MATLAB的“string, value”风格
plt.setp(lines, 'color', 'r', 'linewidth', 2.0)
```

Line2D有以下属性：

| Property               | Value Type                                                |
| ---------------------- | --------------------------------------------------------- |
| alpha                  | float                                                     |
| animated               | [True \| False]                                           |
| antialiased or aa      | [True \| False]                                           |
| clip_box               | a matplotlib.transform.Bbox instance                      |
| clip_on                | [True \| False]                                           |
| clip_path              | a Path instance and a Transform instance, a Patch         |
| color or c             | any matplotlib color                                      |
| contains               | the hit testing function                                  |
| dash_capstyle          | [`'butt'` | `'round'` | `'projecting'`]                   |
| dash_joinstyle         | [`'miter'` | `'round'` | `'bevel'`]                       |
| dashes                 | sequence of on/off ink in points                          |
| data                   | (np.array xdata, np.array ydata)                          |
| figure                 | a matplotlib.figure.Figure instance                       |
| label                  | any string                                                |
| linestyle or ls        | [ `'-'` | `'--'` | `'-.'` | `':'` | `'steps'` \| ...]     |
| linewidth or lw        | float value in points                                     |
| marker                 | [ `'+'` | `','` | `'.'` | `'1'` | `'2'` | `'3'` | `'4'` ] |
| markeredgecolor or mec | any matplotlib color                                      |
| markeredgewidth or mew | float value in points                                     |
| markerfacecolor or mfc | any matplotlib color                                      |
| markersize or ms       | float                                                     |
| markevery              | [ None \| integer \| (startind, stride) ]                 |
| picker                 | used in interactive line selection                        |
| pickradius             | the line pick selection radius                            |
| solid_capstyle         | [`'butt'` | `'round'` | `'projecting'`]                   |
| solid_joinstyle        | [`'miter'` | `'round'` | `'bevel'`]                       |
| transform              | a matplotlib.transforms.Transform instance                |
| visible                | [True \| False]                                           |
| xdata                  | np.array                                                  |
| ydata                  | np.array                                                  |
| zorder                 | any number                                                |

想要知道其他元素的属性列表，可以通过调用`setp`函数

```python
lines = plt.plot([1, 2, 3])
plt.setp(lines)
```

然后终端就会显示：

```
alpha: float
animated: [True | False]
antialiased or aa: [True | False]
...snip
```

## Pyplot下的多subplot和多axes

MATLAB和pyplot都有当前figure和当前axes的概念

可以通过函数`gca`（get current axes）和`gcf`（get current figure）来返回当前的axes和figure（不太理解这2个函数怎么用）

```python
def f(t):
    return np.exp(-t) * np.cos(2*np.pi*t)

t1 = np.arange(0.0, 5.0, 0.1)
t2 = np.arange(0.0, 5.0, 0.02)

plt.figure()

plt.subplot(211)  # 当子图少于10个的时候，可以不加逗号（意思就是还可以写成“plt.subplot(2, 1, 1)”）
plt.plot(t1, f(t1), 'bo', t2, f(t2), 'k')

plt.subplot(212)
plt.plot(t2, np.cos(2*np.pi*t2), 'r--')

plt.show()
```

![pyplot](https://matplotlib.org/stable/_images/sphx_glr_pyplot_007.png)

如果需要手动指定每个subplot的位置（不喜欢这种默认位置），可以用`axes`函数（`axes([left, bottom, width, height])  # 全都是0~1的小数`）

也可以直接就画多个figure，可以用`figure`函数，例如：

```python
import matplotlib.pyplot as plt

plt.figure(1)                # the first figure
plt.subplot(211)             # the first subplot in the first figure
plt.plot([1, 2, 3])
plt.subplot(212)             # the second subplot in the first figure
plt.plot([4, 5, 6])


plt.figure(2)                # a second figure
plt.plot([4, 5, 6])          # creates a subplot() by default

plt.figure(1)                # figure 1 current; subplot(212) still current
plt.subplot(211)             # make subplot(211) in figure1 current
plt.title('Easy as 1, 2, 3') # subplot 211 title
```

也可以用`clf`和`cla`来清除当前figure和当前axes

注意：figure会一直在内存中，知道调用`close`，将内存释放。

## Pyplot下的text

`xlabel`、`ylabel`、`title`其实就是特定位置的`text`

```python
mu, sigma = 100, 15
x = mu + sigma * np.random.randn(10000)

# the histogram of the data
n, bins, patches = plt.hist(x, 50, density=1, facecolor='g', alpha=0.75)


plt.xlabel('Smarts')
plt.ylabel('Probability')
plt.title('Histogram of IQ')

plt.text(60, .025, r'$\mu=100,\ \sigma=15$')  # LaTeX的写法？
plt.axis([40, 160, 0, 0.03])
plt.grid(True)
plt.show()
```

![Histogram of IQ](https://matplotlib.org/stable/_images/sphx_glr_pyplot_008.png)

所有的`text`函数都会返回`matplotlib.text.Text`的实例，`text`也是一种元素，可以通过之前介绍的keyword的方法定义它的属性（当然也可以通过`setp`）：

```python
t = plt.xlabel('my data', fontsize=14, color='red')
```

### text经常需要转换空间

|  坐标   |    转换对象     |                             说明                             |
| :-----: | :-------------: | :----------------------------------------------------------: |
|  Data   |  ax.transData   |                 用户数据坐标系。由xlim和ylim                 |
|  Axes   |  ax.transAxes   | 轴的坐标系。 (0，0)位于轴的左下角，而(1，1)位于轴的右上角。  |
| Figure  | fig.transFigure | 该图的坐标系。 (0，0)位于图的左下角，而(1，1)位于图的右上角  |
| Display |      None       | 这是显示器的像素坐标系。 (0，0)是显示的左下角，(宽度，高度)是显示的右上角(以像素为单位)。或者，可以使用(matplotlib.transforms.IdentityTransform())代替无。 |

考虑以下示例

```python
axes.text(x,y,"my label") 
```

文本放置在数据点(x，y)的理论位置。

使用其他转换对象 ，可以控制放置。如，如果将上述测试放置在轴坐标系的中心，请执行以下代码行:

```python
axes.text(0.5, 0.5, "middle of graph", transform=axes.transAxes)
```

这些转换可用于任何Matplotlib对象 。 ax.text 的默认转换为 ax.transData ，而 fig.text 的默认转换为 fig.transFigure。在轴上放置文本时，轴坐标系非常有用。



## Pyplot下的非线性标度

```python
# Fixing random state for reproducibility
np.random.seed(19680801)

# make up some data in the open interval (0, 1)
y = np.random.normal(loc=0.5, scale=0.4, size=1000)
y = y[(y > 0) & (y < 1)]
y.sort()
x = np.arange(len(y))

# plot with various axes scales
plt.figure()

# linear
plt.subplot(221)
plt.plot(x, y)
plt.yscale('linear')
plt.title('linear')
plt.grid(True)

# log
plt.subplot(222)
plt.plot(x, y)
plt.yscale('log')
plt.title('log')
plt.grid(True)

# symmetric log
plt.subplot(223)
plt.plot(x, y - y.mean())
plt.yscale('symlog', linthresh=0.01)
plt.title('symlog')
plt.grid(True)

# logit
plt.subplot(224)
plt.plot(x, y)
plt.yscale('logit')
plt.title('logit')
plt.grid(True)
# Adjust the subplot layout, because the logit one may take more space
# than usual, due to y-tick labels like "1 - 10^{-3}"
plt.subplots_adjust(top=0.92, bottom=0.08, left=0.10, right=0.95, hspace=0.25,
                    wspace=0.35)

plt.show()
```

![linear, log, symlog, logit](https://matplotlib.org/stable/_images/sphx_glr_pyplot_010.png)
