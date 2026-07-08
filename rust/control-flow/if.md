# 🔷 `if` Statement

`if` lets you branch on a **boolean** condition. In Rust, `if` is an *expression* — it produces a value — so you can not only run different code down different paths, you can hand its result straight to a variable.

```rust
if condition {
    // runs when condition is true
} else if other_condition {
    // runs when the first was false and this one is true
} else {
    // runs when nothing above matched
}
```

## 🔹 Conditions are strictly `bool`

The condition must be exactly a `bool`. Rust never treats other values as "truthy" — there is no implicit conversion from integers, options, or pointers. Compare explicitly and you always know what you get.

```rust
fn main() {
    let n = 7;
    if n % 2 == 0 {
        println!("even");
    } else if n % 3 == 0 {
        println!("divisible by 3");
    } else {
        println!("neither");
    }
}
```

> ⚠️ `if 1 { }` and `if some_option { }` both fail to compile. Write the comparison you mean: `if n != 0` or `if some_option.is_some()`.

## 🔹 `if` as a value

Because `if` is an expression, each branch is a block whose **last line is the value it produces**. Assign the whole thing to a variable and you skip the temporary mutable variable dance.

```rust
fn main() {
    let cold = true;
    let temp = if cold { 0 } else { 30 };
    println!("{temp}");
}
```

Two rules make this work:

| Rule | Why |
|------|-----|
| Every branch must produce the **same type** | The variable needs one known type at compile time |
| You need an `else` | A missing branch produces `()`, the empty value, which usually won't match the other branch |

##  🔹`if let` — check one pattern

When you only care about a single pattern, `if let` checks it and pulls out the value inside — no full `match` needed.

```rust
fn main() {
    let opt: Option<i32> = Some(5);
    if let Some(x) = opt {
        println!("got {x}");
    }
}
```

> 💡 `if let` does **not** force you to cover every case; patterns that don't fit fall through to the optional `else`. Reach for `match` when you want the compiler to make you handle every possibility.

##  🔹`let ... else` — bind or bail

`let ... else` (stable since Rust 1.65) pulls a value out of a pattern. If the pattern fits, the bound value stays in scope for the **rest of the function**. If it doesn't fit, the `else` block runs and must leave the current path — `return`, `break`, `continue`, `panic!`, and so on.

```rust
fn first(opt: Option<i32>) -> i32 {
    let Some(y) = opt else {
        return -1;
    };
    y // y is in scope for the rest of the function
}

fn main() {
    println!("{}", first(Some(5)));
    println!("{}", first(None));
}
```

This flattens code that would otherwise nest inside an `if let` block, keeping the happy path un-indented.

## Gotchas ⚠️

- **The condition is `bool` and nothing else.** Other types won't be coerced for you.

  ```rust,compile_fail
  fn main() {
      if 1 { // error[E0308]: mismatched types — expected `bool`, found integer
          println!("nope");
      }
  }
  ```

- **When you use its value, all branches must share a type.**

  ```rust,compile_fail
  fn main() {
      // error[E0308]: `if` and `else` have incompatible types
      let x = if true { 1 } else { "two" };
      println!("{x}");
  }
  ```

- **`if let` skips unmatched cases silently.** Use `match` when exhaustiveness matters.
- **`let ... else` needs Rust ≥ 1.65.** Its `else` block must diverge (leave the path), and the values the pattern binds live in the surrounding code, not inside the `else`.

## Example

```rust
fn classify(opt: Option<i32>) -> String {
    // let ... else: bind on success, bail on failure
    let Some(n) = opt else {
        return "nothing".to_string();
    };

    // if as an expression: each branch yields the same type
    let sign = if n > 0 {
        "positive"
    } else if n < 0 {
        "negative"
    } else {
        "zero"
    };

    format!("{n} is {sign}")
}

fn main() {
    // if let: check one pattern and unwrap it
    if let Some(x) = Some(42) {
        println!("unwrapped {x}");
    }

    println!("{}", classify(Some(7)));
    println!("{}", classify(Some(-3)));
    println!("{}", classify(None));
}
```

## 🖐️ Summary

| Form | Use it when |
|------|-------------|
| `if` / `else if` / `else` | Branch on a boolean, optionally as a value |
| `if let` | Check and unwrap a single pattern |
| `let ... else` | Unwrap a pattern or diverge, keeping the binding in scope |

## See also

- [match](./match.md)
- [Booleans and chars](../basics/bool-char.md)
- [Loop](./loop.md)
