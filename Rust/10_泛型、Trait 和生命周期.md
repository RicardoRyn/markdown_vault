# 泛型、Trait 和生命周期

## 泛型数据类型

注意必须在`impl`后面声明`T`，这样就可以在`Point<T>`上实现的方法中使用`T`了。
通过在`impl`之后声明泛型`T`，Rust 就知道`Point`的尖括号中的类型是泛型而不是具体类型。
可以为泛型参数选择一个与结构体定义中声明的泛型参数所不同的名称，不过**依照惯例**推荐使用了相同的名称。

```rust
struct Point<T> {
    x: T,
    y: T,
}

// 可以，但不推荐用U代替T
impl<U> Point<U> {
    fn x(&self) -> &U {
        &self.x
    }
}

// 不在impl后跟<T>，就会把Point中的<T>识别为一个具体的类型
impl Point<f64> {
    fn distance_from_origin(&self) -> f64 {
        ((self.x.pow(2) + self.y.pow(2)) as f64).sqrt()
    }
}
```

结构体定义中的泛型类型参数并不总是与结构体方法签名中使用的泛型是同一类型。

```rust
struct Point<X1, Y1> {
    x: X1,
    y: Y1,
}

impl<X1, Y1> Point<X1, Y1> {
    fn mixup<X2, Y2>(self, other: Point<X2, Y2>) -> Point<X1, Y2> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}

fn main() {
    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hello", y: 'c' };

    let p3 = p1.mixup(p2);

    println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```

Rust 的泛型是编译时机制。

- 编译器会分析所有使用泛型的地方，根据实际传递的具体类型，为每种类型生成一份独立的代码。
- 编译时单态化要求类型在编译时已知。
- 即**静态派发**。

当需要表示“某种实现了某个`trait`的类型，但具体是什么只有在运行时才知道”时，
可以使用`Box<dyn Trait>`或`&dyn Trait`。
这会产生**动态派发**。

```rust
trait Draw {
    fn draw(&self);
}
struct Circle;
struct Square;
impl Draw for Circle {
    fn draw(&self) {
        println!("Circle");
    }
}
impl Draw for Square {
    fn draw(&self) {
        println!("Square");
    }
}

fn draw_random(choice: bool) -> Box<dyn Draw> {
    if choice {
        Box::new(Circle)
    } else {
        Box::new(Square)
    }
}

// 或者
enum Shape {
    Circle,
    Square,
}
fn draw(shape: Shape) {
    match shape {
        Shape::Circle => println!("Circle"),
        Shape::Square => println!("Square"),
    }
}
```

这里，返回的类型`Box<dyn Draw>`在编译时只知道它实现了`Draw` trait，具体是`Circle`还是`Square`由运行时`choice`决定。

## Trait：定义共同行为

`trait`必须和类型一起引入作用域以便使用额外的`trait`方法。

```rust
use aggregator::{SocialPost, Summary};

// 下面虽然没有出现"Summary"字样，但是.summarize方法属于Summary trait
fn main() {
    let post = SocialPost {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        repost: false,
    };

    println!("1 new post: {}", post.summarize());
}
```

可以使用`trait`作为参数：

```rust
// item是一个类型，这个类型只要实现了Summary这个trait就行
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// 语法糖写法（推荐）
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}

//模板
// fn 函数名<泛型: 特征>(参数: 泛型)
```

这两种写法各有侧重：

```rust
// item1和item2不一定是同一种类型
pub fn notify(item1: &impl Summary, item2: &impl Summary) {}

// item1和item2一定是同一种类型
pub fn notify<T: Summary>(item1: &T, item2: &T) {}
```

指定具有多个`trait`的类型：

```rust
pub fn notify(item: &(impl Summary + Display)) {}

pub fn notify<T: Summary + Display>(item: &T) {}
```

通过`where`来表达类型的`trait`：

1. shere后没有括号
2. 每个<泛型>:<特征>后有“,”
3. 函数体的括号在最后

```rust
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
    42
}

// 1. shere后没有括号
// 2. 每个<泛型>:<特征>后有“,”
// 3. 函数体的括号在最后
fn some_functionk<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{
    42
}
```

返回值若指定为具有某`trait`的类型，也是可以的，但是只能是同一种类型：

