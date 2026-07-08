# ♾️ loop

`loop` runs its body forever — until you `break` out of it.

```rust,ignore
loop {
    // runs until a break is hit
    break;
}
```

## 🎁 loop is an expression

`loop` produces a value, so `break value` becomes the loop's result and you can assign it straight to a variable:

```rust
fn main() {
    let mut i = 0;
    let x = loop {
        i += 1;
        if i * i > 20 {
            break i; // this value becomes x
        }
    };
    println!("{x}");
}
```

> 💡 `break value` is a `loop`-only superpower. A `while`/`for` `break` can't carry a value — those loops always produce `()`.

## 🏷️ Labeled loops

Give a loop a `'name:` label to `break` or `continue` an *outer* loop from inside a nested one:

```rust
fn main() {
    'outer: for a in 0..3 {
        for b in 0..3 {
            if a + b == 3 {
                break 'outer; // exits both loops at once
            }
            println!("{a}, {b}");
        }
    }
}
```

`continue 'label` jumps back to the top of the labeled loop instead of the innermost one:

```rust
fn main() {
    let mut count = 0;
    'outer: for a in 0..3 {
        for b in 0..3 {
            if b == 1 {
                continue 'outer; // restart the outer loop
            }
            count += a + b;
        }
    }
    println!("{count}");
}
```

## Gotchas ⚠️

> ⚠️ **A bare `loop {}` never returns.** Without a `break` (or `return`/`panic!`) it spins forever.

> ⚠️ **`break value` only works in `loop`.** In `while`/`for`, `break` can't carry a value; those loops always produce `()`, the empty value.

> ⚠️ **Labels use the leading-tick syntax** and must sit right before the loop keyword: `'outer: loop`, not `outer: loop`. A `break`/`continue` label always names a loop (`'outer`) — never a variable.

## Example

```rust
fn main() {
    // loop as an expression: break out with a value.
    let mut i = 0;
    let first_big_square = loop {
        i += 1;
        if i * i > 20 {
            break i * i; // the loop evaluates to this
        }
    };
    println!("first square over 20: {first_big_square}");

    // Labeled loops: stop the whole nest from deep inside.
    'search: for row in 0..3 {
        for col in 0..3 {
            if row + col == 3 {
                println!("found target at {row}, {col}");
                break 'search;
            }
        }
    }
}
```

## See also

- [while](./while.md)
- [for](./for.md)
