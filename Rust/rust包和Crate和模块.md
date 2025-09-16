# 使用包、Crate 和模块管理不断增长的项目

一个**包（package）**可以包含多个**二进制 crate 项**和一个可选的**库 crate**。

“作用域（scope）”指的是代码所在的上下文环境。
在一个作用域里，有一组可以被使用的名字（称为 在作用域中，in scope）。
当我们写代码或编译代码时，程序员和编译器都需要知道，在某个位置出现的名字，到底指的是变量、函数、结构体、枚举、模块、常量，还是其他东西。

你可以创建新的作用域，或者改变哪些名字在作用域内、哪些在作用域外。
在同一个作用域里，不能出现两个同名的东西；如果真的遇到名字冲突，可以通过一些机制来解决。

Rust 提供了一些功能来帮助你组织代码，比如哪些部分对外公开，哪些部分只在内部使用，以及在不同作用域里能用哪些名字。
这些功能通常统称为 **模块系统（the module system）**，主要包括：

- **包（Packages）**：Cargo 提供的一种功能，用来构建、测试和分享 crate。
- **Crates**：由模块组成的一棵树，可以是一个库（library）或者一个可执行程序（binary）。
- **模块（Modules）和 use**：用来控制作用域里的名字和是否公开。
- **路径（Paths）**：一种命名方式，用来找到结构体、函数或模块等代码项。

## 包（Package）和 crate

在 Rust 里，**crate** 是编译时的最小代码单位。
哪怕你只是用 `rustc` 编译一个单独的 `.rs` 文件，编译器也会把它当作一个 crate。

一个 crate 可以包含模块（module），这些模块可以在同一个文件里，也可以拆分到不同文件里，最后一起编译。

crate 有两种类型：

- **二进制 crate（Binary crate）**
  - 可以编译成可执行程序，比如命令行工具或服务器。
  - 必须有一个 `main` 函数，定义程序运行时要做的事。
  - 我们之前写的项目都是这种 crate。
- **库 crate（Library crate）**
  - 没有 `main` 函数，不会直接变成可执行文件。
  - 用来提供可以复用的功能，给其他项目调用。
  - 比如第二章用到的 `rand` crate，它提供了生成随机数的功能。
  - 当 Rustaceans 说 “crate” 时，通常指的就是库 crate，这跟其他语言里的 “library” 很像。

**crate root** 指的是 crate 的入口文件，编译器会从这里开始，把它当作整个 crate 的根模块。

**包（package）** 是对一组 crate 的打包管理。

- 一个包里至少有一个 crate（可以是库，也可以是二进制）。
- 最多只能有一个库 crate，但可以有任意多个二进制 crate。
- 包里有一个 `Cargo.toml` 文件，说明要怎么构建这些 crate。
- `Cargo` 本身就是一个包：它包含一个二进制 crate（命令行工具），还包含一个库 crate（提供和命令行一样的逻辑给其他项目用）。

当使用 `cargo new my-project`，Cargo 会为我们创建一个 **Cargo.toml** 文件（用来描述包和依赖）：

```bash
cargo new my-project
```

同时，它会在 `src` 目录下生成一个 **main.rs** 文件。

为什么没有在 Cargo.toml 里写明 main.rs？
因为 Cargo 遵循一条约定：

- 如果项目里有 `src/main.rs`，它就是一个 **二进制 crate** 的入口文件（crate root），crate 的名字和包名一样。
- 如果有 `src/lib.rs`，那就是一个 **库 crate** 的入口文件，名字同样和包名一致。
- crate root 文件会交给 `rustc`，编译成最终的二进制或库。

在上面的例子中：
包里只有 `src/main.rs`，所以它只包含一个 **二进制 crate**，名字叫 `my-project`。

如果包里同时有 `src/main.rs` 和 `src/lib.rs`，那就说明它同时包含：

- 一个二进制 crate
- 一个库 crate
  这两个 crate 的名字都会和包名相同。

如果想要更多的二进制 crate，可以把文件放到 `src/bin` 目录下：

- `src/bin/foo.rs` 会被编译成一个独立的二进制 crate，名字叫 **foo**。
