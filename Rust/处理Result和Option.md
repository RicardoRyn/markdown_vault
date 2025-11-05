# 容易混淆的方法

## 在处理 `Option` 和 `Result` 时

先定义一些变量

```rust
let ok: Result<i32, &str> = Ok(10);
let err: Result<i32, &str> = Err("something went wrong");

let some: Option<i32> = Some(5);
let none: Option<i32> = None;
```

### 1. `.unwrap()`

要么输出值，要么直接panic

```rust
// Result
println!("{}", ok.unwrap()); // ✅ 输出 10
println!("{}", err.unwrap()); // ❌ panic: called `Result::unwrap()` on an `Err` value: "something went wrong"

// Option
println!("{}", some.unwrap()); // ✅ 输出 5
println!("{}", none.unwrap()); // ❌ panic: called `Option::unwrap()` on a `None` value
```

### 2. `.expect()`：

和 `unwrap()` 一样，但 panic 时会输出自定义信息，方便调试。

```rust
// Result
println!("{}", ok.expect("should be ok")); // ✅ 输出 10
println!("{}", err.expect("file reading failed")); // ❌ panic: file reading failed: "something went wrong"

// Option
println!("{}", some.expect("should be ok")); // ✅ 输出 5
println!("{}", none.expect("file reading failed")); // ❌ panic: file reading failed: "something went wrong"
```

### 3. `.unwrap_or()`

如果 `Ok` 或 `Some`，就取值；否则返回一个固定的默认值。

```rust
// Result
println!("{}", ok.unwrap_or(1998)); // ✅ 10
println!("{}", err.unwrap_or(1998)); // ✅ 1998

// Option
println!("{}", some.unwrap_or(1215)); // ✅ 5
println!("{}", none.unwrap_or(1215)); // ✅ 1215
```

### 4. `.unwrap_or_else(|| expression)`

和 `unwrap_or()` 类似，但是可以传入一个函数，用于生成默认值。

```rust
// Result
println!(
    "{}",
    ok.unwrap_or_else(|e| {
        println!("Error: {e}");
        1998
    })
); // ✅ 输出 10，不执行闭包
println!(
    "{}",
    err.unwrap_or_else(|e| {
        println!("Error: {e}");
        1998
    })
); // 🔸 输出：Error: something went wrong，✅ 返回 1998

// Option
println!(
    "{}",
    ok.unwrap_or_else(|| {
        println!("Error");
        1215
    })
); // ✅ 输出 5，不执行闭包
println!(
    "{}",
    err.unwrap_or_else(|| {
        println!("Error");
        1215
    })
); // 🔸 输出：Error: something went wrong，✅ 返回 1215
```

### 5.`?`

如果结果是 `Ok` / `Some` → 继续执行；如果是 `Err` / `None` → 立刻返回错误（或 `None`）。

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file() -> Result<String, io::Error> {
    let mut file = File::open("hello.txt")?; // 👈 可能失败
    let mut contents = String::new();
    file.read_to_string(&mut contents)?; // 👈 也可能失败
    Ok(contents)
}

fn get_char(s: &str) -> Option<char> {
    let first = s.chars().next()?; // 👈 如果字符串为空，就直接返回 None
    Some(first)
}
```

### 6. `is_ok()` 和 `is_err()`

转换成 `bool` 值

```rust
// Result
assert!(ok.is_ok()); // true
assert!(err.is_err()); // true

// Option
assert!(some.is_some()); // true
assert!(none.is_none()); // true
```
