# 枚举与模式匹配

枚举（enumerations），也称为 **enums**。
枚举允许你通过列举可能的 **变体**（variants）来定义一个类型。

## 枚举的定义

结构体提供了一种将**字段**和**数据**聚合在一起的方法，例如 `Rectangle` 结构体有 `width` 和 `height` 两个字段。
而枚举则提供了一种方式来声明**某个值属于一组可能的选项之一**。例如，如果我们希望 `Rectangle` 是一些形状集合中的一个成员，集合中还包括 `Circle` 和 `Triangle`，Rust 允许我们将这些可能性编码为一个枚举类型。

假设我们要处理 IP 地址，目前广泛使用的两种主要 IP 标准是 IPv4（version four）和 IPv6（version six）。
在程序中，IP 地址可能的类型就只有这两种，因此可以将所有可能的值枚举出来，这也正是“枚举”一词的由来。

任何一个 IP 地址要么是 IPv4，要么是 IPv6，不可能同时属于两者。
这个特性使得枚举非常适合描述 IP 地址，因为枚举值只可能是其中的一个变体。
尽管 IPv4 和 IPv6 在底层不同，但它们本质上都是 IP 地址，因此在处理适用于任意类型 IP 地址的代码时，可以将它们视作相同类型。

我们可以通过在代码中定义一个 `IpAddrKind` 枚举来表达这个概念，并列出可能的 IP 地址类型 `V4` 和 `V6`。
这两个成员就是枚举的 **变体**（variants）。

```rust
enum IpAddrKind {
    V4,
    V6,
}
```

> 现在 `IpAddrKind` 就是一个可以在代码中使用的**自定义数据类型**了。

## 枚举值

创建 `IpAddrKind` 两个不同变体的实例：

```rust
enum IpAddrKind {
    V4,
    V6,
}

fn main() {
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;
}
```

注意，枚举的变体位于其标识符的命名空间中，并使用双冒号 `::` 进行访问。
这种设计的好处在于，`IpAddrKind::V4` 和 `IpAddrKind::V6` 都被视为 `IpAddrKind` 类型的值。
着可以定义一个函数来接收任何 `IpAddrKind`类型的参数：

```rust
enum IpAddrKind {
    V4,
    V6,
}

fn main() {
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;

    route(IpAddrKind::V4);
    route(IpAddrKind::V6);
}

fn route(ip_kind: IpAddrKind) {}
```

使用枚举还有更多优势。
进一步考虑我们的 IP 地址类型，目前我们只能表示 IP 地址的类型，却没有办法存储实际的 IP 地址数据。

```rust
fn main() {
    enum IpAddrKind {
        V4,
        V6,
    }

    struct IpAddr {
        kind: IpAddrKind,
        address: String,
    }

    let home = IpAddr {
        kind: IpAddrKind::V4,
        address: String::from("127.0.0.1"),
    };

    let loopback = IpAddr {
        kind: IpAddrKind::V6,
        address: String::from("::1"),
    };
}
```

通过枚举可以使用一种更简洁的方式来表达相同的概念：

```rust
fn main() {
    enum IpAddr {
        V4(String),
        V6(String),
    }

    let home = IpAddr::V4(String::from("127.0.0.1"));

    let loopback = IpAddr::V6(String::from("::1"));
}
```

我们可以直接把数据附加到枚举的每个变体上，这样就不需要额外的结构体了。

这里还有一个容易被忽略但非常重要的细节：每个**枚举变体的名字**实际上也成为了一个用来构造该枚举实例的**函数**。
换句话说，`IpAddr::V4()` 就是一个函数，它接收一个 `String` 参数，并返回一个 `IpAddr` 类型的实例。
当我们定义了枚举，Rust 会自动为每个变体生成这样的构造函数。

使用枚举还有另一个优势：每个变体可以存储不同类型和数量的数据。

例如，IPv4 地址总是由四个介于 0 到 255 的数字组成。如果我们想用四个 `u8` 值表示 IPv4 地址，而让 IPv6 地址仍然用一个 `String` 表示，使用结构体就不方便了，但枚举可以轻松实现：

