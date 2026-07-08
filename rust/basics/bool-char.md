# ⭐ `bool` and `char`

Rust has two simple scalar types for representing single logical values and single characters: `bool` and `char`. Both have a fixed, known size and are copied by value rather than moved.

## `bool`

`bool` represents a truth value and has exactly two possible values: `true` or `false`. It occupies **1 byte** in memory and is most commonly used in conditionals, loops, and logical expressions.

## `char`

`char` represents a single **Unicode scalar value**, not just an ASCII character. Because of this, it's **4 bytes** in size — large enough to hold any Unicode code point, including emoji, accented letters, and characters from non-Latin alphabets. `char` literals are written with single quotes (`'a'`), as opposed to `String`/`&str` literals, which use double quotes (`"a"`).

## ⭐ Example

```rust
fn main() {
    // bool: exactly true or false
    let is_active: bool = true;
    let is_finished = false; // type inferred as bool

    if is_active && !is_finished {
        println!("Task is active and not finished.");
    }

    // char: a single Unicode scalar value, 4 bytes
    let letter: char = 'R';
    let emoji: char = '🦀'; // valid! chars aren't limited to ASCII
    let accented: char = 'é';

    println!("Letter: {}", letter);
    println!("Emoji: {}", emoji);
    println!("Accented: {}", accented);

    // Useful char methods
    println!("Is '{}' alphabetic? {}", letter, letter.is_alphabetic());
    println!("Is '{}' a digit? {}", letter, letter.is_numeric());
    println!("Uppercase of 'r': {}", 'r'.to_uppercase().next().unwrap());

    // bool from a comparison
    let x = 10;
    let y = 20;
    let is_greater: bool = x > y;
    println!("Is x > y? {}", is_greater);
}
```

## ⚖️ Feature Comparison

| Feature                     | `bool`                                    | `char`                                          |
|------------------------------|---------------------------------------------|---------------------------------------------------|
| Represents                  | A truth value                              | A single Unicode scalar value                     |
| Possible values             | `true` or `false` only                     | Any valid Unicode code point                      |
| Size in memory              | 1 byte                                     | 4 bytes                                           |
| Literal syntax               | `true` / `false`                           | Single quotes, e.g. `'a'`, `'🦀'`                  |
| ASCII-only?                 | N/A                                        | No — supports full Unicode, not just ASCII        |
| Common use case             | Conditionals, flags, loop control          | Representing individual characters, iterating over `chars()` |
| Implements `Copy`           | Yes                                        | Yes                                                |
| Logical operators           | `&&`, `\|\|`, `!`                            | N/A                                                |
| Common methods              | N/A (rarely has methods called on it)      | `.is_alphabetic()`, `.is_numeric()`, `.to_uppercase()`, `.to_lowercase()` |
| Relationship to strings     | N/A                                        | A `String`/`&str` is a sequence of UTF-8 encoded `char`s (though iteration isn't always 1:1 due to multi-byte encoding) |

