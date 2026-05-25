## 1. 入门指南

`rustc`是rust的编译器，可以直接运行某个rust脚本，例如：

```bash
rustc main.rs
```

`cargo`是rust的*构建工具*以及*包管理工具*。

```bash
cargo init hello_cargo
```

初始化的`Cargo.toml`文件内容：

```toml
[package]
name = "hello_cargo"
version = "0.1.0"
edition = "2024"

[dependencies]
```

`cargo check`检查程序确保可以编译。
`cargo build`编译程序，但不运行。
`cargo run`编译且运行。

`cargo test`：

1. 捕获（capture）测试过程中打印到控制台的所有输出（例如 println!、eprintln! 等）。
2. 不显示任何输出（只显示 ok）。
3. 测试失败时，会显示该测试产生的输出，以帮助调试。

`cargo test -- --nocapture`：

1. `--nocapture`指示测试运行器不要捕获输出。
2. 所有`println!`等输出会直接打印到终端，即使测试通过也会显示。

## 2. 编写一个猜数字游戏

`cargo update <crate>`更新指定的crate。

## 3. 常见编程概念

```rust
fn main() {
    let x = 3; //不可变变量。
    let mut x = 3; //可变变量。
    const PI: f64 = 3.1415926; // 常量必须显式标注类型
}
```

*遮蔽*可以修改变量的类型，而普通定义一个可变变量再修改其值时，则不能修改其类型。

### 数据类型

整型默认是`i32`，浮点型默认是`f64`。

字符类型`char`大小为4个字节，一个汉字为6个字节。

`let a = [5; 3];`与`let a = [5, 5, 5];`一致。

### 函数

*语句（Statements）*是执行一些操作但不返回值的指令。
*表达式（Expressions）*计算并产生一个值。

### 控制流

与python不一样，rust中`if`后面**只能**跟`bool`值。

```rust
// 错误！
fn main() {
    let number = 3;

    if number {
        println!("number was three");
    }
}

// 正确
fn main() {
    let number = 3;

    if number < 5 {
        println!("condition was true");
    } else {
        println!("condition was false");
    }
}
```

循环标签，通过单引号`'`来打一个标签：

```rust
fn main() {
    let mut count = 0;
    'counting_up: loop {
        println!("count = {count}");
        let mut remaining = 10;

        loop {
            println!("remaining = {remaining}");
            if remaining == 9 {
                break;
            }
            if count == 2 {
                break 'counting_up;
            }
            remaining -= 1;
        }

        count += 1;
    }
    println!("End count = {count}");
}
```

## 4. 认识所有权

### 什么是所有权

所有权规则：

1. Rust 中的每一个值都有一个 所有者（owner）。
2. 值在任一时刻有且只有一个所有者。
3. 当所有者离开作用域，这个值将被丢弃。

```rust
fn main() {
    let s1 = gives_ownership(); // gives_ownership 将它的返回值传递给 s1

    let s2 = String::from("hello"); // s2 进入作用域

    let s3 = takes_and_gives_back(s2); // s2 被传入 takes_and_gives_back,
                                       // 它的返回值又传递给 s3
} // 此处，s3 移出作用域并被丢弃。s2 被 move，所以无事发生
  // s1 移出作用域并被丢弃

fn gives_ownership() -> String {
    // gives_ownership 将会把返回值传入
    // 调用它的函数

    let some_string = String::from("yours"); // some_string 进入作用域

    some_string // 返回 some_string 并将其移至调用函数
}

// 该函数将传入字符串并返回该值
fn takes_and_gives_back(a_string: String) -> String {
    // a_string 进入作用域

    a_string // 返回 a_string 并移出给调用的函数
}
```

如果**元组/数组**中的每个元素都实现了`Copy`，那么这个数组本身也实现了`Copy`。

在 Rust 中，一个类型不能同时实现`Copy`和`Drop`：

- `Drop`的语义是“离开作用域时执行自定义清理”，这要求每个值只能被析构一次。如果类型实现了`Drop`（即拥有自定义析构逻辑），则无法实现`Copy`。
- `Copy`的语义是“隐式、简单的位复制”，复制的源和目标都是独立有效的，不需要任何清理。如果类型实现了`Copy`（即按位复制语义），则无法实现`Drop`。

