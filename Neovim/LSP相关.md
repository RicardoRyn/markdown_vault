# LSP
LSP (Language Server Protocol) 语言服务协议
帮助在 Neovim 中配置代码补全、代码悬停、代码提示等等功能

在 LSP 出现之前，传统的 IDE 都要为其支持的每个语言实现类似的代码补全、文档提示、跳转到定义等功能，不同的 IDE 做了很多重复的工作，并且兼容性也不是很好。 LSP 的出现将编程工具解耦成了 :
- Language Server：负责提供语言支持，包括常见的自动补全、跳转到定义、查找引用、悬停文档提示等功能。
- Language Client：专注于显示样式实现。
 定义了编辑器与语言服务器之间交互协议。

# 代码补全

Neovim 本身不支持代码补全，需要通过插件实现，例如：
- blink-cmp 插件
- nvim-cmp 插件

在安装自动代码补全之前，需要了解几个概念：
- 补全引擎：补全引擎就是为 Neovim 提供代码补全核心功能的插件，比如 blink-cmp。
- 补全源：补全源就是补全引擎需要的数据来源，最常见的来源是来自 Language Server 提供的数据，它会知道某个类有哪些属性和方法等。
- snippet 引擎：snippet 引擎就是自定义代码段的引擎，常见的有 vsnip、luasnip 等。

解释：blink-cmp 是使用 Lua 编写的 补全引擎 插件。可以配置多种外部的补全源，支持 vsnip、luasnip、snippy、 ultisnips 4 种 snippet 引擎 。

```lua
packer.startup({
    function(use)
        ...
        -- 补全引擎
        use("hrsh7th/nvim-cmp")
        -- snippet 引擎
        use("hrsh7th/vim-vsnip")
        -- 补全源
        use("hrsh7th/cmp-vsnip")
        use("hrsh7th/cmp-nvim-lsp") -- { name = nvim_lsp }
        use("hrsh7th/cmp-buffer") -- { name = 'buffer' },
        use("hrsh7th/cmp-path") -- { name = 'path' }
        use("hrsh7th/cmp-cmdline") -- { name = 'cmdline' }

        -- 常见编程语言代码段
        use("rafamadriz/friendly-snippets")

        ...
    end,
    ...
})
```
只有 hrsh7th/nvim-cmp 是补全引擎插件本身，其他 cmp-xxx 基本都是插件补全来源，也就是说当你输入一个变量的时候，可以从多个来源显示补全的内容。