```rust
fn main() {
    enum IpAddr {
        V4(u8, u8, u8, u8),
        V6(String),
    }

    let home = IpAddr::V4(127, 0, 0, 1);

    let loopback = IpAddr::V6(String::from("::1"));
}
```

在这个例子中，`V4` 和 `V6` 变体存储的数据类型和数量不同，但它们都属于同一个枚举 `IpAddr`。

再来一个例子：

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

// 上下类似

struct QuitMessage; // 类单元结构体
struct MoveMessage {
    x: i32,
    y: i32,
}
struct WriteMessage(String); // 元组结构体
struct ChangeColorMessage(i32, i32, i32); // 元组结构体
```

如果使用结构体，由于每个结构体的类型不同，就无法轻松地定义**一个函数**来同时处理这些不同类型的结构体。
而枚举属于单一类型，因此可以统一处理所有变体，使得函数编写更加简单和灵活：

```rust
fn main() {
    enum Message {
        Quit,
        Move { x: i32, y: i32 },
        Write(String),
        ChangeColor(i32, i32, i32),
    }

    impl Message {
        fn call(&self) {
            // 在这里定义方法体
        }
    }

    let m = Message::Write(String::from("hello"));
    m.call();
}
```

## Option 枚举及其相对于空值的优势

这一部分将通过一个案例来分析 `Option`，它是标准库中定义的另一个枚举。
`Option` 类型非常常用，因为它刻画了一个普遍的场景：一个值要么存在，要么不存在。

```rust
enum Option<T> {
    None,
    Some(T),
}
```

> `Option<T>` 枚举已经被包含在了 prelude 之中，无需将其显式引入作用域。
> 它的变体也是如此：可以不需要 `Option::` 前缀来直接使用 `Some` 和 `None`。

`<T>` 语法是我们还没详细讲到的 Rust 特性，它表示一个 **泛型类型参数**。

目前你只需要知道，`<T>` 的含义是：`Option` 枚举中的 `Some` 变体可以包含任意类型的数据。
并且，每个用于 `T` 的具体类型，都会让 `Option<T>` 被视为一个全新的、独立的类型。
例如：

```rust
fn main() {
    let some_number = Some(5); // 类型是 `Option<i32>`
    let some_char = Some('e'); // 类型是 `Option<char>`

    let absent_number: Option<i32> = None; // 必须指定类型，因为编译器无法推断
}
```

当值是 `Some` 时，我们就知道有一个有效的数据，并且它保存在 `Some` 中。
当值是 `None` 时，从某种意义上说，它和“空值”含义相同：表示没有有效数据。

那么，为什么 `Option<T>` 会比空值更好呢？

简而言之，因为 `Option<T>` 和 `T`（这里的 `T` 可以是任意类型）是不同的类型。
编译器不会允许你像操作一个确定存在的值那样直接使用 `Option<T>`。

例如，下面的代码无法编译，因为它尝试将 `Option<i8>` 与 `i8` 相加：

```rust
// 以下代码无法编译
fn main() {
    let x: i8 = 5;
    let y: Option<i8> = Some(5);

    let sum = x + y; // 报错，`y` 是 `Option<i8>` 类型，不是 `i8` 类型。
}
```

编译器会强迫你先把 `Option<i8>` 里的值取出来（比如用 `match` 或者 `if let`），明确地处理 `None` 的情况，这样就避免了空值带来的 bug。

## match控制流结构

Rust 提供了一种非常强大的控制流运算符：**match**。
它的作用是将**一个值**依次与**一组模式**进行比较，并根据匹配到的模式执行对应的代码。

这些模式可以是字面值、变量、通配符，甚至更复杂的形式。
`match` 的强大之处在于：

1. 它的模式匹配能力非常灵活和强大；
2. 编译器会强制检查，确保你已经处理了所有可能的情况，不会遗漏。

你可以把 `match` 表达式想象成一个“硬币分类器”：
硬币从上方滑入，有很多不同大小的槽口。每个硬币会刚好掉进匹配它大小的槽里。
同样地，值也会依次和 `match` 中的模式比较，并在遇到第一个匹配的模式时进入对应的代码块执行。

我们可以写一个函数，输入一个未知的美国硬币，然后让函数像验钞机一样识别它的种类，并返回它对应的美分值：

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
```