### 引用与借用

引用符号为`&`，解引用符号为`*`。

```rust
// s1是栈上的结构（指针，长度，容量），其中指针执行堆上的数据
// s2是栈上的结构，其中指针指向栈上的s1的指针
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);

    println!("The length of '{s1}' is {len}.");
}

fn calculate_length(s2: &String) -> usize {
    s2.len()
}
```

- 多个不可变引用可以同时存在，正确！
- 多个可变引用可以同时存在，错误！
- 同时存在可变引用和不可变引用，错误！

```rust
// 错误！悬垂引用

fn main() {
    let reference_to_nothing = dangle();
}

fn dangle() -> &String {
    // dangle 返回一个字符串的引用

    let s = String::from("hello"); // s 是一个新字符串

    &s // 返回字符串 s 的引用
} // 这里 s 离开作用域并被丢弃。其内存被释放。
  // 危险！
```

一个不可变的数据，通常不会有可变引用，但通过*内部可变性*（`RefCell<T>`、`Mutex<T>` 等）可以间接实现。
这么设计的目的是，让一个数据在逻辑上对外表现为只读（只有不可变引用可用），
但实际上内部可以安全地修改，从而满足共享可变性、惰性初始化、并发控制等编程需求，且依然保证内存安全（通过运行时检查）。

Rust在调用方法时，会按照以下顺序**自动插入**引用/解引用：

1. 如果接收者类型与`self`类型完全匹配，直接调用。
2. 如果不匹配，自动对接收者添加`&`、`&mut`或`*`（解引用），直到满足方法签名。

## 5. 使用结构体组织相关联的数据

### 结构体的定义与实例化

**可变性**和**可见性**正交。

对于可变性：

1. 一个结构体，要么整体可变，要么整体不可变。
2. 没有整个结构体可变，但是某些字段不可变一说。
3. 也没有整个结构体不可变，而某些字段可变这一说。

对于可见性：

1. 结构体的每个字段可以独立指定为公有（`pub`）或私有（默认）。
2. 公有字段：外部模块可以直接访问（读/写，但写权限仍然受限于变量自身的可变性）。
3. 私有字段：外部模块不能直接访问，只能通过结构体提供的公有方法访问。

一个整体是私有的，但是部分字段是公开的结构体没有意义：

```rust
mod outer {
    pub struct PublicStruct {
        pub public_field: i32, // 外部可见
        private_field: i32,    // 外部不可见
    }

    struct PrivateStruct {
        pub field: i32, // 但结构体本身私有，内部该访问还能访问，外部该访问不到还是访问不到，无意义
    }

    pub fn test() {
        let ps = PrivateStruct { field: 10 };
        println!("{}", ps.field); // ✅ 模块内部访问，没问题
    }
}

fn main() {
    let pub_s = outer::PublicStruct {
        public_field: 5,
        private_field: 0,
    };
    // 错误：private_field 是私有的

    // let priv_s = outer::PrivateStruct { field: 10 };
    // 错误：PrivateStruct 是私有的，外部无法使用
}
```

### 方法语法

通过派生 trait 增加功能：

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {rect1:#?}");
}
```

`dbg!()`会接收一个表达式的*所有权*，会将其消耗（与`println!`宏相反，后者接收的是引用）。

`&self`是`self: &Self`的语法糖（注意大小写）

## 6. 枚举与模式匹配

### 枚举的定义

1. 枚举值只可能是枚举其中一个变体，不能是多个。
2. 当创建一个枚举变量时，必须提供具体的变体（以及该变体所需的数据），除非先定义，后赋值。
3. 每个变体可以处理不同类型和数量的数据。

枚举本身是一种数据类型。
枚举中的变体如果包含一个结构体（作为其字段），那么这个变体的值的类型仍然是枚举类型，而不是独立的结构体类型。

```rust
struct Point {
    x: i32,
    y: i32,
}

enum Shape {
    Circle(f64),                  // 元组变体
    Rectangle { w: i32, h: i32 }, // 结构体变体（匿名结构体）
    Polygon(Point),               // 包含一个 Point 结构体
}

