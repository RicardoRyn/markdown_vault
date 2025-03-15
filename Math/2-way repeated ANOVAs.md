# 一、Multivariate Tests

对多变量方差分析（MANOVA）的统计检验

用于测试**多个因变量的总体均值向量**是否在**不同组**之间存在显著差异

原假设：各组均值相等。**我们希望，维持原假设，也就是p > 0.05**

## 1. Pillai's Trace

描述：Pillai's Trace是通过求和每个特征值的形式来计算的。它被认为是比较稳健的统计量，特别是在样本量较小或数据分布偏离正态分布时

解释：较高的Pillai's Trace值表示组间差异较大。Pillai's Trace值越大，越有可能拒绝原假设（即各组均值相等）

## 2. Wilks' Lambda

描述：Wilks' Lambda是最常用的多变量检验统计量。它通过比较组间和组内方差来度量群体差异

解释：较小的Wilks' Lambda值表示组间差异较大。Wilks' Lambda值越小，越有可能拒绝原假设

## 3. Hotelling's Trace

描述：Hotelling's Trace通过求和特征值来计算，类似于Pillai's Trace，但不是通过每个特征值的比率，而是直接累加特征值

解释：较高的Hotelling's Trace值表示组间差异较大。Hotelling's Trace值越大，越有可能拒绝原假设

## 4. Roy's Largest Root

描述：Roy's Largest Root仅考虑最大的特征值，是一种极端的检验方法，通常用于检测最大差异

解释：较高的Roy's Largest Root值表示组间差异较大。Roy's Largest Root值越大，越有可能拒绝原假设



# 二、Mauchly's Test of Sphericity

用于评估重复测量方差分析（repeated measures ANOVA）中球形假设（sphericity assumption）的统计检验

球形假设是指在重复测量设计中，不同条件之间的方差-协方差矩阵是等方差的，即各组的方差相等，且各组之间的协方差也相等

重复测量方差分析的一个重要假设是球形假设。Mauchly's Test 用于检验这个假设是否成立

原假设：各组的方差相等，且各组之间的协方差也相等。**我们希望，维持原假设，也就是p > 0.05**



# 三、Tests of Within-Subjects Effects

在“Tests of Within-Subjects Effects”部分，通常会包含以下信息：

1. 因子（Factor）：指不同的实验条件或测量时间点。
2. 类型III平方和（Type III Sum of Squares）：用于计算各因子的变异量。
3. 自由度（df）：表示因子和误差的自由度。
4. 均方（Mean Square）：等于平方和除以对应的自由度。
5. F值（F-value）：均方之间的比值，用于检验组内效应的显著性。
6. 显著性水平（p-value）：用于判断是否拒绝原假设。通常情况下，p值小于0.05表示组内效应显著。

例如被试分成2组，分了3个时间点进行数据测量的例子中：

| Source       | Type III Sum of Squares | df   | Mean Square | F    | Sig. (p-value) |
| ------------ | ----------------------- | ---- | ----------- | ---- | -------------- |
| Time         | 25.6                    | 2    | 12.8        | 5.4  | 0.008          |
| Time * Group | 10.4                    | 2    | 5.2         | 2.2  | 0.12           |
| Error(Time)  | 47.6                    | 18   | 2.6         |      |                |

第1行的原假设：所有时间点的均值相等

第2行的原假设：时间点和组别之间没有交互作用

**希望维持还是拒绝原假设取决于我们的研究需求。**



# 四、Tests of Within-Subjects Contrasts

用于比较不同时间点或条件之间的特定差异

它们提供了一种更详细的分析方法，通过对比不同条件或时间点的均值来揭示潜在的趋势或模式

1. Within-Subjects Contrasts（组内对比）：
   - 定义：对比是指在重复测量设计中，对特定时间点或条件之间的均值进行比较。比如，比较第一个时间点与第二个时间点之间的差异，或者比较第一个条件与第三个条件之间的差异。
   - 目的：这些对比帮助我们理解各时间点或条件之间的具体差异，而不仅仅是整体效应。
2. 常见对比类型：
   - 线性对比（Linear Contrast）：测试随时间或条件增加是否存在线性趋势。
   - 二次对比（Quadratic Contrast）：测试是否存在二次趋势（即抛物线形趋势）。
   - 其他高级对比：如立方对比等，可以测试更复杂的趋势。

Linear原假设：不同条件或时间点之间不存在线性趋势

Quadratic原假设：不同条件或时间点之间不存在二次（抛物线）趋势

**希望维持还是拒绝原假设取决于我们的研究需求。**



# 五、Tests of Between-Subjects Effects

用来检验不同组之间是否存在显著差异的部分

用于分析不同组之间的主效应（main effects）和交互效应（interaction effects），尤其是在涉及多组或多种处理条件的实验设计中
| Source    | Type III Sum of Squares | df   | Mean Square | F         | Sig. |
| --------- | ----------------------- | ---- | ----------- | --------- | ---- |
| Intercept | 73.836                  | 1    | 73.836      | 29996.441 | .000 |
| Species   | 10.544                  | 1    | 10.544      | 4283.775  | .000 |
| Error     | .293                    | 119  | .002        |           | 

Intercept 原假设：species和pair不具有交互效应

Species原假设：Species不具有主效应

**希望维持还是拒绝原假设取决于我们的研究需求。**
