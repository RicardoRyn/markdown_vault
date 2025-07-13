# P1

MATLAB的介绍

“MATLAB不够优雅。”	——王某



# P2

## 矩阵的下标

```matlab
A=[1 21 6;5 17 9;31 2 7]
A(8)  % 9；矩阵的下标是沿着列数，
A([1 3 5])  % 1 31 17
A([1 3;1 3])  % 结果是一个矩阵[1 31;1 31]
A(3,2)  % 2
A([1 3],[1 3])  % 结果是一个矩阵[1 6;31 7]
```

## 矩阵的运算

```matlab
A=[1 2 3; 4 5 4;9 8 7]
B=[3 3 3;2 4 9;1 3 1]
a=2
%% 矩阵间的运算
x1=A+B
x1=A-B
x1=A*B  % 矩阵相乘
x1=A.*B  % 矩阵点乘，对应位置的元素相乘
x1=A/B  % 矩阵A乘以矩阵B的逆
x1=A./B  % 对应位置的元素相除

%% 矩阵与常数的运算
y1=A+a
y1=A-a
y1=A/a
y1=A./a  % 因为a是一个常数，所以点除和除结果一样
y1=A^a  % 即A*A
y1=A.^a  % A矩阵里的每个元素都要乘以常数a
y1=A'  % A矩阵的转置（转置是转置，逆是逆）
```

## 创建矩阵的函数

```matlab
linspace(1,9,5)  % [1 3 5 7 9]；生成一个5个元素的向量，第一个数是1，第5个数是9，中间值为线性关系
eye(5)  % 创建一个5×5的矩阵，但是对角线上全是1，其他元素全是0
zeros(12,15)  % 创建一个12×15的矩阵，所有元素全是0
ones(12,15)  % 创建一个12×15的矩阵，所有元素全是1
diag([2 3 4 5])  % 创建一个4×4的矩阵，对角线上分别是2 3 4 5，其他元素全是0
rand(12,15)  % 创建一个12×15的矩阵，所有元素值在(0,1)内随机
```

## 查找矩阵元素的函数

```matlab
A=[1 2 3;0 5 6;7 0 9]
max(A)  % [7 5 9]；找到矩阵A每一列中最大值，合起来写成一个行向量
max(max(A))  % 9；找到矩阵A里最大的元素
min(A)
min(min(A))
sum(A)  % [8 7 18]；计算矩阵A每一列的和，合起来写成一个行向量
sum(sum(A))  % 计算矩阵A所有元素值的和
mean(A)  % 同理
mean(mean(A))  % 同理
```

## 获取矩阵信息函数

```matlab
A=[1 2 3;0 5 6;7 0 9]
sort(A)  % 对每一列进行从小到大的排序，会完全改变矩阵值的排列
sortrows(A)  % 对第一列进行排序，后面的列都会根据这个排序变换，也就是说每一行都不会变
size(A)  % [3 3]；显示矩阵A每个维度有多大
length(A)  % 3；显示向量/矩阵有多少列（字面意思，有多长，对于多维度矩阵可能这样不好理解）
find(A==6)  % 8；查找矩阵A里值为6的数字的下标是多少，下标是8
```



# P3

创建p3_1.m脚本，写入以下内容：

```matlab
for i=1:10
	x=linspace(0,10,101);
	plot(x,sin(x+i));
	print(gcf,'-deps',strcat('plot',num2str(i),'.ps'));
end
```

一些快捷键：

- 注释：ctrl + r
- 去除注释：ctrl + t
- 智能缩进：选中内容按ctrl + i
- 执行整个脚本：F5
- 执行当前节：ctrl + Enter
- 强制结束：ctrl + c

小技巧：

- 用`;`不显示一些代码的执行结果

- 用`clear all`清楚工作区所有变量，用`close all`关闭所有图

- ```matlab
  A=[1 2 3 4 5 6; ...
     6 5 4 3 2 1];  % 用“...”来分行显示
  ```

## 流程控制语句

