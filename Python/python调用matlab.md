# 一、python调用matlab

![img](https://pic2.zhimg.com/80/v2-56fa6e5b6227adf540d5086db7477175_1440w.webp)

找到的python engine路径，即matlab安装路径\extern\engines\python

在对应python环境下键入：

```powershell
python setup.py install
```

有时候报错是因为[setuptools](https://so.csdn.net/so/search?q=setuptools&spm=1001.2101.3001.7020)版本过高。setuptools在58.0版本以后弃用了一些方法，导致matlab.engine中的一些命令无法运行。在cmd中输入如下命令将setuptools降版本至58.0版本即可。

```powershell
pip install setuptools==58.0
```

调用示例：
```python
import matlab.engine


# 启动一个matlab引擎
eng = matlab.engine.start_matlab()  # 可以调用matlab的内置函数。
# 调用matlabhanshu
rm_rjx = eng.rjx_multiplication_matlab(3, 2) # 调用了matlab里的函数，函数名为“rjx_multiplication_matlab”
# 打印结果
print('rm_rjx', rm_rjx, type(rm_rjx))
```

