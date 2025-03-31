# 1. 创建虚拟环境

进入项目文件夹中，然后创建python环境：
```bash
uv venv -p 3.11
```

可以选择激活当前虚拟环境（但是nushell中好像有问题）：
```bash
source .venv/bin/activate
```

# 2.初始化项目
初始化项目（会在当前目录下生成git、README、pyproject.toml）：
```bash
uv init
```

# 3. 添加必要包
```bash
uv add numpy pandas nibable scipy ipykernel

# 移除包
uv remove neuromaps
```

# 4. 使用与测试
文件建议遵循以下结构：
```text
plotfig_project/
├── src/
│   └─── plotfig
│        ├── __init__.py
│        ├── a.py
│        ├── b.py
│        └─── data/
│             ├── A/*
│             ├── B/*
│             └── C/*
└── pyproject.toml
```

`pyproject.toml`文件内容如下：
```toml
[project]
name = "plotfig"
version = "0.0.6"
description = "Scientific plotting package for Cognitive neuroscience"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "ipykernel>=6.29.5",
    "matplotlib>=3.10.1",
    "mne-connectivity>=0.7.0",
    "nibabel>=5.3.2",
    "numpy>=2.2.4",
    "pandas>=2.2.3",
    "plotly>=6.0.1",
    "scipy>=1.15.2",
    "surfplot>=0.2.0",
]

[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
where = ["."]
include = ["plotfig*"]  # 包含主包及其子包

[tool.setuptools.package-data]
plotfig = [
    "data/atlas_tables/**/*",
    "data/neurodata/**/*"
]

```

可以使用`uv pip install -e .`进行编辑安装

# 5. 打包与发布

也使用`uv build`打包。生成`dist/*.whl`文件，可直接`uv pip install *.whl`在本地安装

`uv tool install twine` 安装`twine`用于上传到Pypi

注册Pypi账号，强制需要双因素（2FA）安全登录，选择`Add 2FA with authentication application`，会弹出一个二维码以及一串2FA代码，创建以下脚本：
```python
import pyotp  # 如果没有就安装这个包

key = '粘贴 2FA 代码'
totp = pyotp.TOTP(key)
print(totp.now())  # 将打印出来的验证码复制回Pypi
```

然后在Pypi中创建API令牌，按照说明在家目录下创建`~/.pypirc`，粘贴以下内容：
```text
[pypi]
  username = __token__
  password = pypi-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

最后就可以上传到Pypi了：
```bash
twine upload dist/*  # 如果有dist文件夹中有.gitignore文件，需要删除
```

有没有人使用`uv pip -e install .`安装调试一个包，在vscode里面能够正常使用，但是没办法跳转到对应函数的位置啊