首先，`match` 关键字后面跟着一个**表达式**，在这里就是 `coin`。
这看起来和 `if` 的用法有点像，但有一个很大的不同：

- 在 `if` 里，条件表达式必须返回布尔值（true 或 false）；
- 在 `match` 里，这个表达式可以是**任何类型**。在这个例子里，`coin` 的类型是之前定义的 `Coin` 枚举。

接下来是 **match 的分支**。

- 每个分支由两部分组成：一个**模式**和对应要执行的**代码**。
- 模式和代码之间用 `=>` 分隔。
  比如，第一个分支是 `Coin::Penny => 1`，意思是：如果值是 `Coin::Penny`，就返回 1。
- 每个分支之间用逗号分隔。

当 `match` 表达式运行时，它会依次拿 `coin` 的值和每个模式进行比较：

- 如果匹配成功，就执行对应的代码；
- 如果不匹配，就继续检查下一个分支。
  这就像一个“硬币分类器”，硬币会掉进正好匹配它的槽口里。

最后要注意：**每个分支的代码都是一个表达式**，而 `match` 的最终结果，就是被匹配到的那个分支的代码的返回值。

如果想要在分支中运行多行代码，可以使用大括号，而分支后的逗号是可选的。
例如，如下代码在每次使用 `Coin::Penny` 调用时都会打印出 “Lucky penny!”，同时仍然返回代码块最后的值，`1`：

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Lucky penny!");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}

fn main() {}
```

`match` 的另一个强大功能是：**可以把匹配到的值的一部分绑定出来使用**。
这就是我们从枚举变体中**提取数据**的方式。

举个例子：我们来改造一下枚举。
在 1999 年到 2008 年之间，美国发行了一系列 25 美分硬币（Quarter），
每个州都有自己独特的图案。
其他硬币没有这种区别，所以只有 Quarter 才需要额外记录它属于哪个州。

为了表达这种情况，我们可以修改枚举，把 `Quarter` 变体改成包含一个 `State` 值。
这样，枚举不仅能表示硬币的种类，还能额外保存与该种类相关的数据：

```rust
#[derive(Debug)] // 这样可以立刻看到州的名称
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn main() {}
```

想象一下，你有个朋友正在收集全部 50 个州的 25 美分硬币。
在分类零钱时，我们不仅要识别硬币的类型，还想报告出每个 25 美分硬币对应的州名，
这样朋友就能知道哪些州的硬币还缺少，从而加入收藏。

在下面的代码中，我们给 `Coin::Quarter` 这个分支的模式增加了一个变量 `state`。
当匹配到 `Coin::Quarter` 时，这个 `state` 变量就会绑定到该硬币对应的州上。
然后，我们就能在分支的代码里使用 `state`，打印出它的值：

```rust
#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {state:?}!");
            25
        }
    }
}