fn main() {
    let s = Shape::Polygon(Point { x: 0, y: 0 });
    // s 的类型是 Shape，不是 Point
}
```

结构体也是一种类型。
当结构体的某个字段被定义为枚举类型时，该字段的类型就是那个枚举类型，但整个结构体变量的类型仍然是结构体类型，而不是枚举类型。

```rust
enum Color {
    Red,
    Green,
    Blue,
}

struct ColoredPoint {
    x: i32,
    y: i32,
    color: Color, // 字段类型是枚举 Color
}

fn main() {
    let cp = ColoredPoint {
        x: 0,
        y: 0,
        color: Color::Red,
    };
    // cp 的类型是 ColoredPoint（结构体类型）
    // cp.color 的类型是 Color（枚举类型）
}
```

枚举**不是**多个结构体的语法糖，而是一种类型论中不可或缺的构造（sum type），结构体是 product type，两者互补。
没有枚举，许多模式（如 Option、Result、状态机）将难以安全表达。
因此，不能说“绝大部分情况可用结构体替代”，而是根据需求选择：需要“并且”用结构体，需要“或者”用枚举。
尽管它们有时候很相似：

```rust
fn main() {
    // 需要定义4个结构体
    // 也就是4个类型
    struct QuitMessage; // 类单元结构体
    struct MoveMessage {
        x: i32,
        y: i32,
    };
    struct WriteMessage(String); // 元组结构体
    struct ChangeColorMessage(i32, i32, i32); // 元组结构体

    // 1个枚举就搞定
    // 只有1个类型
    enum Message {
        Quit,
        Move { x: i32, y: i32 }, // 结构体变体
        Write(String),
        ChangeColor(i32, i32, i32), // 元组变体
    }
}
```

构造函数写法不同。

```rust
enum Message1 {
    Quit,
    Move { x: i32, y: i32 }, // 结构体变体（匿名结构体）
    Write(String),
    ChangeColor(i32, i32, i32),
}

enum Message2 {
    Quit,
    Move(i32, i32), // 元组变体
    Write(String),
    ChangeColor(i32, i32, i32),
}

fn main() {
    // 构造函数写法不同
    let a = Message1::Move { x: 10, y: 20 };
    let b = Message2::Move(10, 20);
}
```

枚举的所有变体共享同一个`impl`块中的方法。
如果希望枚举的前2个变体该有某方法，而后2个变体不该有该方法。
最合理的做法是，继续拆分该枚举，组织成2个新的枚举。

`Option<T>`是一个**泛型**，泛型参数会生成不同的类型。
也就是说，如果我们自己定义一个枚举，变量1是这个枚举的变体1，变量2是这个枚举的变体2，这2个变量仍是同一个类型。
我们自己定义的非泛型枚举，所有变体都属于同一个固定类型。

### match控制流与结构

在遇到**第一个**符合的模式时，值会进入相关联的代码块并在执行中被使用。

`if`表达式必须返回一个布尔值，而`match`后面可以是任何类型的。

```rust
// match 表达式 {
//     模式1 => 表达式1,
//     模式2 => 表达式2,
//     模式3 => 表达式3,
// }
```

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}

fn main() {
    let coin = Coin::Dime;
    let value = value_in_cents(coin);
    println!("The value of the coin is {} cents.", value);
}
```

### if let和let else简洁控制流

所有**只有两个分支**的`match`都可以改写成`if let ... else`形式。

```rust
fn main() {
    let maybe_value = Some(3u8);
    match maybe_value {
        Some(a) => println!("The maximum is configured to be {a}"),
        _ => (),
    }

    // if let 模式1(变量) = 表达式 {
    //     表达式1
    // }

    // if let
    if let Some(a) = maybe_value {
        println!("The maximum is configured to be {a}");
    }

    // let ... if let ... esle
    let a = if let Some(_) = maybe_value {
        true
    } else {
        false
    };

    println!("{a}");
}
```

`let else`的`else`分支必须**发散**（即不返回到该分支之后的代码）， 也就是解构写法：

```rust
fn myfunction() -> i32 {
    let maybe_value = Some(42);

    let Some(a) = maybe_value else { return 0 };

    a
}

fn main() {
    let b = myfunction();
    println!("b: {b}");
}
```

