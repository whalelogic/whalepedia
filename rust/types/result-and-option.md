# ❓ `Result` and `Option`

Rust has **no `null`** and **no exceptions**. Instead, it models a missing value and a failed operation with two enums from the standard library: `Option<T>` and `Result<T, E>`. Because these are ordinary types, the compiler makes you deal with the "nothing here" or "it went wrong" case *before* you can reach the value inside — turning a whole class of runtime bugs into compile-time errors.

> 💡 An enum is a type whose value is one of a fixed set of cases (each case is called a **variant**). `Option` and `Result` are just enums with two variants each — nothing magical.

## 🎁 `Option<T>` — maybe a value

`Option<T>` represents a value that might be present or absent. Its two variants:

| Variant   | Meaning                          |
|-----------|----------------------------------|
| `Some(T)` | a value of type `T` is present   |
| `None`    | there is no value                |

Use `Option` when absence is a **normal, expected** possibility: looking up a key that may not exist, the first element of a possibly-empty collection, or a config field that's optional.

## 🚦 `Result<T, E>` — success or failure

`Result<T, E>` represents an operation that can succeed or fail. Its two variants:

| Variant  | Meaning                                       |
|----------|-----------------------------------------------|
| `Ok(T)`  | success, carrying a value of type `T`         |
| `Err(E)` | failure, carrying an error of type `E`        |

Use `Result` when an operation can fail for a reason you want to **describe**: parsing input, reading a file, or making a network request.

## Getting the value out

Both types hold their contents inside a variant, so you have to unwrap that variant to reach the value. Your options, from safest to most abrupt:

- **`match`** — handle every case explicitly. Safest, most verbose.
- **`if let`** — handle one case concisely.
- **`.unwrap()` / `.expect()`** — pull out the inner value, but **crash the program** (a *panic*) on `None`/`Err`. Handy for prototypes and tests.
- **`.unwrap_or(default)` / `.unwrap_or_else(..)`** — supply a fallback instead of crashing.
- **The `?` operator** — a shortcut you write *after* an `Option`/`Result` value. In a function that returns `Option`/`Result`, it hands you the inner value on success, or stops the function early and passes the `None`/`Err` straight back to the caller.

> ⚠️ **Avoid `.unwrap()` and `.expect()` on production paths.** They convert a recoverable situation into a hard crash. Prefer `match`, a fallback, or `?` so failures stay in the type system where the compiler can help.

## Example

```rust
// Returns Option: the answer may legitimately not exist.
fn first_even(numbers: &[i32]) -> Option<i32> {
    for &n in numbers {
        if n % 2 == 0 {
            return Some(n);
        }
    }
    None
}

// Returns Result: parsing can fail, and we describe the failure.
fn double_from_str(s: &str) -> Result<i32, std::num::ParseIntError> {
    let n: i32 = s.parse()?; // `?` returns Err early on failure
    Ok(n * 2)
}

fn main() {
    // Option with match
    match first_even(&[1, 3, 4, 7]) {
        Some(n) => println!("First even: {}", n),
        None => println!("No even numbers found"),
    }

    // Option with a fallback
    let empty: Vec<i32> = vec![];
    let found = first_even(&empty).unwrap_or(-1);
    println!("Found (or default): {}", found);

    // Result with if let
    if let Ok(value) = double_from_str("21") {
        println!("Doubled: {}", value);
    }

    // Result error case
    match double_from_str("not a number") {
        Ok(value) => println!("Doubled: {}", value),
        Err(e) => println!("Failed to parse: {}", e),
    }
}
```

## ⚖️ `Option` vs `Result`

| Feature                     | `Option<T>`                                  | `Result<T, E>`                                  |
|------------------------------|-----------------------------------------------|--------------------------------------------------|
| Represents                  | Presence or absence of a value                | Success or failure of an operation               |
| Cases                       | `Some(T)`, `None`                             | `Ok(T)`, `Err(E)`                                |
| Carries a reason on the empty case | No — `None` holds no data                | Yes — `Err(E)` carries an error value            |
| Typical use case            | Optional values, lookups, "might be nothing"  | Fallible operations that can explain what failed |
| Replaces                    | `null` / nil references                       | Exceptions / error codes                         |
| `?` operator support        | Yes (in fns returning `Option`)               | Yes (in fns returning `Result`)                  |
| Panic-on-empty methods      | `.unwrap()`, `.expect()`                      | `.unwrap()`, `.expect()`                         |
| Fallback methods            | `.unwrap_or()`, `.unwrap_or_else()`, `.unwrap_or_default()` | `.unwrap_or()`, `.unwrap_or_else()`, `.unwrap_or_default()` |
| Convert between the two     | `.ok_or(err)` → `Result`                      | `.ok()` → `Option` (discards the error)          |
| Helper methods that transform the inner value (no `match` needed) | `.map()`, `.and_then()`, `.filter()`          | `.map()`, `.map_err()`, `.and_then()`            |
| Implements `Copy`           | Only if `T: Copy`                             | Only if `T: Copy` and `E: Copy`                  |
