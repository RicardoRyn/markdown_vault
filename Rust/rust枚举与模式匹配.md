# 枚举与模式匹配

枚举（enumerations），也称为 **enums**。
枚举允许你通过列举可能的 **变体**（variants）来定义一个类型。

我们首先会定义并使用一个枚举，展示它如何携带数据并编码信息。
接着，我们将探索一个特别有用的枚举——`Option`，它表示一个值要么存在，要么不存在。
然后会讲解如何在 `match` 表达式中使用模式匹配，根据不同的枚举值编写相应的代码。
最后，我们会介绍 `if let`，另一种简洁方便处理枚举的语法结构。

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
着可以定义一个函数来接收任何 IpAddrKind类型的参数：

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
