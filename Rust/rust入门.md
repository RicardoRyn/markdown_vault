# 安装
rust是一个静态编译语言，python是一个动态解释型语言。

cargo：包管理器。
rustup：工具链管理器。
rustc：编译器。
rust-analyzer、clippy：代码检查。
rustfmt：代码格式化。

更新rust：

```bash
rustup update
```

检查安装：

```bash
rustc --version
```

本地文档，可离线阅读：

```bash
rustup doc
```

新建项目库：

```bash
cargo new hello_cargo
```

`Cargo.toml`文件：

```toml
[package]  # section的标题，表明下面语句用来配置一个包
name = "hello_cargo"  # 项目名称
version = "0.1.0"  # 项目版本
edition = "2024"  # rust的版本

[dependencies]
```

> 对于已有的rust项目：
> `cargo init`  # 会自动创建 Cargo.toml等文件。

项目根目录下构建项目：

```bash
cargo build  # 在 target/debug 下生成可执行文件
```

也可以构建并直接运行项目：

```bash
cargo run  # 大多数人都会直接cargo run
```

检查代码确保其可以编译，但是不编译（省去了编译可执行文件步骤，快很多）：

```bash
cargo check
```

> 定期执行`cargo check`，确保代码可编译，养成好习惯。

最终编译release版本：

```bash
# 优点，程序运行更快
# 缺点，编译时间更长
cargo build --release  # 在 target/release 下生成可执行文件
```

> `cargo build` 适用于开发阶段频繁编译。
> 
> `cargo build --release` 适用于为用户构建最终程序。

# 常见概念

## 变量和可变性

### 变量

变量是不可变的 immutable, 
当变量不可变时，一旦值被绑定一个名称上，你就不能改变这个值。

使用 `mut` 可以声明一个可变变量。

```rust
let x = 5
let mut x = 5
```

### 常量

不允许对 **常量** 使用 `mut`。常量不光默认不可变，它总是不可变。并且 必须 注明值的类型。

常量可以在任何作用域中声明，包括全局作用域。

常量只能被设为**常量表达式**，而不能是那些必须在运行时才能计算出的值。编译器在编译时能处理一部分有限的运算，因此我们可以用更直观、易读的方式来写常量的定义，而不用直接把它写成一个像 10,800 这样的具体数字。

```rust
const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 *3
```

> Rust 对常量的命名约定是在单词之间使用全大写加下划线。

### 遮蔽

可以定义一个与**之前变量**同名的**新变量**。
Rustacean 们称之为第一个变量被第二个 **遮蔽（Shadowing）** 了。

> 当使用**可变变量**时，后续修改变量的时候可以没有`let`关键字。
> 但是如果是**遮蔽**旧变量，则必须使用`let`关键字。
> 
> **可变变量**与**遮蔽**的另一个区别是，当再次使用 let 时，实际上创建了一个新变量，我们可以改变值的类型，并且复用这个名字。

## 数据类型

在 Rust 中，每一个值都有一个特定 数据类型（data type），这告诉 Rust 它被指定为何种数据，以便明确数据处理方式。

 静态类型（statically typed）语言在编译时就必须知道所有变量的类型。

### 标量类型

**标量（scalar）**类型代表一个单独的值:
1. 整型
2. 浮点型
3. 布尔类型
4. 字符类型

#### 整型

默认为`i32`。

| 长度      | 有符号   | 无符号   |
| ------- | ----- | ----- |
| 8-bit   | i8    | u8    |
| 16-bit  | i16   | u16   |
| 32-bit  | i32   | u32   |
| 64-bit  | i64   | u64   |
| 128-bit | i128  | u128  |
| 架构相关    | isize | usize |

> `isize` 和 `usize` 类型依赖运行程序的计算机架构：64 位架构上它们是 64 位的，32 位架构上它们是 32 位的。

#### 浮点型

只有`f32`**单精度浮点**和`f64`**双精度浮点**，默认为`u64`。
所有的浮点型都是有符号的。

#### 布尔类型

rust中是`true`，python中是`True`。

```rust
fn main() {
    let t = true;

    let f: bool = false; // with explicit type annotation
}
```

#### 字符串类型

rust中单引号和双引号的含义不同：
1. `let c = 'z';` 的类型是 `char`（单个字符，4字节）。
2. `let c = "zz";` 的类型是 `&str`（字符串切片，指向一段内存里的字节数组）。

```rust
fn main() {
    let x = 'z';
    let y: char = 'ℤ'; // with explicit type annotation
    let z: &str = "ℤℤ"; // with explicit type annotation
    let heart_eyed_cat = '😻';
}
```

