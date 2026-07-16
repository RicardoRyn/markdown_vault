# 包、Crates 与模块

## 包和crate

**包**：包含 `Cargo.toml`，可以包含多个 `crate`（**一个库 + 多个二进制**），但通常只有一个库`crate`。
**crate**：代码的编译单元（一个`.rs`文件或由`mod`组织的多个文件，最终生成一个`.rlib`或可执行文件）。

crate分为：

- **库 crate**：不包含`main`函数，用于提供功能给其他crate使用。编译后生成`.rlib`或动态库，不能直接运行。
- **二进制 crate**：包含`main`函数，编译后生成可执行文件，可以直接运行。

```bash
cargo new <包名 >--lib # 创建一个库crate
```

## 定义模块来控制作用域与私有性

Rust 模块只能包含项（items），例如：

- `enum`
- `fn`
- `const`
- `static`
- `trait`
- `impl`
- `mod` 等。

`let` 语句属于**表达式/语句**，只能出现在函数体或其他代码块中。

1. 在不使用`pub mod`的情况下，父级模块**可以访问**子级模块的所有公开项。而子模块可以访问父模块的任何私有项。
2. 在不使用`pub mod`的情况下，祖父模块**不可访问**孙子模块的公开项。且孙子模块无法访问祖父模块的公开项。
3. 在自己的层级`.rs`文件中写`mod`，永远声明的是子模块，所以兄弟模块想要相互调用，就必须去父级`.rs`文件中将兄弟模块声明为`pub mod`。
4. 顶层`main.rs/lib.rs`不可能有兄弟模块。

> 子能看到父，因为子需要上下文；父不能看到子，因为需要隐藏细节实现。

rust中只有**模块树**的概念，没有crate树的概念。
crate之间的依赖写在`Cargo.toml`中。
时刻提醒自己，你在说的是**模块**之间的导入，还是**crate**之间的依赖。

## 引用模块树中项的路径

```rust
mod mod1 {
    pub fn function_mod1() {
        println!("Mod1 function called");
    }
    pub mod mod2 {
        pub mod mod3 {
            pub fn function_mod3() {
                use super::super::function_mod1;
                function_mod1();
            }
        }
    }
}

fn main() {
    mod1::mod2::mod3::function_mod3();
    mod1::function_mod1();
}
```

Rust 中一种常见的项目组织模式：一个包同时包含一个二进制 crate（可执行程序）和一个库 crate（供他人使用的 API）

职责分离

- **二进制crate**：只包含足以生成可执行文件的代码，通常是`main`函数和一些简单的命令行参数解析，然后调用库`crate`中的功能。它是薄薄的一层胶水代码。
- **库crate**：包含真正的业务逻辑、模块树、数据结构、算法等。这部分可以被其他项目重用。

> 所有核心功能（模块、结构体、函数、trait 等）都放在库 crate 中，其模块树的根是 lib.rs。
> 二进制 crate 中不定义复杂的模块树，只负责调用。

你不仅仅是作者，也是用户。
当你编写二进制 crate 代码时，你站在“使用者”的角度来调用库 crate 的 API。
这会促使你设计出更干净、稳定的 API，因为你亲自体验了使用过程。

| 位置      | 想导入的模块所在          | 导入语法                    |
| --------- | ------------------------- | --------------------------- |
| `main.rs` | 本 crate（`main.rs`）     | `crate::my_mod` 或 `my_mod` |
| `main.rs` | 库 crate（`lib.rs`）      | `<包名>::my_mod`            |
| `lib.rs`  | 本 crate（`lib.rs`）      | `crate::my_mod` 或 `my_mod` |
| `lib.rs`  | 二进制 crate（`main.rs`） | **不支持**                  |

> 在 lib.rs 中无法导入二进制 crate（main.rs）中的任何模块。

当结构体有私有字段时，**必须**提供至少一个**公共的构造器**，否则该结构体在模块外部无法实例化。
这是 Rust 封装性的一种体现——强制通过公开的 API 来创建对象，从而控制对象的不变量。

**枚举和结构体相反**，要么整体公开，要么整体私有，没有某个变体公开，某个变体私有这一说。

## 使用use关键字将路径引入作用域

不允许`use`导入的名称与当前模块中已有的名称（如通过`mod`定义的模块、函数、常量、其他`use`等）发生冲突。

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {
            println!("11111111111111111111111111");
        }
    }
}

mod hosting {
    pub fn add_to_waitlist() {
        println!("22222222222222222222222222");
    }
}

use crate::front_of_house::hosting; // 错误！需要用`as <alias>`

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_1() {
        eat_at_restaurant();
    }
}
```

用`use`:

- 引入**函数**时只引入其父模块，调用时通过父模块访问。
- 引入**结构体、枚举等类型**时则直接引入完整路径。

```rust
// 例子1
use std::cmp::Ordering;
use std::io;
// 等价于
use std::{cmp::Ordering, io};

// 例子2
use std::io;
use std::io::Write;
// 等价于
use std::io::{self, Write};
```
