# 🔁 for

`for` walks through anything you can loop over — ranges, arrays, vectors, and more — handing you one item at a time until there are none left.

```rust,ignore
for pattern in iterable {
    // body runs once per item
}
```

Under the hood a `for` loop just keeps asking the thing for its next item; the loop ends when there is no next item (`next()` returns `None`).

## 📐 Ranges

Ranges are the quickest thing to loop over:

| Range     | Reads as                        | Includes `n`? |
|-----------|---------------------------------|:-------------:|
| `0..n`    | 0 up to but *not* including `n` | ❌ |
| `0..=n`   | 0 up through `n`                | ✅ |

```rust
fn main() {
    for i in 0..3 {
        println!("{i}"); // 0, then 1, then 2
    }
}
```

> ⚠️ `0..n` stops at `n - 1`. Reach for `0..=n` when you actually need `n` in the loop.

## 🎯 Ways to loop over a collection

How you write the loop decides what you get and whether the collection survives.

| You write               | Each item is | Collection after the loop |
|-------------------------|--------------|---------------------------|
| `for x in &v`           | `&T` (borrow)     | still usable ✅ |
| `for x in v.iter_mut()` | `&mut T` (edit)   | still usable ✅ |
| `for x in v`            | `T` (owned)       | moved away ❌ |

```rust
fn main() {
    let v = vec![10, 20, 30];

    // By reference: borrow, so v stays usable afterward.
    for x in &v {              // x: &i32  (same as v.iter())
        println!("{x}");
    }
    println!("still have {} items", v.len());

    // Mutate each element in place.
    let mut nums = vec![1, 2, 3];
    for n in nums.iter_mut() { // n: &mut i32
        *n *= 2;
    }

    // Index + value together with .enumerate().
    for (i, x) in v.iter().enumerate() {
        println!("{i}: {x}");
    }
}
```

> 💡 Arrays and slices iterate exactly like vectors — `for x in &arr` or `for x in slice` both hand you `&T`.

## Gotchas ⚠️

> ⚠️ **Looping by value consumes the collection.** `for x in v` gives the loop ownership and uses `v` up, so it's gone afterward. Borrow with `&v` (or `v.iter()`) to keep it.

```rust,compile_fail
fn main() {
    let v = vec![1, 2, 3];
    for x in v {               // moves v; x is i32
        println!("{x}");
    }
    println!("{}", v.len());   // ERROR[E0382]: v moved by the loop
}
```

> ⚠️ **You can't change a collection while looping over it.** The loop is already borrowing it, so Rust rejects a mutation mid-flight. Collect the indices or changes into a separate `Vec` and apply them after the loop.

```rust,compile_fail
fn main() {
    let mut v = vec![1, 2, 3];
    for x in &v {
        v.push(*x);            // ERROR[E0502]: cannot borrow v as mutable
    }                          //               while it is borrowed by the loop
}
```

## Example

```rust
fn main() {
    // Range with an inclusive end.
    println!("counting to 5:");
    for i in 1..=5 {
        println!("  {i}");
    }

    // Borrow a vector, pairing each value with its index.
    let colors = vec!["red", "green", "blue"];
    for (i, color) in colors.iter().enumerate() {
        println!("{i}: {color}");
    }
    println!("{} colors, all still here", colors.len());

    // Mutate every element in place.
    let mut scores = vec![10, 20, 30];
    for s in scores.iter_mut() {
        *s += 5;
    }
    println!("adjusted scores: {scores:?}");
}
```

## See also

- [while](./while.md)
- [Loop](./loop.md)
- [Vectors](../basics/vectors.md)
- [Slices](../basics/slices.md)