### 复合类型

将多个值组合成一个类型。Rust 有两个原生的复合类型：
1. 元组（tuple）
2. 数组（array）

#### 元组

元组**长度固定**。元素类型**可以不同**。

```rust
fn main() {
    let tup = (500, 6.4, 1);
}
```

元组的**打印**：

```rust
fn main() {
    let tup = (500, 6.4, 1);
    // println!("{tup}"); // 直接打印会报错 println!("{:?}", tup)
	
    println!("{tup:?}");
    println!("{tup:#?}"); // 打印地更好看
	
    println!("{:?}", tup);
    println!("{:#?}", tup); // 打印地更好看
}
```

元组的**解构**：

```rust
fn main() {
    let tup = (500, 6.4, 1);
	let (x, y, z) = tup;
	println!("{x} {y} {z}");
}
```

元组的**类型标注**：

```rust
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

元组的**索引**：

```rust
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);
	
    let five_hundred = x.0;
    let six_point_four = x.1;
    let one = x.2;
	
	println!("{} {} {}", five_hundred, six_point_four, one);
}
```

> 不带任何值的元组有个特殊的名称，叫做 **单元（unit） 元组**。
> 这种值以及对应的类型都写作 `()`，表示空值或空的返回类型。
> 如果表达式不返回任何其他值，则会隐式返回单元值。

#### 数组

Rust 中的数组长度也是**固定的**。

数组中的每个元素的类型**必须相同**。

> `vector` 类型是标准库提供的一个 允许 增长和缩小长度的类似数组的集合类型。
> 
> 当不确定是应该使用数组还是 `vector` 的时候，那么很可能应该使用 `vector`。

**特殊数组**：

```rust
let a = [3; 5];
println!("{a:?}"); // [3, 3, 3, 3, 3]
```

数组的**打印**：

```rust
let arr = [1, 2, 3, 4, 5];
// println!("{arr}"); // 直接打印会报错 println!("{:?}", arr)

println!("{arr:?}");
println!("{arr:#?}"); // 打印地更好看

println!("{:?}", arr);
println!("{:#?}", arr); // 打印地更好看
```

数组的**解构**：

```rust
let arr = [1, 2, 3];
let [x, y, z] = arr;
println!("{x} {y} {z}");
```

数组的**类型标注**：
```rust
let a: [i32; 5] = [1, 2, 3, 4, 5];
let monthes: [&str; 12] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
```

数组的**访问**（不同与元组的索引。类似与python的索引）：

```rust
fn main() {
    let x = [1, 2, 3, 4];
	
    let a = x[0];
    let b = x[1];
    let c = x[2];
    let d = x[3];
    println!("{a} {b} {c} {d}");

}
```

## 函数

```rust
fn main() {
    println!("Hello, world!");
    annother_function();
}

fn annother_function() {
    println!("Annother function.");
}
```

> 源码中 `another_function` 定义在 `main` 函数 之后；也可以定义在之前。
> Rust 不关心函数定义所在的位置，只要函数被调用时出现在调用之处可见的作用域内就行。

### 参数

**参数**（parameters）的函数，参数是特殊变量，是函数签名的一部分：
1. 形参：函数拥有参数，parameters。
2. 实参：为这些参数提供具体的值，arguments。

> 日常交流中，人们倾向于不区分使用 parameter 和 argument 来表示函数定义中的变量或调用函数时传入的具体值。

在函数签名中，***必须*** 声明每个参数的类型。

```rust
fn main() {
    println!("Hello, world!");

    print_labeled_measurement(5, 'h');
}

fn print_labeled_measurement(value: i32, unit_label: char) {
    println!("The measurement is: {value} {unit_label}");
}
```

### 语句和表达式

- **语句**（Statements）是执行一些操作但不返回值的指令。
- **表达式**（Expressions）计算并产生一个值。

```rust
fn main() {
    let y = 6; // 这是一个语句
	let x = (let y = 6); // 报错，因为`let y = 6`是一个语句，不会返回值
	
}
```

***表达式的结尾没有分号。
如果在表达式的结尾加上分号，它就变成了语句，而语句不会返回值。***

```rust
fn main() {
    let y = {
        let x = 3;
        x + 1 // 表达式的结尾没有分号
    }; // 外层的`let y = {};`是一个语句，结尾需要分号

    println!("The value of y is: {y}");
}
```

> `{...}`被称为一个**代码块**。代码块的值是其最后一个表达式的值

### 具有返回值的函数

rust 中不需要对返回值命名，但 ***必须*** 要在箭头（`->`）后声明它的类型。

```rust
fn five() -> i32 {
    5 // 表达式的结尾没有分号
}

