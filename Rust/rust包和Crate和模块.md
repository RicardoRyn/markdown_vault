# 使用包、Crate 和模块管理不断增长的项目

一个**包（package）**可以包含多个**二进制 crate 项**和一个可选的**库 crate**。

“作用域（scope）”指的是代码所在的上下文环境。
在一个作用域里，有一组可以被使用的名字（称为 在作用域中，in scope）。
当我们写代码或编译代码时，程序员和编译器都需要知道，在某个位置出现的名字，到底指的是：

- 变量、
- 函数、
- 结构体、
- 枚举、
- 模块、
- 常量，

还是其他东西。

你可以创建新的作用域，或者改变哪些名字在作用域内、哪些在作用域外。
在同一个作用域里，不能出现两个同名的东西；如果真的遇到名字冲突，可以通过一些机制来解决。

Rust 提供了一些功能来帮助你组织代码。
比如哪些部分对外公开，哪些部分只在内部使用，以及在不同作用域里能用哪些名字。
这些功能通常统称为 **模块系统（the module system）**，主要包括：

- **包**：一整个项目，可能包含多个 crate。
- **crate**：编译单元，可以是二进制或库。
- **模块**：crate 内部的代码分组方式，形成模块树。
- **路径（Paths）**：一种命名方式，用来找到结构体、函数或模块等代码项。

## 包与crate

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
  - 比如 `rand` crate，它提供了生成随机数的功能。
  - 当 Rustaceans 说 “crate” 时，通常指的就是库 crate，这跟其他语言里的 “library” 很像。

**crate root** 指的是 crate 的入口文件，编译器会从这里开始，把它当作整个 crate 的根模块。

**包（package）** 是对一组 crate 的打包管理。

- 一个包里至少有一个 crate（可以是库，也可以是二进制）。
- 最多只能有一个库 crate，但可以有任意多个二进制 crate。
- 包里有一个 `Cargo.toml` 文件，说明要怎么构建这些 crate。

> `Cargo` 本身就是一个包：它包含一个二进制 crate（命令行工具），还包含一个库 crate（提供和命令行一样的逻辑给其他项目用）。

当使用 `cargo new my-project`，Cargo 会为我们创建一个 **Cargo.toml** 文件（用来描述包和依赖）：

```bash
cargo new my-project
```

同时，它会在 `src` 目录下生成一个 **main.rs** 文件。

为什么没有在 Cargo.toml 里写明 main.rs？
因为 Cargo 遵循一条约定：

- 如果项目里有 `src/main.rs`，它就是一个 **二进制 crate** 的入口文件（crate root），crate 的名字和包名一样。
- 如果有 `src/lib.rs`，那就是一个 **库 crate** 的入口文件，名字同样和包名一样。
- crate root 文件会交给 `rustc`，编译成最终的二进制或库。

在上面的例子中：
包里只有 `src/main.rs`，所以它只包含一个 **二进制 crate**，名字叫 `my-project`。

如果包里同时有 `src/main.rs` 和 `src/lib.rs`，那就说明它同时包含：

- 一个二进制 crate
- 一个库 crate
  这两个 crate 的名字都会和包名相同。

如果想要更多的二进制 crate，可以把文件放到 `src/bin` 目录下：

- `src/bin/foo.rs` 会被编译成一个独立的二进制 crate，名字叫 **foo**。

## 模块

在深入了解模块和路径之前，这里先提供一个简明的参考，帮助理解 Rust 中：

- 模块、
- 路径、
- `use` 关键词、
- `pub` 关键词。

1. 从 crate 根节点开始
   编译一个 crate 时，Rust 编译器首先会从 crate 根文件开始寻找需要编译的代码：
   - 对于库 crate（library crate），根文件是 _src/lib.rs_
   - 对于二进制 crate（binary crate），根文件是 _src/main.rs_
2. 声明模块
   在 crate 根文件中，可以声明一个模块，例如 `mod garden;`。
   编译器会在以下位置寻找模块代码：
   - 内联定义：直接用大括号 `{}` 包含模块内容
   - 外部文件：_src/garden.rs_ 或 _src/garden/mod.rs_
3. 声明子模块
   在非根文件中，也可以定义子模块，例如在 _src/garden.rs_ 中声明 `mod vegetables;`。
   编译器会在父模块对应的目录中寻找子模块代码：
   - 内联定义：在 `mod vegetables` 后面加大括号 `{}`
   - 外部文件：_src/garden/vegetables.rs_ 或 _src/garden/vegetables/mod.rs_
