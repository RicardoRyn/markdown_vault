# 结构体的定义和实例化

## 结构体

1. 和元组一样，结构体的每一部分**可以是不同类型**。
2. 但不同于元组，结构体**需要命名各部分数据**以便能清楚的表明其值的意义。
3. 由于有了名字：**不需要依赖顺序**来指定或访问实例中的值。

```rust
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}
```

通过为每个字段指定具体值来创建这个结构体的实例：

```rust
fn main() {
    let user1 = User {
        active: true,
        username: String::from("someusername123"),
        email: String::from("someone@example.com"),
        sign_in_count: 1,
    };
}
```

为了从结构体中获取某个特定的值，可以使用点号。
举个例子，想要用户的邮箱地址，可以用 `user1.email`。

如果结构体的实例是可变的，我们可以使用点号并为对应的字段赋值：

```rust
fn main() {
    let mut user1 = User {
        active: true,
        username: String::from("someusername123"),
        email: String::from("someone@example.com"),
        sign_in_count: 1,
    };

    user1.email = String::from("anotheremail@example.com");
}
```

> 注意整个实例必须是可变的；Rust 并不允许只将某个字段标记为可变。

我们可以在函数体的最后一个表达式中构造一个结构体的新实例，来隐式地返回这个实例：

```rust
fn build_user(email: String, username: String) -> User {
    User {
        active: true,
        username,
        email,
        sign_in_count: 1,
    }
}
```

使用**结构体更新语法**从其他实例创建实例:

```rust
// 普通语法
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    let user2 = User {
        active: user1.active,
        username: user1.username,
        email: String::from("another@example.com"),
        sign_in_count: user1.sign_in_count,
    };
}
```

```rust
// 结构体更新语法
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    let user2 = User {
        email: String::from("another@example.com"),
        ..user1
    };

    // println!("{}", user1.username); // 报错
}
```

> **结构更新语法**就像带有 `=` 的赋值，因为它**移动**了数据。
>
> 在这个例子中，我们在创建 `user2` 后就不能再使用 `user1.username` 了。
> 因为 `user1` 的 `username` 字段中的 `String` 被移到 `user2` 中。

如果我们给 `user2` 的 `email` 和 `username` 都赋予新的 `String` 值，那么 `user1` 在创建 `user2` 后仍然有效:

```rust
// 有效
fn main() {
    let user1 = User {
        email: String::from("someone@example.com"),
        username: String::from("someusername123"),
        active: true,
        sign_in_count: 1,
    };

    let user2 = User {
        email: String::from("user2@example.com"),
        username: String::from("user2"),
        ..user1
    };

    println!("{}", user1.email);
    println!("{}", user1.username);
}
```

> `active` 和 `sign_in_count` 的类型是实现 `Copy` trait 的类型。

---

**结构体数据的所有权**

在上面的例子中，我们故意使用了自身拥有所有权的 `String` 类型而不是 `&str` **字符串 slice 类型**。
因为我们想要这个结构体拥有它所有的数据，为此只要整个结构体是有效的话其数据也是有效的。

我们也可使结构体存储**被其他对象拥有的数据的引用**，不过这么做的话需要用上 **生命周期（lifetimes）**。

生命周期确保结构体引用的数据有效性跟结构体本身保持一致。
如果你尝试在结构体中存储一个引用而不指定生命周期将是无效的，比如这样：

```rust
// 以下代码会报错
struct User {
    active: bool,
    username: &str, // 注意这里是 &str 而不是 String
    email: &str,    // 注意这里是 &str 而不是 String
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        active: true,
        username: "someusername123",
        email: "someone@example.com",
        sign_in_count: 1,
    };
}
```

编译器会抱怨它需要生命周期标识符：

