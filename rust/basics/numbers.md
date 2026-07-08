# Numeric Types ❶ ❷ ❸ 

Rust is a statically-typed language with a rich set of built-in numeric types, split into **integers** and **floating-point numbers**. The size and signedness of each type is baked into its name, giving you precise control over memory usage and behavior.

## Integers

Integers are whole numbers, and can be either **signed** (can be negative) or **unsigned** (zero or positive only). The number in the type name is the number of bits it occupies in memory.

| Signed  | Unsigned | Bits |
|---------|----------|------|
| `i8`    | `u8`     | 8    |
| `i16`   | `u16`    | 16   |
| `i32`   | `u32`    | 32   |
| `i64`   | `u64`    | 64   |
| `i128`  | `u128`   | 128  |
| `isize` | `usize`  | arch-dependent (32 or 64) |

`i32` is Rust's default integer type — if you don't annotate a type and Rust can't infer otherwise, it will choose `i32`.

## Floating-Point Numbers

Floating-point types represent numbers with a decimal point, following the IEEE-754 standard.

| Type  | Bits | Precision       |
|-------|------|-----------------|
| `f32` | 32   | Single precision |
| `f64` | 64   | Double precision |

`f64` is Rust's default floating-point type, since on modern CPUs it's roughly as fast as `f32` but offers more precision.

## ⭐ Example

```rust
fn main() {
    // Integers: default type is i32
    let default_int = 42;
    let explicit_u8: u8 = 255; // max value for u8
    let big_number: i64 = 9_000_000_000; // underscores improve readability

    // Floating-point: default type is f64
    let default_float = 3.14;
    let explicit_f32: f32 = 2.5;

    // usize is commonly used for indexing collections
    let vec = vec![10, 20, 30];
    let index: usize = 1;
    println!("Element at index {}: {}", index, vec[index]);

    // Integer overflow: this would panic in debug mode
    let max_u8: u8 = u8::MAX;
    let wrapped = max_u8.wrapping_add(1); // explicitly handle overflow
    println!("255 wrapped + 1 = {}", wrapped);

    // Basic arithmetic and type checking
    let sum = default_int as f64 + default_float; // explicit cast required
    println!("Sum: {}", sum);

    println!("u8: {}, i64: {}, f32: {}", explicit_u8, big_number, explicit_f32);
}
```

## ⚖️ Feature Comparison

| Feature                     | Integers (`i32`, `u8`, etc.)                | Floats (`f32`, `f64`)                     |
|------------------------------|-----------------------------------------------|---------------------------------------------|
| Represents                  | Whole numbers                                | Numbers with a fractional/decimal component |
| Default type                | `i32`                                        | `f64`                                       |
| Signed variants              | Yes (`i8`–`i128`, `isize`)                   | Always signed                               |
| Unsigned variants             | Yes (`u8`–`u128`, `usize`)                   | No unsigned floats                          |
| Overflow behavior (debug)   | Panics                                       | No panic — produces `inf`/`NaN`             |
| Overflow behavior (release) | Wraps silently (two's complement)            | No panic — produces `inf`/`NaN`             |
| Explicit overflow handling  | `wrapping_*`, `checked_*`, `saturating_*`, `overflowing_*` | N/A (IEEE-754 handles special cases)        |
| Common use case             | Counting, indexing, IDs, bit manipulation    | Measurements, scientific calculations, graphics |
| Implements `Eq` / `Ord`     | Yes (exact comparison)                       | No — only `PartialEq` / `PartialOrd` (due to `NaN`) |
| Casting between types       | Explicit via `as` (may truncate/wrap)        | Explicit via `as` (may lose precision)      |
| Arch-dependent size         | `isize` / `usize` only                       | None — sizes are fixed                      |
