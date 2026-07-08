# `while` loop

Repeat a block **while** a `bool` condition holds — or **while** a pattern keeps matching, with `while let`.

```rust,ignore
while condition {      // condition must be `bool`, re-checked each iteration
    // body
}

while let PATTERN = expr {   // loop until `expr` stops matching PATTERN
    // body
}
```

## Condition-driven looping

`while` checks the condition *before* every pass and stops the moment it's false. Use it when the loop is steered by some state you keep testing.

```rust
fn main() {
    let mut n = 3;
    while n > 0 {
        println!("{n}"); // 3, then 2, then 1
        n -= 1;
    }
}
```

> 💡 Use `break` to bail out early and `continue` to jump straight to the next condition check.

```rust
fn main() {
    let mut i = 0;
    while i < 10 {
        i += 1;
        if i % 2 == 0 { continue; } // skip evens
        if i > 7 { break; }         // stop once past 7
        println!("{i}");
    }
}
```

## while let

`while let` keeps looping as long as the value still matches the pattern — perfect for draining a collection with `.pop()`:

```rust
fn main() {
    let mut stack = vec![1, 2, 3];
    while let Some(top) = stack.pop() {
        println!("{top}"); // pops from the top: 3, then 2, then 1
    }
}
```

> ⚠️ `while let` stops at the **first** value that fails to match, then falls through to the code after the loop. It won't skip a non-matching item and keep going.

## 🧭 Which loop?

| Reach for       | When                                                    |
|-----------------|---------------------------------------------------------|
| `while`         | The loop is driven by a condition you check up front    |
| `loop { break }`| The body must run at least once, or you need `break value` |
| `for`           | You're iterating a known range or collection            |

## Gotchas ⚠️

> ⚠️ **The condition must be exactly `bool`.** Rust never treats other values as "truthy": `while 1 { }` or `while some_option { }` won't compile. Write `while n != 0`, or use `while let`.

> ⚠️ **Easy to spin forever.** If nothing in the body changes what the condition tests (e.g. you forget `n -= 1`), the loop never ends.

## Example

```rust
fn main() {
    // Condition-driven: spend a balance until it runs low.
    let mut balance = 100;
    while balance >= 30 {
        balance -= 30;
    }
    println!("leftover balance: {balance}");

    // break / continue to shape the flow.
    let mut i = 0;
    while i < 10 {
        i += 1;
        if i % 2 == 0 { continue; } // skip evens
        if i > 7 { break; }         // stop once past 7
        println!("odd and small: {i}");
    }

    // while let drains a stack until pop() returns None.
    let mut stack = vec!["a", "b", "c"];
    while let Some(top) = stack.pop() {
        println!("popped {top}");
    }
}
```

## See also

- [Loop](./loop.md)
- [for](./for.md)
- [match](./match.md)