```bash
$ cargo run
   Compiling structs v0.1.0 (file:///projects/structs)
error[E0106]: missing lifetime specifier
 --> src/main.rs:3:15
  |
3 |     username: &str,
  |               ^ expected named lifetime parameter
  |
help: consider introducing a named lifetime parameter
  |
1 ~ struct User<'a> {
2 |     active: bool,
3 ~     username: &'a str,
  |

error[E0106]: missing lifetime specifier
 --> src/main.rs:4:12
  |
4 |     email: &str,
  |            ^ expected named lifetime parameter
  |
help: consider introducing a named lifetime parameter
  |
1 ~ struct User<'a> {
2 |     active: bool,
3 |     username: &str,
4 ~     email: &'a str,
  |

For more information about this error, try `rustc --explain E0106`.
error: could not compile `structs` (bin "structs") due to 2 previous errors
```

目前，我们暂时会使用像 `String` 这类拥有所有权的类型来替代 `&str` 这样的引用以修正这个错误。

---

## 元组结构体

**元组结构体**有着结构体名称提供的含义，但**没有具体的字段名，只有字段的类型**。
使用没有命名字段的元组结构体来创建不同的类型:

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

fn main() {
    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
}
```

注意 `black` 和 `origin` 值的类型不同，因为它们是不同的元组结构体的实例。
你定义的每一个结构体有其自己的类型，即使结构体中的字段可能有着相同的类型。

例如，一个获取 Color 类型参数的函数不能接受 Point 作为参数，即便这两个类型都由三个 i32 值组成。

元组结构体实例类似于元组，你可以将它们解构为单独的部分，也可以使用 `.` 后跟索引来访问单独的值。

与元组不同的是，解构元组结构体时必须写明结构体的类型。
例如，我们可以写 `let Point(x, y, z) = origin;`，将 origin 的值解构到名为 x、y 和 z 的变量中。

## 类单元结构体

可以定义一个**没有任何字段**的结构体，它们被称为 **类单元结构体（unit-like structs）**。
因为它们类似于 `()`，即 unit 类型。

类单元结构体常常在你想要在某个类型上实现 trait 但不需要在类型中存储数据的时候发挥作用：

```rust
struct AlwaysEqual;

fn main() {
    let subject = AlwaysEqual;
}
```

## 结构体实例程序（计算长方形面积）

普通代码：

```rust
fn main() {
    let width1 = 30;
    let height1 = 50;

    println!(
        "The area of the rectangle is {} square pixels.",
        area(width1, height1)
    );
}

fn area(width: u32, height: u32) -> u32 {
    width * height
}
```

使用**元组**重构。

上面代码虽然可以运行，但是函数 `area` 本应该计算一个长方形的面积，不过函数却有两个参数。
这两个参数是相关联的，不过程序本身却没有表现出这一点。
将长度和宽度组合在一起将更易懂也更易处理。

```rust
fn main() {
    let rect1 = (30, 50);

    println!(
        "The area of the rectangle is {} square pixels.",
        area(rect1)
    );
}

fn area(dimensions: (u32, u32)) -> u32 {
    dimensions.0 * dimensions.1
}
```

使用**结构体**重构。

我们使用结构体为数据命名来为其赋予意义。
我们可以将我们正在使用的元组转换成一个有整体名称而且每个部分也有对应名字的结构体

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        area(&rect1)
    );
}

fn area(rectangle: &Rectangle) -> u32 {
    rectangle.width * rectangle.height
}
```

> 作为Rustacean，时刻关注所有权。
> 此处希望借用结构体而不是获取它的所有权，这样 `main` 函数就可以保持 `rect1` 的所有权并继续使用它。

在调试程序时打印出 `Rectangle` 实例来查看其所有字段的值非常有用。
但是现有的程序还不行：

```rust
// 以下代码无法编译
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {}", rect1);
}
```

`println!` 宏可以处理多种类型的格式，不过默认的 `{}` 占位符会告诉 `println!` 使用称为 `Display` 的格式：
这种格式主要是为了让终端用户直接查看。

到目前为止，基本类型都默认实现了 `Display`，因为这是向用户展示诸如 `1` 或其他基本值的唯一合理方式。

然而，对于结构体来说，`println!` 所应使用的输出格式并不明确，因为有更多的展示方式可选：

- 是否需要逗号分隔？
- 是否需要大括号？
- 是否应该显示所有字段？

由于这些不确定性，Rust 不会尝试猜测我们的意图，因此结构体默认没有提供 `Display` 实现，也就不能直接用 `{}` 占位符与 `println!` 配合使用。

