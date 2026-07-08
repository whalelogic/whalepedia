## 🗚  Strings in Rust

In Rust, strings are a fundamental data type used to represent text. There are two main types of strings in Rust: `String` and `&str`. Understanding the differences between these types and how to use them effectively is crucial for writing efficient and safe Rust code.

# `String` vs `&str`

> I love strings!

Rust has two primary types for working with text: `String` and `&str`. Understanding the difference between them is fundamental to working with ownership and borrowing in Rust.

## `String`

`String` is a **growable, heap-allocated, owned** UTF-8 encoded string type. Because it owns its data, a `String` can be mutated, resized, and will be cleaned up (its memory freed) when it goes out of scope.

Use `String` when you need to:
- Own the text data
- Modify or build the string at runtime
- Return a string from a function

## `&str`

`&str` (pronounced "string slice") is an **immutable reference** to a sequence of UTF-8 bytes stored somewhere else — either inside a `String`, or hardcoded into the binary as a string literal. `&str` does not own the data it points to; it just borrows a view into it.

Use `&str` when you need to:
- Reference or read text without owning it
- Accept string data flexibly as a function parameter
- Work with string literals

## ⭐ Example

```rust
fn main() {
    // `String`: owned, mutable, heap-allocated
    let mut owned: String = String::from("Hello");
    owned.push_str(", world!"); // mutation is possible because we own the data

    // `&str`: a string literal, stored in the binary, borrowed as a slice
    let borrowed: &str = "Hello, world!";

    // A `&str` can also be created by borrowing (slicing) a `String`
    let slice_of_owned: &str = &owned[..5]; // borrows "Hello" from `owned`

    println!("String:  {}", owned);
    println!("&str:    {}", borrowed);
    println!("Slice:   {}", slice_of_owned);

    // Function that borrows a &str, so it works with both types
    print_length(&owned);   // &String auto-derefs to &str
    print_length(borrowed); // already a &str
}

fn print_length(s: &str) {
    println!("Length: {}", s.len());
}
```

## ⚖️ Feature Comparison

| Feature                     | `String`                                   | `&str`                                      |
|------------------------------|---------------------------------------------|----------------------------------------------|
| Ownership                   | Owned                                       | Borrowed (reference)                          |
| Mutability                  | Mutable (if declared `mut`)                 | Immutable                                     |
| Storage location            | Heap                                        | Stack, heap, or binary (depends on source)    |
| Size known at compile time  | No (growable)                               | No (but the reference itself is a fat pointer: ptr + length) |
| Can be resized/appended to  | Yes (`push`, `push_str`, `+=`)              | No                                            |
| Common creation methods     | `String::from()`, `.to_string()`, `String::new()` | String literals (`"text"`), slicing a `String` (`&s[..]`) |
| Typical use case            | Building, storing, or owning text long-term | Reading, borrowing, or passing text efficiently |
| Function parameter idiom    | Avoid — prefer `&str` for flexibility       | Preferred parameter type for reading strings  |
| Deref coercion              | `&String` auto-coerces to `&str`            | N/A                                           |
| Memory cleanup              | Freed automatically when it goes out of scope (via `Drop`) | No cleanup needed — doesn't own memory        |

