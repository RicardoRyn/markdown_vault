# 关于jupyter内核

启动内核

```bash
uv add ipykernel --dev

uv run python -m ipykernel install --user --name=aaa --display-name "Python (AAA)"

uv run jupyter kernelspec list
```

> uv run: 这告诉 uv 使用当前项目 .venv 环境中的 Python 解释器及其依赖包（即你刚刚安装的 ipykernel）。
>
> python -m ipykernel install: 调用 ipykernel 模块进行安装。
>
> --user: 将内核安装到当前用户的配置目录中（这样全局的 Jupyter 也能读取到）。
>
> --name=aaa: 这是内核的系统唯一标识符。建议使用英文小写，不要包含空格。
>
> --display-name "Python (AAA)": 这是你在 Jupyter Notebook 界面上看到的名称，可以随意起名，方便你识别。

有些插件会让你装`jupyter_client`

简单来说：ipykernel 是干活的（执行代码），jupyter_client 是传话的（管理通信）。

通常情况下，ipykernel 依赖于 jupyter_client，所以你只安装 ipykernel 其实也是可以的（uv 会自动把依赖装上），但显式安装两者也没问题。