在 `{}` 中加入 `:?` 指示符可以告诉 `println!` 使用称为 `Debug` 的输出格式。
`Debug` 是一个 trait，它允许我们以对开发者有帮助的方式打印结构体，从而在调试代码时能够查看其值。

```rust
// 以下代码无法编译
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!("rect1 is {:?}", rect1);
}
```

上面的代码依旧无法通过编译。
Rust 确实包含了打印出调试信息的功能，不过我们必须为结构体显式选择这个功能。

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

> 可以使用 `{:#?}` 替换 println! 字符串中的 `{:?}`。
> 打印结果更加易读。

另一种使用 `Debug` 格式打印数值的方法是使用 `dbg!` 宏。
`dbg!` 宏会获取一个表达式的所有权（与 `println!` 宏不同，后者通常接收引用），
打印出调用 `dbg!` 时所在的文件名和行号，以及该表达式的值，并将该值的所有权返回。

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let scale = 2;
    let rect1 = Rectangle {
        width: dbg!(30 * scale),
        height: 50,
    };

    dbg!(&rect1);
}
```

最后输出结果：

```bash
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.61s
     Running `target/debug/rectangles`
[src/main.rs:10:16] 30 * scale = 60
[src/main.rs:14:5] &rect1 = Rectangle {
    width: 60,
    height: 50,
}
```

可以看到，第一条输出来自 _src/main.rs_ 第 10 行，我们正在调试的表达式是 `30 * scale`，其结果值为 60（整数的 `Debug` 格式只打印值本身）。
在 _src/main.rs_ 第 14 行的 `dbg!` 调用输出了 `&rect1` 的值，也就是 `Rectangle` 结构体。
这个输出使用了更易读的 `Debug` 格式。
当你试图理解代码的执行情况时，`dbg!` 宏非常有用！

## 方法语法

**方法**（method）与函数类似：
它们通过 `fn` 关键字声明名称，可以拥有参数和返回值，并包含在调用时会执行的代码。

但方法与函数不同之处在于，它们是在结构体（或枚举、trait 对象）的上下文中定义的，并且第一个参数总是 `self`，代表调用该方法的实例。

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        rect1.area()
    );
}
```

为了将函数定义在 `Rectangle` 的上下文中，我们引入了一个 `impl` 块（`impl` 是 _implementation_ 的缩写）。
这个 `impl` 块中的所有内容都会与 `Rectangle` 类型关联。
接着，将 `area` 函数移动到 `impl` 大括号内，并将其签名中的第一个（也是唯一一个）参数，以及函数体中相应的地方，改为 `self`。
然后，在 `main` 中，将之前通过传递 `rect1` 调用 `area` 函数的代码改为 **方法语法**（method syntax），在 `Rectangle` 实例上调用 `area` 方法。

> 方法语法的形式是：实例名 + 点号 + 方法名 + 圆括号（以及任何参数）。

在 `area` 的签名中，使用 `&self` 来替代 `rectangle: &Rectangle`，其中 `&self` 实际上是 `self: &Self` 的简写。

> 在 `impl` 块中，`Self` 是该块所关联类型的别名。

方法的第一个参数必须是名为 `self` 的 `Self` 类型参数，因此 Rust 允许在第一个参数位置直接使用 `self` 来简化书写。
注意，我们仍然需要在 `self` 前加 `&`，表示该方法借用了 `Self` 实例，就像之前的 `rectangle: &Rectangle` 一样。
方法可以选择获取 `self` 的所有权，或者像这里一样不可变借用，或者可变借用，就像其他参数一样灵活。

这里选择 `&self` 的理由与在函数版本中使用 `&Rectangle` 是相同的：
**我们并不希望获取所有权，只想读取结构体中的数据，而不是修改它们**。
如果希望在方法中改变调用方法的实例，则需要将第一个参数改为 `&mut self`。
而仅使用 `self` 作为第一个参数以获取实例的所有权的情况较少见；
这种做法通常用于方法将 `self` 转换成另一个实例时，以防调用者在转换后继续使用原来的实例。

