# Rust Functions

Rust functions are explicitly typed, expression-oriented, and commonly combined with iterators and closures.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `fn name(args) -> T` | Standard function declaration | `fn add(a: i32, b: i32) -> i32` |
| Expression return | Return last expression without `;` | `a + b` |
| Early `return` | Exit function explicitly | `return Err(e);` |
| Generic function | Reusable across types | `fn first<T>(items: &[T]) -> Option<&T>` |
| Closure `|x| ...` | Inline anonymous function | `items.iter().map(|x| x * 2)` |

## Common Built-in/Std Function Helpers

| API | Purpose | Example |
| --- | --- | --- |
| `println!` / `format!` | Output and string formatting | `println!("{x}")` |
| `dbg!` | Debug-print expression and value | `dbg!(value)` |
| `drop` | Explicitly drop value early | `drop(lock)` |
| `std::mem::take` / `replace` | Move/replace values safely | `std::mem::take(&mut buf)` |
| Iterator adapters (`map`, `filter`, `fold`) | Functional data processing | `nums.iter().fold(0, |a, n| a + n)` |

## Examples

```rust
fn transform(values: &[i32], f: impl Fn(i32) -> i32) -> Vec<i32> {
    values.iter().map(|v| f(*v)).collect()
}
```
