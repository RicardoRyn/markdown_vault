# t检验

```python
from scipy import stats


data1 = [15.00, 16.00, 14.00, 16.00, 15.00, 13.00, 16.00, 16.00, 15.00, 11.00]
data2 = [15.00, 15.00, 16.00, 17.00, 16.00, 15.00, 15.00, 17.00, 14.00, 17.00]

# 配对t检验
t_value, p_value = stats.ttest_rel(data1, data2)
print(t_value, p_value)

# 独立样本t检验
t_value, p_value = stats.ttest_ind(data1, data2)
```

# ANOVA

```python
from scipy import stats

data1 = [15.00, 16.00, 14.00, 16.00, 15.00, 13.00, 16.00, 16.00, 15.00, 11.00]
data2 = [15.00, 15.00, 16.00, 17.00, 16.00, 15.00, 15.00, 17.00, 14.00, 17.00]
data3 = [13.00, 13.00, 14.00, 15.00, 15.00, 16.00, 15.00, 14.00, 13.00, 17.00]

# 单因素ANOVA
f_value, p_value = stats.f_oneway(data1, data2, data3)


# 双因素ANOVA
import statsmodels.api as sm
import pandas as pd
from statsmodels.formula.api import ols
from statsmodels.stats.anova import anova_lm
# 假设有两个因素 A 和 B，以及相应的数据
data = {
    'value': [15, 18, 20, 22, 17, 12, 14, 16, 19, 13, 25, 28, 30, 32, 27, 22, 24, 26, 29, 23],
    'A': ['A1']*5 + ['A2']*5 + ['A1']*5 + ['A2']*5,
    'B': ['B1']*10 + ['B2']*10
}
df = pd.DataFrame(data)
# 使用ols函数建立模型
model = ols('value ~ A + B + A*B', data=df).fit()
# 打印模型摘要
print(model.summary())
# 执行双因素ANOVA
anova_table = anova_lm(model, typ=2)
print("\nANOVA Table:")
print(anova_table)
```

# Mann Whitney Wilcoxon rank-sum test

```python
from scipy import stats

data1 = [15.00, 16.00, 14.00, 16.00, 15.00, 13.00, 16.00, 16.00, 15.00, 11.00]
data2 = [15.00, 15.00, 16.00, 17.00, 16.00, 15.00, 15.00, 17.00, 14.00, 17.00]

# 以下2种秩和检验算出来的statistic值不一样，p值接近但也不一样
# SPSS和这2种方法算出来都不一样，但是更接近第二种
# qyc说是因为SPSS可能排除了一部分异常值导致的，当数据量很大时候，SPSS结果可能和第二种方法一样

# 秩和检验1（Mann Whitney Wilcoxon rank-sum test，Mann-Whitney U test）
statistic_value, p_value = stats.ranksums(data1, data2)

# 秩和检验2
# 和SPSS算出来的类似
statistic, p_value = stats.mannwhitneyu(data1, data2, alternative='two-sided')
```

# 相关性

```python
from scipy import stats


data1 = [15.00, 16.00, 14.00, 16.00, 15.00, 13.00, 16.00, 16.00, 15.00, 11.00]
data2 = [15.00, 15.00, 16.00, 17.00, 16.00, 15.00, 15.00, 17.00, 14.00, 17.00]

# 皮尔逊相关
r,p = stats.pearsonr(data1, data2)

# 斯皮尔曼相关
r,p = stats.spearmanr(data1, data2)
```

# Kruskal-Wallis H Test，KW检验

```python
from scipy import stats


data1 = [15.00, 16.00, 14.00, 16.00, 15.00, 13.00, 16.00, 16.00, 15.00, 11.00]
data2 = [15.00, 15.00, 16.00, 17.00, 16.00, 15.00, 15.00, 17.00, 14.00, 17.00]
data3 = [13.00, 13.00, 14.00, 15.00, 15.00, 16.00, 15.00, 14.00, 13.00, 17.00]

# Kruskal-Wallis H Test，KW检验，类似于非参的单样本ANOVA检验
s, p = stats.kruskal(data1, data2, data3)
```

# 线性回归

```python
from scipy import stats
import numpy as np


# 第一种
# 能够算出p值，知道显不显著

x = [5,7,8,7,2,17,2,9,4,11,12,9,6]
y = [99,86,87,88,111,86,103,87,94,78,77,85,86]
x1 = np.arange(0,100)
slope, intercept, rvalue, pvalue, stderr = stats.linregress(x, y)
y_est = slope * x + intercept
y_err = x1.std() * np.sqrt(1/len(x1) + (x1 - x1.mean())**2 / np.sum((x1 - x1.mean())**2)

# 第二种
# 能够拟合高阶曲线
x = [5,7,8,7,2,17,2,9,4,11,12,9,6]
y = [99,86,87,88,111,86,103,87,94,78,77,85,86]
x1 = np.arange(0,100)
slope, intercept = np.polyfit(x, y, deg=1)
y_est = slope * x1 + intercept
y_err = x1.std() * np.sqrt(1/len(x1) + (x1 - x1.mean())**2 / np.sum((x1 - x1.mean())**2)

# 第三种
import statsmodels.api as sm

exog, endog = sm.add_constant(data1), data2
# endog，内生变量，因变量
# exog，外生变量，自变量
model = sm.OLS(endog, exog, missing="drop")
results = model.fit()
# display(results.summary())  # 第1种展示结果的方式
print(results.summary())  # 第2种展示结果的方式
```

# 多重比较校正

```python
from statsmodels.stats import multitest


p_list = np.array([0.05, 0.065, 0.075, 0.001, 0.04, 0.02, 0.06, 0.03])

# 第一种
bool_list, p_list_corr, counts_uncorr, alpha = multitest.fdrcorrection_twostage(
    p_list, alpha=0.05, method='bh', maxiter=1, iter=False, is_sorted=False
)
# bool_list  # 一个数组，告诉你每个p值是否小于α值（一般是0.05）
# p_list_corr  # 一个数组，校正后的p值
# counts_uncorr  # 整数值，没有通过校正的p值数量
# alpha  # 不同阶段设定的alpha值，一般是0.05，然后其他阶段的α值会增加

# 第二种
# 和matlab算出来一样
bool_list, p_list_corr = multitest.fdrcorrection(p_list, alpha=0.05, method='i', is_sorted=False)
# bool_list  # 一个数组，告诉你每个p值是否小于α值（一般是0.05）
# p_list_corr  # 一个数组，校正后的p值
# method{‘i’, ‘indep’, ‘p’, ‘poscorr’, ‘n’, ‘negcorr’}；前4个表示Benjamini/Hochberg表示独立或正相关测试；后2个表示Benjamini/Yekutieli用于一般或负相关测试
```

# z-score

```python
# 生成一组示例数据
data = np.array([10, 12, 15, 18, 20, 22, 25, 28, 30])

# 使用zscore函数进行Z-score标准化
z_scores = zscore(data)

# 打印原始数据和Z-score标准化结果
print("原始数据：", data)
print("Z-score标准化结果：", z_scores)
```

# KL散度

```python
from scipy import stats
# KL散度具有不对称性

KL = stats.entropy(x, y)
print(KL)

KL = stats.entropy(y, x)
print(KL)
```