> 原来的实例如果不想要了，就可以考虑 move 其所有权。

使用**方法**替代**函数**，除了可以使用方法语法和避免在每个函数签名中重复 `self` 的类型之外，其主要优势在于组织性。
我们可以将某个类型实例能执行的所有操作集中放入同一个 `impl` 块，而不是让将来的用户在库中到处寻找 `Rectangle` 的相关功能。

**注意**，我们可以选择将方法的名称与结构中的一个字段相同。
例如，我们可以在 `Rectangle` 上定义一个方法，并命名为 `width`：

```rust
impl Rectangle {
    fn width(&self) -> bool {
        self.width > 0
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    if rect1.width() {
        println!("The rectangle has a nonzero width; it is {}", rect1.width);
    }
}
```

> 在 `main` 中，当我们在 `rect1.width` 后加上括号时，Rust 会理解我们指的是方法 `width`；
> 而当不加括号时，Rust 会理解我们指的是字段 `width`。

通常（但并非总是如此），与字段同名的方法会被定义为**仅返回该字段的值**，而不执行其他操作。
这样的函数称为 **getter**。
与一些其他语言不同，Rust 不会为结构体字段自动生成 getter。
getter 很有用，因为你可以将字段设置为私有，而方法保持公共，从而将对字段的只读访问作为类型公共 API 的一部分提供。

### 更多带有参数的方法

让我们通过在 `Rectangle` 结构体上实现另一个方法来练习方法的使用。  
这次，我们希望让一个 `Rectangle` 实例检查它是否能够完全包含另一个 `Rectangle` 实例：  
如果 `self`（第一个 `Rectangle`）能够完全包含第二个长方形，则返回 `true`；否则返回 `false`。

```rust
fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
    let rect2 = Rectangle {
        width: 10,
        height: 40,
    };
    let rect3 = Rectangle {
        width: 60,
        height: 45,
    };

    println!("Can rect1 hold rect2? {}", rect1.can_hold(&rect2));
    println!("Can rect1 hold rect3? {}", rect1.can_hold(&rect3));
}
```

我们期待：

```
Can rect1 hold rect2? true
Can rect1 hold rect3? false
```

因为我们要定义一个方法，所以它应该位于 `impl Rectangle` 块中。
方法名为 `can_hold`，它接收另一个 `Rectangle` 的不可变借用作为参数。

从调用方法的代码可以看出参数类型：`rect1.can_hold(&rect2)` 传入了 `&rect2`，即 `rect2` 实例的不可变借用。
这是合理的，因为我们只需要读取 `rect2`（无需修改，因此使用不可变借用），同时希望 `main` 保留 `rect2` 的所有权，以便在调用方法后继续使用它。

`can_hold` 的返回值为布尔类型，其实现会检查 `self` 的宽度和高度是否都大于另一个 `Rectangle`。

```rust
impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

### 关联函数

所有在 `impl` 块中定义的函数都称为 **关联函数**（associated functions），因为它们与 `impl` 后面指定的类型相关。

我们可以定义不以 `self` 作为第一个参数的关联函数（**因此它们不是方法**），因为这些函数并不作用于结构体的某个实例。
一个常见的例子是 `String::from`，它是在 `String` 类型上定义的关联函数。

> 所有的方法都是关联函数，但并非所有的关联函数都是方法。

**非方法的关联函数经常被用作创建结构体新实例的构造函数**。
这些函数通常命名为 `new`，但 `new` 并不是关键字。
例如，我们可以定义一个名为 `square` 的关联函数，它接收一个尺寸参数，并将该尺寸同时作为宽度和高度，从而更方便地创建一个正方形 `Rectangle`，而无需重复指定相同的值。

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn square(size: u32) -> Self {
        Self {
            width: size,
            height: size,
        }
    }
}

fn main() {
    let sq = Rectangle::square(3);

    dbg!(&sq);
}
```

关键字 `Self` 在函数的返回类型和函数体中，都是对 `impl` 关键字后指定类型的别名，这里指的是 `Rectangle`。

要调用这个关联函数，我们使用结构体名加上 `::` 语法，例如：`let sq = Rectangle::square(3);`