## 7. 包、Crates 与模块

### 包和crate

**包**：包含 `Cargo.toml`，可以包含多个 `crate`（**一个库 + 多个二进制**），但通常只有一个库`crate`。
**crate**：代码的编译单元（一个`.rs`文件或由`mod`组织的多个文件，最终生成一个`.rlib`或可执行文件）。

crate分为：

- **库 crate**：不包含`main`函数，用于提供功能给其他crate使用。编译后生成`.rlib`或动态库，不能直接运行。
- **二进制 crate**：包含`main`函数，编译后生成可执行文件，可以直接运行。

```bash
cargo new <包名 >--lib # 创建一个库crate
```

### 定义模块来控制作用域与私有性

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

### 引用模块树中项的路径

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

### 使用use关键字将路径引入作用域

不允许`use`导入的名称与当前模块中已有的名称（如通过`mod`定义的模块、函数、常量、其他`use`等）发生冲突。

```rust
// 错误！
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

use crate::front_of_house::hosting as rjx; // 错误！

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

## 8. 常见集合

在 Rust 中，变量拥有整个复合类型（如元组、数组、结构体）的所有权。
但通过模式匹配或字段访问，可以部分移动出其中某些元素的所有权，这会导致原始变量变得“部分未初始化”，编译器会限制对原始变量的后续使用。

对于**元组**和**结构体**：支持直接部分移动（通过`.`或模式解构）。
移动部分字段后，原变量不能整体使用，但其他未移动的字段仍可用。

```rust
struct MyStruct {
    a: String,
    b: i32,
}

fn main() {
    let s = MyStruct {
        a: String::from("hi"),
        b: 42,
    };
    let x = s.a; // 可以移动 s.a
    println!("{:?}", s); // 错误！s 整体已部分移动
    println!("{}", s.b); // 可以，b 是 Copy 且未被移动
}
```

对于**数组**和**Vec**：不支持部分移动单个元素，只能整体移动数组。除非元素实现`Copy`，但这就不是移动语义，而是复制。

```rust
fn main() {
    let arr = [String::from("a"), String::from("b")];
    let s = arr[0]; // 错误！不能部分移动数组元素

    let v = vec![String::from("Hello"), String::from("World")];
    let a = v[0]; // 错误
}
```

### 使用字符串储存 UTF-8 编码的文本

`push_str`方法采用字符串slice，它并不会获取对象的所有权

```rust
fn main() {
    let mut s1 = String::from("foo");
    let s2 = "bar";
    s1.push_str(s2);
    println!("s2 is {s2}"); // ✅ 可以
}
```

`push_str`：追加一个字符串切片（`&str`）。例如`s.push_str("world");`。
`push`：追加一个字符（`char`）。例如`s.push('!');`。

使用`+`拼接字符串：

```rust
fn main() {
    let s1 = String::from("Hello, ");
    let s2 = String::from("world!");
    let s3 = s1 + &s2; // 注意 s1 被移动了，不能继续使用
}
```

使用`format!`宏来拼接字符串：
`format!("...")`宏 → `String`，它总是返回一个新分配的`String`。

```rust
fn main() {
    let s1 = String::from("tic");
    let s2 = String::from("tac");
    let s3 = String::from("toe");

    let s = format!("{s1}-{s2}-{s3}");

    println!("{s1}");
    println!("{s2}");
    println!("{s3}");
    println!("{s}");
}
```

Rust 的字符串不支持索引。
原理类似**数组**和**Vec**的部分所有权一样。
不支持移动单个元素。

```rust
fn main() {
    let s1 = String::from("hi");
    let h = s1[0]; // ❌ 错误
}
```

Rust 的字符串`str`**不支持**通过索引`s[0]` 直接访问字符。
原因在于字符串是 UTF-8 编码的。

- 索引操作会按字节索引，而一个字符可能占用多个字节，直接按字节索引可能无法得到一个合法的字符（甚至切在字符中间）。
- 而`&s[0..3]`是字节切片（范围语法基于字节位置），它返回一个`&str`。

```rust
fn main() {
    // 索引索的是字节
    let s = "你好"; // 2个字符，6个字节

    let a = &s[0]; // ❌ 错误
    println!("{}", a);

    let b = &s[0..3]; // ✅ 正确
    println!("{}", b); // 你

    // 使用字符
    for c in s.char() {
        println!("{c}"); // 你 好
    }
}
```

小练习：

```rust
fn string_slice(arg: &str) {
    println!("{arg}");
}

