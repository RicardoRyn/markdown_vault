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