fn main() {
    value_in_cents(Coin::Quarter(UsState::Alaska));
}
```

通过这种方式，我们就能把枚举 `Coin` 的 `Quarter` 变体里保存的州信息提取出来并使用。

## 匹配 `Option<T>`

在前面的部分，我们使用 `Option<T>` 时，是为了从 `Some` 变体中取出内部的值 `T`。
其实，我们也可以像处理 `Coin` 枚举那样，用 `match` 来处理 `Option<T>`！
唯一的区别是，这次匹配的是 `Option<T>` 的变体，而不是硬币类型。

举个例子，假设我们想写一个函数，它接收一个 `Option<i32>`：

- 如果其中有值，就把它加一；
- 如果没有值（`None`），就直接返回 `None`，不做任何操作。

借助 `match`，这个函数的实现非常直观，如下所示：

```rust
fn main() {
    fn plus_one(x: Option<i32>) -> Option<i32> {
        match x {
            None => None,
            Some(i) => Some(i + 1),
        }
    }

    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
}
```

### 通配符和 `_` 占位符

`match` 不仅可以匹配枚举的不同变体，也可以匹配具体的值或模式。
甚至只针对少数几个特定值做特殊操作，而对其他所有情况执行默认操作：

```rust
fn main() {
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        other => move_player(other),
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
    fn move_player(x: u8) {}
}
```

`match` 是按顺序检查每个分支的。
所以通配分支必须放在最后，否则后面的分支永远不会被匹配到，Rust 会给出警告。

Rust 还提供了一个模式，当我们不想使用通配模式获取的值时，请使用 `_` 。
这是一个特殊的模式，可以匹配任意值而不绑定到该值：

```rust
fn main() {
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        _ => reroll(),
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
    fn reroll() {}
}
```

`_`：忽略匹配的值，不绑定。
`other`：匹配并绑定值，可以在分支中使用，但如果不使用会产生警告。

在功能上，如果分支内部根本不需要值，使用 `_` 更干净。
如果你需要在分支中访问该值，就用命名变量（`other`）。

```rust
fn main() {
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        _ => (),
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
}
```

## `if let` 和 `let else` 简介控制流

`if let` 语法让我们以一种不那么冗长的方式结合 `if` 和 `let`，来处理只匹配一个模式的值而忽略其他模式的情况：

```rust
fn main() {
    let config_max = Some(3u8);
    match config_max {
        Some(max) => println!("The maximum is configured to be {max}"),
        _ => (),
    }
}
```

如果值是 `Some`，我们希望打印出 `Some` 变体中的值，这个值被绑定到模式中的 max 变量里。
对于 `None` 值我们不希望做任何操作。

为了满足 `match` 表达式（穷尽性）的要求，必须在处理完这唯一的变体后加上 `_ => ()`。

现在可以使用 `if let` 这种简洁的方式编写：

```rust
fn main() {
    let config_max = Some(3u8);
    if let Some(max) = config_max {
        println!("The maximum is configured to be {max}");
    }
}
```

`if let` 语法获取通过等号分隔的**一个模式**和**一个表达式**。
在这里，模式是 `Some(max)`，`max` 绑定为 `Some` 中的**值**。
接着可以在 `if let` 代码块中使用 `max` 了，就跟在对应的 `match` 分支中一样。
只有当值匹配该模式时，`if let` 块中的代码才会执行。

> `if let` 会失去 `match` 强制要求的穷尽性检查来确保你没有忘记处理某些情况
> 可以认为 `if let` 是 `match` 的一个语法糖，它当值匹配某一模式时执行代码而忽略所有其他值。

可以在 `if let` 中包含一个 `else`：

```rust
#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn main() {
    let coin = Coin::Penny;
    let mut count = 0;
    match coin {
        Coin::Quarter(state) => println!("State quarter from {state:?}!"),
        _ => count += 1,
    }
}
```

```rust
#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn main() {
    let coin = Coin::Penny;
    let mut count = 0;

}
```

在实际编程中，一个常见的场景是：如果某个值存在，就对它做一些操作；如果不存在，就返回一个默认值。

还是继续用处理 `UsState` 的硬币作为例子。
假设我们要写点有趣的逻辑，它依赖于硬币所代表的州成立了多久。
我们就可以在 `UsState` 上定义一个方法，用来检查州的“年龄”：

```rust
#[derive(Debug)] // so we can inspect the state in a minute
enum UsState {
    Alabama,
    Alaska,
}

impl UsState {
    fn existed_in(&self, year: u16) -> bool {
        match self {
            UsState::Alabama => year >= 1819,
            UsState::Alaska => year >= 1959,
        }
    }
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn describe_state_quarter(coin: Coin) -> Option<String> {
    if let Coin::Quarter(state) = coin {
        if state.existed_in(1900) {
            Some(format!("{state:?} is pretty old, for America!"))
        } else {
            Some(format!("{state:?} is relatively new."))
        }
    } else {
        None
    }
}

fn main() {
    if let Some(desc) = describe_state_quarter(Coin::Quarter(UsState::Alaska)) {
        println!("{desc}");
    }
}
```