fn string(arg: String) {
    println!("{arg}");
}

fn main() {
    // 字符串字面量
    string_slice("blue");

    // 字符串切片操作，因为它们只是原字符串的一部分的引用，不拥有数据。
    string_slice(&String::from("abc")[0..1]);
    string_slice("  hello there ".trim());

    // 这些方法都会在堆上分配新内存并拥有数据。
    string(format!("Interpolation {}", "Station"));
    string(String::from("hi"));
    string("red".to_string());
    string("rust is fun!".to_owned());
    string("nice weather".into());
    string("Happy Monday!".replace("Mon", "Tues"));
    string("mY sHiFt KeY iS sTiCkY".to_lowercase());
}
```

### 使用 Hash Map 储存键值对

哈希map是同质的：所有的键必须是相同类型，值也必须都是相同类型。
遍历哈希 map 会以任意顺序进行。

1. 直接覆盖原始值：

```rust
use std::collections::HashMap;

fn main() {
    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Blue"), 25);

    println!("{scores:?}"); // {"Blue": 25}
}
```

2. 如果没有指定key，才插入值，有则不做任何处理：
   `Entry`上的`or_insert`方法被定义为：
   - 如果对应`Entry`的键已经存在，就返回该值的**可变引用**；
   - 如果不存在，就把参数作为这个键的新值插入，并返回这个新值的**可变引用**。

```rust
use std::collections::HashMap;

fn main() {
    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);

    let blue_value = scores.entry(String::from("Blue")).or_insert(25);
    println!("{blue_value}"); // 10

    let yellow_value = scores.entry(String::from("Yellow")).or_insert(25);
    println!("{yellow_value}"); // 25

    println!("{scores:?}"); // {"Yellow": 25, "Blue": 10}
}
```

> 注意`println!`的位置，因为不能同时存在多个可变引用。

3. 根据新值更新旧值：

```rust
use std::collections::HashMap;

fn main() {
    let text = "hello world wonderful world";

    let mut map = HashMap::new();

    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0);
        *count += 1
    }

    println!("{map:?}"); // {"world": 2, "wonderful": 1, "hello": 1}
}
```

> 为啥这里是`let count`而不是`let mut count`呢？
> 因为修改变量`count`本身（即改变它指向的地址）和通过`count`修改它指向的值是两件不同的事。
>
> 等号右边是`&mut i32`，即可变引用，可变引用允许通过**解引用**来修改其指向的值。
>
> 等号左边是`let count`，即**不可变绑定**，意思是`count`这个变量名不能重新赋值给另一个不同的引用（即不能再写`count = &mut something`）。
> 而`let mut count`是创建一个**可变绑定**， 可以重新赋值`count = &mut other_value`。
>
> 在循环中，我们只是使用`*count += 1`来修改**引用指向的值**，从未尝试让`count`指向别的引用。
> 因此，`count`不需要是可变的绑定。用`let count = ...`完全足够。
>
> ```rust
> fn main() {
>     let mut a = vec![1]; // a必须为一个可变绑定
>     let b = &mut a[0]; // b不需要是可变的绑定
>     *b += 1;
>     println!("{b}"); // 2
>     println!("{a:?}"); // [2]
> }
> ```
>
> 综上所述，`let mut a`，意识就是说这个`a`所表示的，栈上的，指针，是可以被修改的。
> 而`let b`，则说明这个`b`所表示的，栈上的指针，不能被修改。

## 8.5 测试

```rust

// This is a quiz for the following sections:
// - Strings
// - Vecs
// - Move semantics
// - Modules
// - Enums
//
// Let's build a little machine in the form of a function. As input, we're going
// to give a list of strings and commands. These commands determine what action
// is going to be applied to the string. It can either be:
// - Uppercase the string
// - Trim the string
// - Append "bar" to the string a specified amount of times
//
// The exact form of this will be:
// - The input is going to be a Vector of 2-length tuples,
//   the first element is the string, the second one is the command.
// - The output element is going to be a vector of strings.