fn main() {
    let x = five();

    println!("The value of x is: {x}");
}
```

```rust
fn main() {
    let x = plus_one(5);

    println!("The value of x is: {x}");
}

fn plus_one(x: i32) -> i32 {
    x + 1
}
```

> 如果`x + 1`改成`x + 1;` 则变成一个语句，语句不会返回值，默认是`单位元组 ()`，所以会报`mismatched types`的错误。

## 控制流

### if 表达式

`if` 是**表达式**，不是语句

```rust
fn main() {
    let number = 3;

    if number < 5 {
        println!("condition was true");
    } else {
        println!("condition was false");
    }
}
```

> `if` 表达式中与条件关联的代码块有时被叫做“arms”。

和python不同，代码中的条件 ***必须是 bool 值*** 。
如果条件不是 bool 值，会报错。

```rust
// error[E0308]: mismatched types
fn main() {
    let number = 3;

    if number {
        println!("number is three");
    }
}
```

```rust
fn main() {
    let number = 3;

    if number != 0 {
        println!("number was something other than zero");
    }
}
```

`else if` 的默认逻辑也 ***和python不一样***：

```rust
fn main() {
    let number = 6;

    if number % 4 == 0 {
        println!("number is divisible by 4");
    } else if number % 3 == 0 {
        println!("number is divisible by 3"); // 会打印
    } else if number % 2 == 0 {
        println!("number is divisible by 2"); // 不会打印出来
    } else {
        println!("number is not divisible by 4, 3, or 2");
    }
}
```

> ***Rust 只会执行第一个条件为 true 的代码块***。
> 一旦它找到一个以后，都不会检查剩下的条件了。

使用过多的 else if 表达式会使代码显得杂乱无章，所以如果有多于一个 else if 表达式，最好重构代码。
后面会介绍一个强大的 Rust 分支结构（branching construct），叫做 `match`。

因为 `if` 是一个**表达式**，我们可以在 `let` **语句**的右侧使用它：

```rust
fn main() {
    let condition = true;
    let number = if condition {5} else {6};

    println!("The value of number is: {number}")
}
```

> 在这种情况下，`if` 的每个分支的可能的返回值都 ***必须是相同类型***

```rust
// error[E0308]: `if` and `else` have incompatible types
fn main() {
    let condition = true;
    let number = if condition { 5 } else { "six" };

    println!("The value of number is: {number}")
}
```

### 循环

Rust 为此提供了多种 **循环**（_loops_）：
1. `loop`
2. `while` 
3. `for`

#### 使用loop循环执行代码

```rust
// 以下代码会无限循环，需要<C-c>手动终止
fn main() {
    loop {
        println!("again!");
    }
}
```

#### 从循环返回值

`loop` 的一个用例是**重试可能会失败的操作**，比如：
检查线程是否完成了任务。

然而我们可能会需要将操作的结果传递给其它的代码。
可以在用于停止循环的 `break` 表达式后添加返回值：

```rust
fn main() {
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    }; // 这里是`let`语句，而不是`loop`表达式，所以要加分号

    println!("The result is: {result}");
}
```

如果存在嵌套循环，`break` 和 `continue` 应用于此时**最内层的循环**。

可以在一个循环上指定一个 **循环标签**（loop label），然后与 `break` 或 `continue` 一起使用，用于执行对应标记的循环：

```rust
fn main() {
    let mut count = 0;
    'counting_up: loop { // 给当前循环指定标签
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

#### while循环

同样和python不同，`while` 后的条件 ***必须是 bool 值*** ，否则会报错。

```
fn main() {
    let mut number = 3;

    while number != 0 {
        println!("{number}!");

        number -= 1;
    }

    println!("LIFTOFF!!!");
}
```

#### 使用for遍历集合

用`while`写，坏😠：

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];
    let mut index = 0;

    while index < 5 {
        println!("the value is: {}", a[index]); // 不能写进大括号里

        index += 1;
    }
}
```

用`for`写，好😊：

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];

    for element in a {
        println!("the value is: {element}");
    }
}
```

`for` 循环的安全性和简洁性使得它成为 Rust 中使用最多的循环结构。

```rust
fn main() {
    for number in 1..6 {
        println!("{number}!");
    }
    println!("上山打老虎！");

    for number in (1..4).rev() {
        println!("{number}!");
    }
    println!("LIFTOFF!!!");
}
```