```rust
// ❌ 错误，只能返回一种类型，尽管它们都实现了同一种Trait
fn returns_summarizable(switch: bool) -> impl Summary {
    if switch {
        NewsArticle {
            headline: String::from("Penguins win the Stanley Cup Championship!"),
            location: String::from("Pittsburgh, PA, USA"),
            author: String::from("Iceburgh"),
            content: String::from(
                "The Pittsburgh Penguins once again are the best \
                 hockey team in the NHL.",
            ),
        }
    } else {
        SocialPost {
            username: String::from("horse_ebooks"),
            content: String::from("of course, as you probably already know, people"),
            reply: false,
            repost: false,
        }
    }
}
```

对任何实现了A trait（`Display`）的类型再去实现B trait（`ToString`）：

```rust
impl<T: Display> ToString for T {}
```

## 生命周期确保引用有效

**很少看到函数参数不是引用，但返回值是引用的情况。**
**很少看到函数参数不是引用，但返回值是引用的情况。**
**很少看到函数参数不是引用，但返回值是引用的情况。**

#### 函数中的生命周期

生命周期语法是用于将函数的多个参数与其返回值的生命周期进行关联的。

**引用**的生命周期不能长于**被引用数据**的生命周期，
即**被引用数据**的存活时间必须大于或等于**引用**的生命周期。

> **被引用数据是爹**，必须比引用活的更久。

```rust
&i32        // 引用
&'a i32     // 带有显式生命周期的引用
&'a mut i32 // 带有显式生命周期的可变引用
```

`fn longest<'a>(x: &'a str, y: &'a str) -> &'a str`并不是说`x`和`y`具有完全相同的生命周期，而是要求：

- `x` 的生命周期 ≥ `'a`
- `y` 的生命周期 ≥ `'a`
- 编译器在调用时会推断`'a`为`x`和`y`生命周期中较短的那个
- 第一反应应该是：返回值的生命周期**不会超过** x 和 y 中的任何一个

> 生命周期越**短**越**安全**，长了就可能悬垂引用。

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

fn main() {
    let string1 = String::from("long string is long");

    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("The longest string is {result}"); // ✅，正确
    }
    println!("The longest string is {result}"); // ❌，错误
}
```

> 因为声明了生命周期，所以`longest`返回值的生命周期不会长于`min(string1, string2)`。
> 从而保证了`result`的可用。

返回引用的来源只有两种可能:

1. 来自参数：例如返回 x 或 y，或者返回参数的一部分（如结构体字段）。如上所述。
2. 来自函数内部创建的值：例如局部变量、临时计算结果等。多半为悬垂引用，错误。

结构体中的生命周期，
这个注解意味着`ImportantExcerpt`的生命周期不长于`part`字段中的引用：

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().unwrap();
    let i = ImportantExcerpt {
        part: first_sentence,
    };
}
```

生命周期省略规则：

1. 编译器为每一个**引用参数**都分配一个生命周期参数：`fn foo<'a, 'b, 'c>(x: &'a i32, y: &'b i32, z: &'c i32, i: i32, j: i32)`
2. 如果只有**一个**输入生命周期参数，那么将它赋予给所有输出生命周期参数：`fn foo<'a>(x: &'a i32) -> &'a i32`。
3. 如果**方法**有多个输入生命周期参数并且其中一个参数是`&self`或`&mut self`，那么所有输出生命周期参数被赋予`self`的生命周期。

#### 结构体中的生命周期

结构体的生命周期有2种：

1. 与结构体字段相关：
   ```rust
   struct MyStruct<'a> {
       field: &'a str,
   }
   ```
2. 与方法参数和返回值相关：
   ```rust
   // 结构体字段的生命周期必须总是在 impl 关键字之后声明并在结构体名称之后被使用
   // 即这个例子中的`'a`。因为这些生命周期是结构体类型的一部分
   // 不管impl块中是否用到'a，都一定要写上，因为`MyStruct<'a>`是一个完整的类型，生命周期参数是其类型签名的一部分
   impl<'a> MyStruct<'a> {
       fn do_something<'b>(&self, other: &'b str) -> &'b str {
           other
       }
   }
   ```