4. 模块中的代码路径
   模块成为 crate 的一部分后，你可以在允许的范围内通过完整路径访问模块的内容，比如：
   `crate::garden::vegetables::Asparagus`
5. 私有和公用
   模块里的代码默认对父模块私有。
   要让模块本身公用，用 `pub mod`。
   要让模块内部的成员公用，在声明前加 `pub`。

这里我们创建一个名为 `backyard` 的二进制 crate 来说明这些规则。
该 crate 的路径同样命名为 `backyard`，该路径包含了这些文件和目录：

```
backyard
├── Cargo.lock
├── Cargo.toml
└── src
    ├── garden
    │   └── vegetables.rs
    ├── garden.rs
    └── main.rs
```

> _Cargo.toml_：描述包的信息和依赖。
> _src/main.rs_：二进制 crate 的根文件（crate root）。
> _src/garden.rs_：父模块 `garden`。
> _src/garden/vegetables.rs_：`garden` 模块下的子模块 `vegetables`。

_main.rs_ 中包含：

```rust
use crate::garden::vegetables::Asparagus;

pub mod garden;

fn main() {
    let plant = Asparagus {};
    println!("I'm growing {plant:?}!");
}
```

_src/garden/vegetables.rs_ 包含：

```rust
#[derive(Debug)]
pub struct Asparagus {}
```

`pub mod garden;`
声明了一个名为 `garden` 的模块，模块内容在 _src/garden.rs_ 文件里。
`pub` 表示模块对外可用。

`use crate::garden::vegetables::Asparagus;`
这是一个快捷方式，把 `crate::garden::vegetables::Asparagus` 引入作用域，这样在 `main` 函数里就可以直接写 `Asparagus` 而不必写完整路径。

`let plant = Asparagus {};`
创建了一个 `Asparagus` 实例，类型定义在 _src/garden/vegetables.rs_ 里。

`println!("I'm growing {plant:?}!");`
打印出 `plant` 的信息，需要 `Asparagus` 类型实现了 Debug trait（用 `#[derive(Debug)]` 标注）。

**模块**可以帮助我们把一个 crate 中的相关代码组织在一起，让代码更易读、更易复用。
默认情况下，模块里的代码是私有的，外部无法直接使用。
但也可以把模块或者模块里的某些项标记为 `pub`，让外部代码可以访问和使用它们。

举个例子，我们可以创建一个提供餐厅功能的**库 crate**。
在这个例子里，我们先只定义函数的签名，不写具体实现，这样可以专注于代码结构而不是具体逻辑。

在餐厅里，有**前台（front of house）**和**后台（back of house）**两个区域。
前台负责接待顾客、安排座位、点单和收银、制作饮品等；后台则负责厨房的烹饪、洗碗和管理工作。

为了模拟这种组织方式，我们可以把 crate 的功能放到嵌套模块里。比如执行 `cargo new restaurant --lib` 创建一个名为 `restaurant` 的库，在 _src/lib.rs_ 中：

```rust
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}

        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }
}
```

我们用 `mod` 关键字来定义模块，后面跟上模块名（比如本例中的 `front_of_house`），模块的内容用大括号 `{}` 包起来。
在模块内部，我们还可以定义其他子模块，比如例子里的 `hosting` 和 `serving` 模块。
模块里还可以放：

- 结构体、
- 枚举、
- 常量、
- trait，
- 或者像上例中的函数。

模块的作用是把相关的定义组织到一起，让程序员能清楚地看到它们之间的关系。
这样，当其他人阅读代码时，就能根据模块快速找到需要的定义，而不必浏览所有内容。
如果要给程序添加新功能，也很容易判断代码应该放在哪里，从而保持代码结构的清晰和有序。

前面提到的 _src/main.rs_ 和 _src/lib.rs_ 被称为 **crate 根**。
之所以叫它们根，是因为这两个文件构成了 crate 的顶层模块，也就是**模块树（module tree）的根节点**。

```
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```

这个模块树展示了模块之间的嵌套关系。
例如，`hosting` 被包含在 `front_of_house` 内，所以它是 `front_of_house` 的子模块，而 `front_of_house` 则是它的父模块。
同时，模块也可以互为**兄弟模块（siblings）**，像 `hosting` 和 `serving` 都定义在同一个 `front_of_house` 中。
整个模块树的顶端隐式地位于名为 crate 的根模块下。

你可以把模块树想象成电脑上的文件系统目录树，这是一个很贴切的比喻。
就像目录用来组织文件一样，模块用来组织代码。
而要使用模块，就像访问文件一样，需要一种方式来“找到”它们。
