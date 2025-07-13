# Matlab基础

命令行窗口输入`clc`清除命令行窗口全部命令

`clear all`清除工作区全部内容

注释：两个`%%`会有横线，一个`%`没有横线

`abs('a')  % 97`对应”s“的ASCII码

`char(97)  % 'a'`ASCII码对应的内容

`num2str(65)  % '65'`将数字转换成字符串

```matlab
str = 'I love Matlab'
length(str)  % 13
```

# 矩阵

```matlab
A = [1 2 3; 4 5 2; 3 2 7]
B = A'  % 矩阵B是矩阵A的转置
C = A(:)  % 矩阵C是竖着将矩阵A拉长的，即1 4 3 2 5 2 3 2 7
D = inv(A) % 矩阵D是矩阵A的逆，
A * D  % 因为矩阵A和D互逆，所以结果一定是矩阵E（一种特殊的矩阵）
```

```matlab
rand(m, n)  % 生成m行n列的均匀分布的0到1之间的伪随机数
rand(m, n, a)  % 指定精度为a
randn(m, n)  % 生成m行n列的标准正态分布的伪随机数（均值为0，方差为1）
randi(iMax, m, n)  % 生成m行n列的，0到iMax之间的伪随机整数
randi([iMin,iMax], m, n)  % 生成m行n列的，iMin到iMax之间的伪随机整数
```

```matlab
E = zeros(10, 5, 3)  % 10行5列，3维
E(:,:,1) = rand(10, 5)  % 第1维的矩阵是10行5列的0到1随机数，其他维度都为0
E(:,:,2) = randi(7, 10, 5)  % 第2维的矩阵是10行5列的0到7（含右不含左）随机整数
E(:,:,3) = randn(10, 5)  % 第3维的矩阵是10行5列的正态分布随机数
```

# 元胞数组

`eye(3)`是生成一个3*3的对角线数值为1的矩阵

`magic(5)`是生成一个5阶的幻方（幻方就是横、竖、斜方向上所有数字之和相等）

```matlab
A = cell(1, 6)  % 1行6列的元胞数组，即1行有6个盒子
A{2} = eye(3)  % 和Python不同，Matlab是从1开始的；将一个 3*3的对角线数值为1的矩阵 放到A的第2个盒子当中
A{5} = magic(5)
B = A{5}  % 将A中第5个盒子里的幻方赋值给B
```

# 结构体

结构体有点像python里的字典，有key和value

```matlab
books = struct('name', {{'Machine Learning', 'Data Mining'}}, 'price', [30, 40])
books.name  % {'Machine Learning'}    {'Data Mining'}；就是在books里选择name这个属性
books.name(1)  % {'Machine Learning'}；小括号取出来的是 cell
books.name{1}  % 'Machine Learning'；中括号取出来的是 字符串
```

# 矩阵操作

```matlab
A = [1 2 3 5 8 5 4 6]  % 生成一个1行矩阵
B = 1:2:9  % 生成一个1行矩阵，最小值是1，最大值是9，中间隔2个取一个值
C = repmat(B, 3, 2)  % 将矩阵B先横着重复2次，再竖着重复3次，生成新的矩阵C
D = ones(2, 4)  % 生成一个2行4列的值全部为1的矩阵D
```

```matlab
A = [1 2 3 4; 5 6 7 8]
B = [1 1 2 2; 2 2 1 1]
C = A + B  % 矩阵相加
D = A - B  % 矩阵相减
E = A * B'  % 矩阵A与 矩阵B的转置矩阵 相乘
F = A .*B  % 对应相乘
G = A / B  % 矩阵A与 矩阵B的逆 相乘
H = A ./ B  % 对应相除
```

```matlab
% 矩阵的下标
A = magic(5)
B = A(2, 3)  % B是矩阵A中的第2行第3列数
C = A(3,:)  % :指全部，即取出矩阵A的第3行
D = A(4,:)  % 取出矩阵A的第4列
[m, n] = find(A > 20)  % m行n列的值会大于20
```

# 程序结构

```matlab
% 求 1!+2!+3!+4!+5! 的值
sum = 0
for i = 1:5
    p = 1
    for i = 1:i
        p = p * i
    end
    sum = sum +p
end
```

```matlab
% 用while循环求 1+2+3+4+5+6+7+8+9+10 的值
i = 1
sum = 0
while i <= 10
    sum = sum + i
    i = i + 1
end
```

```matlab
a = 100
b = 20
if a > b
    '成立'
else
    '不成立'
end
```

# 二维绘图

颜色选项参数：红色`r`；绿色`g`；蓝色`b`；黄色`y`；分红`m`；青色`c`；白色`w`；黑色`k`

线型选项参数：实线`-`；虚线`--`；冒号线`:`；点画线`-.`

```matlab
x = 0:0.01:2*pi
y = sin(x)
figure  % 建立一个幕布
plot(x, y)  % 绘制一个二维图片
title('y = sin(x)')  % 给该图命名
xlabel('x')  % 命名x轴
ylabel('sin(x)')  % 命名y轴
xlim([0 2*pi])  % 初始图片中x轴的区间
```

```matlab
x = 0:0.01:20
y1 = 200*exp(-0.05*x).*sin(x)
y2 = 0.8*exp(-0.5*x).*sin(10*x)

figure  % matlab默认用不同的颜色区分两条线
[AX, H1, H2] = plotyy(x,y1,x,y2,'plot')  % plotyy是共用一个x坐标系，在y上有不同的取值,会返回3个值；AX是句柄，H1和H2分别是左边和右边的纵轴
set(get(AX(1),'ylabel'),'String','Slow Decay')  % set后需要3个变量
set(get(AX(2),'ylabel'),'String','Fast Decay')
xlabel('Time (\musec)')  % \mu 就是指μ，合起来就是指 微秒
title('Multiple Decay Rates')
set(H1, 'LineStyle', '--')
set(H2, 'LineStyle', ':')

```

![image-20210628170645916](C:\Users\91009\AppData\Roaming\Typora\typora-user-images\image-20210628170645916.png)

# 三维绘图

```matlab
t = 0:pi/50:10*pi

figure
plot3(sin(t), cos(t), t)  % 三维绘图
xlabel('sin(t)')
ylabel('cos(t)')
zlabel('t')
grid on  % 加上一些网格线
axis square  % x轴和y轴单位长度一样，即看起来像正方体
```

```matlab
% 画出一个双峰函数
[x, y, z] = peaks(30)
mesh(x, y, z)
grid on
axis square
```

