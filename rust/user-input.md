# User Input in Rust

Rust offers multiple approaches to reading and parsing user input. Each method differs in ergonomics, performance, and the kind of control it provides over I/O streams, buffering, and parsing patterns. Below is a comprehensive guide across common approaches.

---

## 1. Basic Input Using `std::io::stdin()`

This is the standard and most direct approach for handling input from the terminal.

```rust
use std::io;

fn main() {
    let mut input = String::new();
    println!("Enter your name:");

    io::stdin().read_line(&mut input).expect("Failed to read input");

    println!("Hello, {}!", input.trim());
}
```

### How it works:
- `read_line()` appends user input to the target `String`
- `.trim()` removes newline characters
- Result type `io::Result<usize>` returns number of bytes read

---

## 2. Input Parsing into Numeric Types

Rust requires explicit parsing because all input begins as a string:

```rust
use std::io;

fn main() {
    let mut input = String::new();
    println!("Enter a number:");

    io::stdin().read_line(&mut input).unwrap();

    let num: i32 = input.trim().parse().unwrap();
    println!("Number doubled: {}", num * 2);
}
```

### Notes:
- `.parse()` converts string slices into numbers.
- `.unwrap()` crashes on failure; `.expect("msg")` improves debugging.

---

## 3. Handling Input Errors Gracefully

```rust
use std::io;

fn main() {
    let mut input = String::new();
    println!("Enter a number:");

    io::stdin().read_line(&mut input).unwrap();

    match input.trim().parse::<i32>() {
        Ok(n) => println!("Valid number: {}", n),
        Err(e) => println!("Error: {}", e),
    }
}
```

This is preferred for production code because it avoids panic scenarios.

---

## 4. Using `std::io::BufRead` for Streaming Input

Use `BufRead` when reading multiple lines efficiently:

```rust
use std::io::{self, BufRead};

fn main() {
    let stdin = io::stdin();
    for line in stdin.lock().lines() {
        println!("Input: {}", line.unwrap());
    }
}
```

### Highlights:
- Efficient for line-by-line processing
- Ideal for large or streaming input

---

## 5. Using Command-Line Arguments Instead of `stdin`

```rust
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    println!("{:?}", args);
}
```

Used when user input happens at execution time, not runtime.

---

## 6. Using `text_io` Crate (User-Friendly Input)

Add to `Cargo.toml`:

```
text_io = "0.1"
```

Example usage:

```rust
use text_io::read;

fn main() {
    println!("Enter a number:");
    let n: i32 = read!();
    println!("Output: {}", n);
}
```

---

## 7. Performance Comparison Summary

| Method | Best For | Performance | Complexity |
|--------|----------|-------------|------------|
| `stdin().read_line()` | General input | Moderate | Low |
| `.parse()` conversion | Numeric parsing | High | Moderate |
| `BufRead` streaming | Multi-line / large input | Very high | Medium |
| CLI args | Non-interactive input | Very high | Low |
| `text_io` crate | User-friendly parsing | High | Very low |

---

## 8. Real-World Example: Menu Input Loop

```rust
use std::io;

fn main() {
    loop {
        println!("1) Say Hello
2) Quit");

        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();

        match input.trim() {
            "1" => println!("Hello!"),
            "2" => break,
            _ => println!("Invalid option"),
        }
    }

    println!("Goodbye.");
}
```

---

# Summary

Rust gives you flexible options for retrieving and parsing user input. Whether reading a single line, parsing numeric types, streaming lines, or grabbing CLI arguments, each approach offers different trade-offs in ergonomics, performance, and safety. Choose the input strategy that fits the runtime nature of your application.