enum Command {
    Uppercase,
    Trim,
    Append(usize),
}

mod my_module {
    use super::Command;

    // TODO: Complete the function as described above.
    pub fn transformer(input: Vec<(String, Command)>) -> Vec<String> {
        let mut output = Vec::new();

        for (old_string, command) in input.into_iter() {
            let new_string = match command {
                Command::Uppercase => old_string.to_uppercase(),
                Command::Trim => old_string.trim().to_string(),
                Command::Append(count) => format!("{}{}", old_string, "bar".repeat(count)),
            };

            output.push(new_string);
        }

        output
    }
}

fn main() {
    // You can optionally experiment here.
}

#[cfg(test)]
mod tests {
    // TODO: What do we need to import to have `transformer` in scope?
    use super::my_module::transformer;
    use super::Command;

    #[test]
    fn it_works() {
        let input = vec![
            ("hello".to_string(), Command::Uppercase),
            (" all roads lead to rome! ".to_string(), Command::Trim),
            ("foo".to_string(), Command::Append(1)),
            ("bar".to_string(), Command::Append(5)),
        ];
        let output = transformer(input);

        assert_eq!(
            output,
            [
                "HELLO",
                "all roads lead to rome!",
                "foobar",
                "barbarbarbarbarbar",
            ]
        );
    }
}
```

这个测验，第一步就是设计函数签名。根据：

```rust
        let input = vec![
            ("hello".to_string(), Command::Uppercase),
            (" all roads lead to rome! ".to_string(), Command::Trim),
            ("foo".to_string(), Command::Append(1)),
            ("bar".to_string(), Command::Append(5)),
        ];
```

我们能知道函数`transformer`的输入`iuput: Vec<(String, Command)>`

但是根据：

```rust
        assert_eq!(
            output,
            [
                "HELLO",
                "all roads lead to rome!",
                "foobar",
                "barbarbarbarbarbar",
            ]
        );
```

我们**不该简单认为**函数`transformer`的输入就是`output: [&str]`。

因为测试断言中右边是一个数组字面量，动态大小类型不能作为返回值。

可以有函数`fn f() -> [i32; 3] { [1,2,3] }`，但是这种长度固定且已知。
而在本例中，我们的输出是**动态大小类型（DST）**，即函数不知道最终返回的数组中有多少个数据，
即**不能返回未标注长度的切片 [T]**。

`Vec<String>`和`[&str; 4]`之间实现了`PartialEq`。
Rust允许`Vec<String>`与`&[&str]`比较，所以`Vec<String>`才是实际应该返回的类型。

接下来，我们需要遍历输入中的元组，利用`for`循环，我们有两种方式：

1. `for (old_string, command) in input.iter() {}`，借用`input`中的值。
2. `for (old_string, command) in input.into_iter() {}`，消耗`input`，直接获取所有权。

实际这两种方式都可以达到目的，但是由于后续不会再使用`input`，因此我们更推荐第二种，直接获取`input`所有权。

最后，在`match`的三个分支中，我要清楚，我们不能返回一个`&str/&String`，这样会导致悬垂引用。

`old_string.to_uppercase()`和`format!()`都会产生临时的`String`对象。
如果在`match`分支中取得它们的`&str`引用，这个临时值在`match`表达式结束后就被销毁，导致`out`中存储的引用变成悬垂指针。
Rust会阻止这种代码编译。

最后，这里有更加rustacean的写法：

```rust
    pub fn transformer(input: Vec<(String, Command)>) -> Vec<String> {
        input
            .into_iter()
            .map(|(old_string, command)| match command {
                Command::Uppercase => old_string.to_uppercase(),
                Command::Trim => old_string.trim().to_string(),
                Command::Append(count) => format!("{}{}", old_string, "bar".repeat(count)),
            })
            .collect()
    }
```

> 学吧，学无止境，太深了。
> 以后但凡有for循环的东西，我第一个想到的就是链式调用
