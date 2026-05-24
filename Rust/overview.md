## 1. 元组

### 整体所有权

```rust
fn main() {
    let a = (String::from("hello"), 2);
    let b = a;
    println!("{:?}", a); // ❌ 错误，整个a的所有权移动到b了
    println!("{:?}", b);
}
```

### 部分所有权

**部分元素的所有权移动之后，整体无法被使用，但是允许使用仍然拥有所有权的元素。**

```rust
fn main() {
    let a = (String::from("hello"), 2);
    let b = a.0;
    println!("{:?}", a); // ❌ 错误，部分所有权被移动后，整体无法被访问
    println!("{:?}", a.1); // ✅ 可以
    println!("{:?}", b);
}
```

### 整体可变性

```rust
fn main() {
    let mut a = (String::from("hello"), 2);
    a.0.push_str(" world");
    a.1 += 1;
    println!("{:?}", a); // ("hello world", 3)
}
```

### 部分可变性

元组不存在部分元素可变、部分元素不可变的情况。要么都可变，要么都不能变。

### 整体可见性

元组本身没有独立的可见性修饰符。

### 部分可见性

元组的字段没有名称，也无法单独使用 pub 标记。

## 2. 数组

### 整体所有权

```rust
fn main() {
    let a = [String::from("hello"), String::from("world")];
    let b = a; // 整个数组的所有权移动到 b
    println!("{:?}", a); // ❌ 错误，a 已失效
    println!("{:?}", b);
}
```

### 部分所有权

**数组不支持部分移动单个元素。**

```rust
fn main() {
    let a = [String::from("hello"), String::from("world")];
    let s = a[0]; // ❌ 错误：无法移出数组中的元素
    let b = a; // 只能整体移动
}
```

### 整体可变性

```rust
fn main() {
    let mut a = [String::from("hello"), String::from("world")];
    a[0].push_str("!");
    a[1] = String::from("rust");
    println!("{:?}", a); // ["hello!", "rust"]
}
```

### 部分可变性

数组本身不存在“部分元素可变、部分元素不可变”的绑定级别设置。要么都可变，要么都不能变。

### 整体可见性

数组类型本身没有独立的可见性修饰符。

### 部分可见性

数组的每个元素没有名称，也无法单独使用 pub 标记。

## 3. 结构体

### 整体所有权

```rust
#[derive(Debug)]
struct Person {
    name: String,
    age: i32,
}

fn main() {
    let a = Person {
        name: String::from("Alice"),
        age: 30,
    };
    let b = a; // 整个结构体的所有权移动到 b
    println!("{:?}", a); // ❌ 错误，a 已失效
}
```

### 部分所有权

**部分字段的所有权移动之后，整体无法被使用，但是允许使用仍然拥有所有权的字段。**

```rust
#[derive(Debug)]
struct Person {
    name: String,
    age: i32,
}

fn main() {
    let a = Person {
        name: String::from("Alice"),
        age: 30,
    };
    let b = a.name; // 移动 name 字段的所有权
    println!("{:?}", a); // ❌ 错误，部分移动后整体a无法使用
    println!("{}", a.age); // ✅ 可以
    println!("{}", b);
}
```

### 整体可变性

```rust
#[derive(Debug)]
struct Person {
    name: String,
    age: i32,
}

fn main() {
    let mut a = Person {
        name: String::from("Alice"),
        age: 30,
    };
    a.name.push_str(" Smith");
    a.age += 1;
    println!("{} {}", a.name, a.age); // "Alice Smith 31"
}
```

### 部分可变性

结构体本身不存在“部分字段可变、部分字段不可变”的绑定级别设置。要么都可变，要么都不能变。

### 整体可见性

```rust
mod my_module {
    pub struct PublicStruct {
        pub field: i32,
    } // 对父可见
    struct PrivateStruct {
        field: i32,
    } // 仅模块内可见
}
```

### 部分可见性

```rust
mod my_module {
    pub struct MyStruct {
        pub public_field: i32, // 父可直接读写
        private_field: String, // 父不可见
    }

    impl MyStruct {
        pub fn new(value: i32, text: String) -> Self {
            MyStruct {
                public_field: value,
                private_field: text,
            }
        }
        pub fn get_private(&self) -> &str {
            &self.private_field
        }
    }
}
```