判断符号

```matlab
<
>
<=
>=
==
~=  % 不等于
&&  % 与；And
||  % 或；Or
```

语句

```matlab
%% if elseif else；针对true或者false条件
if condition1
	statement1
elseif condition2
	statement2
else
	statement3
end

a=3
if rem(a,2) == 0  % rem(a,2)指a/2取余数
	disp('a是偶数')
else
	disp('a是奇数')
end

%% switch；针对数值条件
switch expression
case value1
	statement1
case value2
	statement2
otherwise
	statement3
end

input_num=1;
switch input_num
case -1
	disp('输入的值是-1');
case 0
	disp('输入的值是0');
case 1
	disp('输入的值是1');
otherwise
	disp('输入的值不是-1或0或1');
end

%% while；针对true或者false条件
while expression
	statement
end

n=1;
while prod(1:n) < 1e100  % prod()就是product乘积的意思，prod(1:4)就是1×2×3×4，在这里就是n!，n的阶乘
	disp(n)
	n=n+1
end

%% for
for variable=start:increment:end
	commands
end

for n=1:10
	a(n)=2^n;  % 这里a这个变量就已经不是一个数了，a(n)表示a的下标n，后面赋值为2^n
end
disp(a)
```

## 为变量预分配空间

为一个变量（矩阵）预先分配好空间，这样有利于提高脚本运行速度，例如以下脚本B跑得更快

```matlab
%% 脚本A
tic  % 结合toc使用可以在命令行窗口显示代码运行时间，“tic/toc”用来模拟秒针行走的声音
for ii=1:2000
	for jj=1:2000
		A(ii,jj)=ii+jj;
	end
end
toc

%脚本B
tic
A=zeros(2000,2000);
for ii=1:size(A,1)
	for jj=1:size(A,2)
		A(ii,jj)=ii+jj;
	end
end
toc

```

## matlab里的函数

我们可以参考matla里的function是怎么建立的，键入：

```matlab
edit(which('mean.m'))  % 打开matlab自带的mean.m文件，也就是mean函数
```

```matlab
function y = mean(x,dim,flag,flag2)
%MEAN   Average or mean value.
%   S = MEAN(X) is the mean value of the elements in X if X is a vector. 
%   For matrices, S is a row vector containing the mean value of each 
%   column. 
%   For N-D arrays, S is the mean value of the elements along the first 
%   array dimension whose size does not equal 1.
% 等等，不展示了
```

### 例1

我们可以自己写一个函数，例如和自由落体相关的函数：

```matlab
function x = freebody(x0,v0,t)  % function名字需要和script名字一样
% 输入x0,v0,t，输出x的值
% 这里元与元之间用的是“点乘”，所以可以算多个情况的值
x = x0+v0.*t+1/2*9.8*t.*t
```

并把它保存为`freebody.m`文件，以后可以调用这个文件，例如：

```matlab
freebody([0 1],[0 1],[10 20])  %  490 1981；因为之前用的是“点乘”所以可以计算两种情况的结果。第一种是在0米开始，初速度为0，落体10秒的结果；第二种是在1米开始，初速度为1，落体20秒的结果。
```

### 例2

多个output的函数

```matlab
function [a,F]=acc(v2,v1,t2,t1,m)
a=(v2-v1)./(t2-t1);
F=m.*a;
```

### 函数里的默认变量

```matlab
inputname  % 输入函数的变量名字
mfilename  % 当前运行的函数的名字
nargin  % 函数的input的数量
nargout  % 函数的output的数量
varargin
varargout
```

```matlab
function [volume]=pillar(Do,Di,height)
if nargin==2
	height=1;  % 如果只有2个input，设置默认height为1
end
volume=abs(Do.^2-Di.^2).*height*pi/4;
```

### 函数指针function handles

```matlab
f=@(x) exp(-2*x);  % f指向“exp(-2*x)”,“@(x)”说明输入是x
x=0:0.1:2;
plot(x,f(x));
```



