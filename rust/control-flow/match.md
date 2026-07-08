# 🎯 match

`match` compares a value against a series of **patterns** and runs the arm of the first one that fits. Think of it as a supercharged `switch` that also destructures data and is checked for completeness by the compiler.

```rust
# fn f(value: i32) -> &'static str {
match value {
    pattern1 => expr1,
    pattern2 if guard => expr2, // arm with a match guard
    _ => fallback,              // catch-all
}
# }
```

#### Two properties define `match`:

| Property | What it means |
|----------|---------------|
| **Exhaustive** | The arms together must cover every possible value — leave a case out and it won't compile |
| **An expression** | It produces a value (the chosen arm's), so you can assign the result to a variable |

## 🧩 Patterns you can match on

Patterns are the heart of `match`. A single arm can test a literal, a set of values, a range, or bind the matched value to a name.

```rust
fn main() {
    let n = 7;
    let size = match n {
        0 => "zero",
        1 | 2 | 3 => "small",  // or-pattern: any of these
        4..=9 => "medium",     // inclusive range
        _ => "large",          // catch-all
    };
    println!("{size}");
}
```

> 💡 `@` binds the matched value to a name *while also* testing it: `big @ 4..=10` matches numbers in range and makes them available as `big`.

## 🛡️ Guards refine an arm

A guard is an `if` after the pattern. The arm fires only when the pattern matches **and** the guard is true.

```rust
fn main() {
    let pair = (0, -2);
    let s = match pair {
        (x, y) if x == y => "equal",
        (x, _) if x > 0 => "first positive",
        _ => "other",
    };
    println!("{s}");
}
```

## 🪆 Destructuring

`match` can reach inside tuples, structs, and enums and pull their fields out in the same breath as it matches them.

```rust
struct Point { x: i32, y: i32 }

enum Shape {
    Circle(f64),
    Rect { w: f64, h: f64 },
}

fn area(s: &Shape) -> f64 {
    match s {
        Shape::Circle(r) => std::f64::consts::PI * r * r,
        Shape::Rect { w, h } => w * h,
    }
}

fn main() {
    let p = Point { x: 0, y: 2 };
    match p {
        Point { x: 0, y } => println!("on y axis at {y}"),
        Point { x, .. } => println!("x is {x}"), // .. ignores the rest
    }

    println!("{}", area(&Shape::Circle(1.0)));
}
```

## Gotchas ⚠️

- **A `match` that misses a case won't compile.** You must cover every possible value — add a `_` arm or handle each variant.

  ```rust,compile_fail
  let n: i32 = 3;
  let _ = match n { 1 => "one" }; // error[E0004]: patterns `i32::MIN..=0` and `2..=i32::MAX` not covered
  ```

- **Arms match top-to-bottom, so `_` (and any catch-all) must come last.** An arm after a catch-all is dead code — Rust warns `unreachable pattern` and never runs it.

- **A bare name captures the value; it doesn't compare against one.** `x => ...` matches *everything* and copies the value into a new `x`, so it acts like `_`. To compare against an existing value, use a literal, a named `const`, or a guard (`n if n == target`) — a local variable in the pattern position will not compare.

## Example

```rust
enum Event {
    Click { x: i32, y: i32 },
    Key(char),
    Close,
}

fn describe(e: &Event) -> String {
    match e {
        Event::Click { x, y } if *x == *y => format!("diagonal click at {x},{y}"),
        Event::Click { x, y } => format!("click at {x},{y}"),
        Event::Key(c @ 'a'..='z') => format!("lowercase key {c}"),
        Event::Key(c) => format!("key {c}"),
        Event::Close => "closing".to_string(),
    }
}

fn main() {
    let events = [
        Event::Click { x: 3, y: 3 },
        Event::Click { x: 1, y: 5 },
        Event::Key('r'),
        Event::Key('!'),
        Event::Close,
    ];

    for e in &events {
        println!("{}", describe(e));
    }
}
```

## ⚖️ Table of patterns

| Pattern piece | Example | Matches |
|---------------|---------|---------|
| Literal | `1` | Exactly that value |
| Or-pattern | `1 \| 2 \| 3` | Any listed value |
| Range | `4..=9` | Any value in the inclusive range |
| Binding | `big @ 4..=10` | Range, captured as `big` |
| Guard | `n if n > 0` | Pattern plus an extra condition |
| Catch-all | `_` | Anything (must come last) |

## See also

- [Enums](../types/enums.md)
- [`Result` and `Option`](../types/result-and-option.md)
- [if](./if.md)