## 4. 枚举

### 整体所有权

```rust
enum MyEnum {
    Text(String),
    Number(i32),
}

fn main() {
    let a = MyEnum::Text(String::from("hello"));
    let b = a; // 整个枚举的所有权移动到 b
    println!("{:?}", a); // ❌ 错误，a 已失效
    println!("{:?}", b);
}
```

### 部分所有权

**部分字段的所有权移动之后，整体无法被使用，但是允许使用仍然拥有所有权的字段。**

```rust
#[derive(Debug)]
enum MyEnum {
    Pair(String, String),
}

fn main() {
    let a = MyEnum::Pair(String::from("hello"), String::from("world"));
    match a {
        MyEnum::Pair(s, _) => {
            println!("{}", s);
        }
    }
    println!("{:?}", a); // ❌ 错误：部分移动后整体无法使用

    match a {
        MyEnum::Pair(_, v) => {
            println!("{}", v);
        }
    } // ✅ 可以
}
```

### 整体可变性

```rust
#[derive(Debug)]
enum MyEnum {
    Text(String),
    Number(i32),
}

fn main() {
    let mut a = MyEnum::Text(String::from("hello"));
    // 修改变体内部的数据
    match &mut a {
        MyEnum::Text(s) => s.push_str(" world"),
        _ => {}
    }
    println!("{:?}", a);
    // 重新赋值为另一个变体
    a = MyEnum::Number(42);
    println!("{:?}", a);
}
}
```

### 部分可变性

枚举本身不存在“部分变体可变、部分变体不可变”的绑定级别设置。要么都可变，要么都不能变。

### 整体可见性

枚举本身可以使用 pub 标记其可见性。

```rust
mod my_module {
    pub enum PublicEnum {
        A,
        B,
    } // 对外可见
    enum PrivateEnum {
        C,
        D,
    } // 仅模块内可见
}
```

### 部分可见性

枚举的变体无法单独使用 pub 标记（所有变体要么都可见，要么都不可见）。

## Vec

### 整体所有权

```rust
fn main() {
    let v1 = vec![String::from("hello"), String::from("world")];
    let v2 = v1; // 整个 Vec 的所有权移动到 v2
    println!("{:?}", v1); // ❌ 错误，v1 已失效
}
```

### 部分所有权

`Vec`不支持直接通过索引部分移动元素。
但可以通过`pop`、`remove`、`drain` 等方法将元素的所有权移出，这会改变 `Vec` 的结构。

```rust
fn main() {
    // 非 Copy 元素：不能直接索引移动
    let mut v = vec![String::from("a"), String::from("b")];
    let s = v[0]; // ❌ 错误：不能移出 Vec 中的元素

    // 可以使用 pop 移出最后一个元素
    let s = v.pop(); // ✅ pop 返回 Option<String>
    println!("{:?}", s); // Some("b")
    println!("{:?}", v); // ["a"]

    // 使用 remove 移出指定位置
    let t = v.remove(0); // ✅ 移出索引 0 的元素
    println!("{}", t); // "a"
    println!("{:?}", v); // []

    // Copy 元素：索引访问是复制
    let v2 = vec![1, 2, 3];
    let x = v2[0]; // ✅ i32 是 Copy
    println!("{:?}", v2); // [1, 2, 3]
}
```

### 整体可变性

```rust
fn main() {
    let mut v = vec![String::from("a"), String::from("b")];
    v.push(String::from("c")); // 添加元素
    v[0].push_str("!"); // 修改已有元素
    v[1] = String::from("x"); // 替换元素
    println!("{:?}", v); // ["a!", "x", "c"]
}
```

### 部分可变性

Vec 本身不存在“部分元素可变、部分元素不可变”的绑定级别设置。要么都可变，要么都不能变。

### 整体可见性
数组类型本身没有独立的可见性修饰符。
### 部分可见性
元组的字段没有名称，也无法单独使用 pub 标记。
