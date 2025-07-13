# SNR 信噪比

知识来源：[Mini Tutorial: Signal to noise — NEWBI 4 fMRI](http://www.newbi4fmri.com/mini-tutorial-signal-to-noise)

我们观测某个体素，在时间程上的BOLD信号变化

![image-20230725104234999](..\..\typora_images\image-20230725104234999.png)

**signal**：表示该体素的BOLD信号强度（例如：上图中灰线中，平台稳定时BOLD信号强度为1，即signal为1）

**constant**：表示该体素在静息状态时的BOLD信号强度（例如：上图灰线中，静息状态为时BOLD信号为0，即contant为0）

上图中，灰线都很平滑，这是因为没有噪音noise，接下来添加noise

![image-20230725104206296](..\..\typora_images\image-20230725104206296.png)

**noise**：表示该体素的BOLD信号会在**时间程**上波动，衡量这个波动的方差 (variance)，就被称为noise



## 4种情况

### 第一种：高signal，低noise

![image-20230725104601695](..\..\typora_images\image-20230725104601695.png)

### 第二种：高signal，高noise

![image-20230725104634278](..\..\typora_images\image-20230725104634278.png)

### 第三种：低signal，高noise

![image-20230725104739594](..\..\typora_images\image-20230725104739594.png)

### 第四种：低signal，低noise

![image-20230725104808731](..\..\typora_images\image-20230725104808731.png)

---

如果noise保持不动，signal上升，则 **GLM模型拟合相关性系数 (R, Correlation coefficient)** 上升

如果signal保持不动，noise上升，则 **GLM模型拟合相关性系数 (R, Correlation coefficient)** 下降

# spacial SNR 空间信噪比

![image-20230725112902156](..\..\typora_images\image-20230725112902156.png)
$$
SNR = \frac{Mean_{\,Brain\,tissue\,intensity}}{SD_{\,Background\,intensity}}
$$
