# 🧬 Rust Generics

Generics let you **write your code once** using a stand-in name like `T` for the type, and the compiler fills in a real version for each actual type you use it with. That stand-in name is called a *type parameter*.

```rust
// Generic function: `T` is a type parameter.
fn first<T>(slice: &[T]) -> &T { &slice[0] }

// Generic struct: `T` fills in when you construct it.
struct Wrapper<T> { value: T }
```

> 💡 Think of `T` as a blank you promise to fill in. One definition, many concrete types — no copy-paste, no duplication.

## Bounds: teaching `T` new tricks

A type parameter like `T` could be **anything**, so on its own you can't do much with it. To use an operation on it, you promise that the type actually supports that operation. That promise is called a *bound*.

Here `T: PartialOrd` means "`T` is something you can compare with `>`":

```rust
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut biggest = &list[0];
    for item in list {
        if item > biggest { biggest = item; } // `>` needs `PartialOrd`
    }
    biggest
}
```

You can require **several promises at once** with `+`, and a `where` clause moves those promises below the signature to keep it readable.

```rust
use std::fmt::{Debug, Display};

// Inline bounds with `+`.
fn show<T: Display + Clone>(x: T) { println!("{}", x.clone()); }

// Same idea, moved into a `where` clause for readability.
fn dump<T, U>(a: T, b: U)
where
    T: Debug + Clone,
    U: Debug,
{
    println!("{:?} {:?}", a.clone(), b);
}
```

## Generic structs and impl blocks

A generic struct can carry its type parameter into an `impl` block. The `<T>` after `impl` **declares the parameter for the whole block**, and you can add extra bounds only where they're needed.

```rust
struct Point<T> { x: T, y: T }

// `<T>` after `impl` declares the parameter; `T: Copy` bounds the whole block.
impl<T: Copy> Point<T> {
    fn x(&self) -> T { self.x }
}

// A method available only for a specific concrete type.
impl Point<f64> {
    fn dist_from_origin(&self) -> f64 { (self.x * self.x + self.y * self.y).sqrt() }
}
```

## Gotchas ⚠️

> ⚠️ **A bare `T` has no powers.** A plain `T` could be anything, so Rust won't let you use `>` or `+` on it until you promise the type supports it. State the bound (`T: PartialOrd` for `>`, `T: Add` for `+`, and so on). Without it, the code won't compile:

```rust,compile_fail
fn add<T>(a: T, b: T) -> T { a + b } // error: `T` might not implement `Add`
```

> 🐟 **The turbofish.** Usually Rust figures out the type from how you use a value. When it can't, you spell it out with the `::<>` syntax — nicknamed the *turbofish*:

```rust
let n = "42".parse::<i32>().unwrap();   // annotate the parsed type
let v = (0..3).collect::<Vec<i32>>();   // annotate the collected type
println!("{n} {v:?}");
```

> ⚠️ **Monomorphization has a cost.** When you use a generic with several real types, the compiler makes a **separate compiled copy** of the code for each type. That's why generics cost nothing at runtime — each copy calls the right code directly, as fast as hand-written code, and the compiler can even inline it. The downside: lots of copies grow the binary and slow down builds. If you'd rather have just *one* copy, use `&dyn Trait` or `Box<dyn Trait>` instead. With `dyn`, the program looks up the right code at runtime — a tiny speed cost, but a smaller program.

## Static vs. dynamic dispatch

| | **Generics** (`<T>`) | **Trait objects** (`dyn Trait`) |
|---|---|---|
| Dispatch | Static (resolved at compile time) | Dynamic (resolved at runtime) |
| How it works | Monomorphization: one compiled copy per type | One copy, looked up via a vtable |
| Runtime speed | Fastest; can be inlined | Slight indirection cost |
| Binary size | Grows with each type used | Stays small |
| Build time | Slower (more code to compile) | Faster |
| Trade-off | **Size for speed** | **Speed for size** |

## Example

```rust
use std::fmt::Display;

// Generic function with a bound: works for any comparable type.
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut biggest = list[0];
    for &item in list {
        if item > biggest { biggest = item; }
    }
    biggest
}

// Generic struct plus a generic method.
struct Pair<T> { first: T, second: T }

impl<T: Display + PartialOrd> Pair<T> {
    fn larger(&self) -> &T {
        if self.first >= self.second { &self.first } else { &self.second }
    }
}

fn main() {
    // Same code, different concrete types.
    println!("{}", largest(&[3, 7, 2, 9, 4]));
    println!("{}", largest(&['a', 'z', 'm']));

    let nums = Pair { first: 5, second: 12 };
    let words = Pair { first: "apple", second: "pear" };
    println!("larger number: {}", nums.larger());
    println!("larger word: {}", words.larger());

    // Turbofish: tell the compiler which type to produce.
    let parsed = "255".parse::<u8>().unwrap();
    let collected = (0..3).collect::<Vec<i32>>();
    println!("{parsed} {collected:?}");
}
```

## See also

- [Traits](./traits.md)
- [Structs](./structs.md)
- [Enums](./enums.md)
