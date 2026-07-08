# 🎲 Enums

An **enum** is a type whose value is exactly one of a fixed set of named cases. Rust calls each case a **variant**, and the best part is that every variant can carry its own data — from nothing at all to a full struct's worth.

```rust
enum Shape {
    Circle,                    // no data (a "unit" variant)
    Rectangle(f64, f64),       // tuple data
    Text { content: String },  // struct-like data
}
```

> 💡 Think of an enum as a labeled box that can hold exactly one of several shapes at a time. The label tells you which shape is inside, and the compiler makes sure you check the label before you reach in.

## Defining and using variants

Each variant's name lives *inside* the enum, so you reach it with `EnumName::Variant`. Pair an enum with a `match` to react to whichever variant you're holding:

```rust
enum Direction { North, South, East, West }

fn main() {
    let heading = Direction::East;
    let label = match heading {
        Direction::North => "up",
        Direction::South => "down",
        Direction::East => "right",
        Direction::West => "left",
    };
    println!("{label}");
}
```

## Variants that carry data

This is where enums shine. A variant can bundle data, and `match` (or `if let`) pulls that data back out. Add behavior with an `impl` block, just like a struct:

```rust
enum Shape {
    Circle(f64),
    Rectangle(f64, f64),
}

impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle(r) => std::f64::consts::PI * r * r,
            Shape::Rectangle(w, h) => w * h,
        }
    }
}

fn main() {
    let s = Shape::Rectangle(3.0, 4.0);
    println!("{}", s.area());

    // `if let` when you only care about one variant:
    if let Shape::Circle(r) = s {
        println!("radius {r}");
    }
}
```

> 💡 Reach for `if let` when you care about a single variant and want to ignore the rest. Reach for `match` when you want the compiler to make sure you've considered every case.

## The catch-all `_`

Don't want to spell out every remaining variant? Use `_` as a wildcard arm that soaks up everything you didn't name:

```rust
enum Coin { Penny, Nickel, Dime, Quarter }

fn value(c: Coin) -> u8 {
    match c {
        Coin::Quarter => 25,
        _ => 1, // handles Penny, Nickel, and Dime
    }
}
```

## 🔗 Enums you already use

`Option<T>` and `Result<T, E>` from the standard library are *just enums* — `Some`/`None` and `Ok`/`Err` are their variants. See [`Result` and `Option`](./result-and-option.md) for the full tour.

- **Qualify your variant names.** Write `Direction::North`, not bare `North`. Want the short form? Bring the names into scope with `use Direction::*;`.
- **Don't reach for `_` too eagerly.** When you later add a variant, an explicit `match` forces you to handle it — but a `_` arm silently swallows it, hiding bugs.
- **Size and memory.** An enum is as large as its biggest variant, plus a small hidden tag that records which variant a value currently holds. So every value takes the same amount of space regardless of which variant is active. The compiler can sometimes drop that tag entirely — for example, `Option<&T>` is the size of a single pointer, because a reference can never be null.

## Example

```rust
// A tiny expression tree, built entirely from one enum.
enum Expr {
    Number(f64),
    Add(Box<Expr>, Box<Expr>),
    Mul(Box<Expr>, Box<Expr>),
    Negate(Box<Expr>),
}

impl Expr {
    // Walk the tree and compute a value for each variant.
    fn eval(&self) -> f64 {
        match self {
            Expr::Number(n) => *n,
            Expr::Add(a, b) => a.eval() + b.eval(),
            Expr::Mul(a, b) => a.eval() * b.eval(),
            Expr::Negate(inner) => -inner.eval(),
        }
    }
}

fn main() {
    // Represents: -(2 + 3) * 4
    let expr = Expr::Mul(
        Box::new(Expr::Negate(Box::new(Expr::Add(
            Box::new(Expr::Number(2.0)),
            Box::new(Expr::Number(3.0)),
        )))),
        Box::new(Expr::Number(4.0)),
    );

    println!("Result: {}", expr.eval());

    // `if let` to peek at just one variant:
    if let Expr::Mul(_, right) = &expr {
        println!("Right operand evaluates to {}", right.eval());
    }
}
```

## See also

- [`Result` and `Option`](./result-and-option.md)
- [match](../control-flow/match.md)
- [Structs](./structs.md)
