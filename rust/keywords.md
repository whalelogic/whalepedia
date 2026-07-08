# The Pragmatic Rust Syntax & Keyword Reference

## Part 1: Symbols and Operators

| Symbol | Name | Description / Use Case | Example |
| :--- | :--- | :--- | :--- |
| `!` | Macro / Not | 1. Logic NOT. 2. Suffix for macro invocation. 3. "Never" return type. | `println!()`, `!true`, `-> !` |
| `?` | Try Operator | Unwraps `Result` or `Option`. Returns error/None to caller on failure. | `let f = File::open("a.txt")?;` |
| `.` | Member Access | Accesses fields of a struct or methods of a trait/impl. | `person.name`, `vec.len()` |
| `..` | Range (Exclusive) | Creates a range from start to up-to-but-not-including end. | `1..10` (1 to 9) |
| `..=` | Range (Inclusive) | Creates a range including the end value. | `1..=10` (1 to 10) |
| `..` | Functional Update | In struct literals, copies remaining fields from another instance. | `User { email, ..user1 }` |
| `::` | Path Separator | Accesses items in modules, namespaces, or associated functions. | `std::io::stdin()`, `Vec::new()` |
| `::<_>` | Turbofish | Provides explicit type arguments to a generic function/method. | `collect::<Vec<i32>>()` |
| `&` | Reference / And | 1. Bitwise AND. 2. Create an immutable reference (borrow). | `let x = &y;`, `5 & 1` |
| `&mut` | Mutable Borrow | Creates a unique mutable reference to a value. | `let x = &mut y;` |
| `*` | Dereference / Mult | 1. Multiplication. 2. Follow a pointer/reference to its value. | `let val = *reference;` |
| `_` | Wildcard / Ignore | 1. Pattern match catch-all. 2. Ignore variable binding. | `let _ = hide_me();`, `match { _ => ... }` |
| `,` | Separator | Separates arguments, elements in arrays/vecs, or struct fields. | `fn(a: i32, b: i32)` |
| `;` | Terminator | Ends a statement. If omitted at end of function, returns expression. | `let x = 5;` |
| `:` | Type Ascription | Associates a name with a specific type. | `let x: i32 = 5;` |
| `->` | Return Arrow | Denotes the return type of a function or closure. | `fn add() -> i32` |
| `=>` | Match Arm | Separates a match pattern from the resulting expression. | `Some(x) => println!(x)` |
| `&'a` | Lifetime | Explicitly labels how long a reference must remain valid. | `&'a str`, `fn foo<'a>(...)` |
| `<T>` | Generics | Declares or uses a generic type parameter `T`. | `struct Box<T> { ... }` |
| `{:?}` | Debug Format | Format specifier for the `Debug` trait (printing internals). | `println!("{:?}", vec);` |
| `{:#?}` | Pretty Debug | Format specifier for multi-line, indented debug printing. | `println!("{:#?}", complex_struct);` |
| `|...|` | Closure | Defines parameters for an anonymous function (lambda). | `let c = |x, y| x + y;` |
| `[...]` | Array / Slice | Declares array types or accesses indices. | `let a: [i32; 3]`, `vec[0]` |
| `(...)` | Tuple / Group | 1. Group expressions. 2. Declare tuples. 3. Call functions. | `let t = (1, "hi");` |
| `{...}` | Block / Scope | Defines a scope or a struct/enum body. Expressions return last value. | `let x = { 5 };` |

## Part 2: Keywords and Reserved Terms

| Keyword | Definition | Practical Usage |
| :--- | :--- | :--- |
| `as` | Casting | Perform primitive casting or rename imports. `x as u64`, `use std::io as bio;` |
| `break` | Exit Loop | Break out of a loop (can also return a value from `loop`). `break 5;` |
| `const` | Constant | Compile-time constant with a mandatory type. `const MAX: u32 = 100;` |
| `continue` | Skip | Skip the rest of the current loop iteration. |
| `crate` | Root Module | Refers to the root of the current crate. |
| `dyn` | Dynamic Dispatch | Indicates a trait object (vtable lookup at runtime). `&dyn MyTrait` |
| `else` | Fallback | Defines the fallback block for an `if` expression. |
| `enum` | Enumeration | Defines a type that can be one of several variants. |
| `extern` | FFI | Links to external libraries or defines C-calling conventions. |
| `fn` | Function | Declares a function or a function pointer type. |
| `for` | Loop | Iterates over an iterator. `for x in 0..5 { ... }` |
| `if` | Conditional | Branching expression. Returns a value if used as an expression. |
| `impl` | Implementation | Implements methods or traits for a struct or enum. |
| `in` | Part of `for` | Used in `for` loops to specify the collection/range. |
| `let` | Binding | Binds a value to a variable name. |
| `loop` | Infinite Loop | Unconditional loop. Useful for retries or long-running tasks. |
| `match` | Pattern Match | Exhaustive branching based on pattern matching. |
| `mod` | Module | Declares or defines a module. |
| `move` | Capture by Value | Forces a closure to take ownership of captured variables. |
| `mut` | Mutable | Allows a variable or reference to be modified. |
| `pub` | Public | Makes a module, struct, or function visible outside its parent. |
| `ref` | By Reference | Used in patterns to bind by reference rather than moving. |
| `return` | Return | Returns a value from a function early. |
| `Self` | Self Type | The type being implemented (inside an `impl` block). |
| `self` | Self Instance | The instance being operated on (method receiver). |
| `static` | Global | Global variable with a `'static` lifetime. |
| `struct` | Structure | Defines a custom data type with fields. |
| `trait` | Interface | Defines shared behavior that types can implement. |
| `type` | Alias | Creates a new name for an existing type. `type Bytes = Vec<u8>;` |
| `unsafe` | Unsafe | Opts into features the compiler can't verify (raw pointers, etc). |
| `use` | Import | Brings a path into the current scope. |
| `where` | Constraints | Defines complex generic bounds at the end of a signature. |
| `while` | Loop while | Conditional loop. `while x < 5 { ... }` |

## Part 3: Common Standard Types & Enums

| Term | Context | Description |
| :--- | :--- | :--- |
| `Option<T>` | Enum | Represents a value that might be missing (`Some(T)` or `None`). |
| `Result<T, E>` | Enum | Represents success (`Ok(T)`) or failure (`Err(E)`). |
| `Some(v)` | Variant | Part of `Option`. Wraps an existing value. |
| `None` | Variant | Part of `Option`. Represents the absence of value. |
| `Ok(v)` | Variant | Part of `Result`. Represents a successful operation. |
| `Err(e)` | Variant | Part of `Result`. Represents a failed operation. |
| `Vec<T>` | Struct | A growable, heap-allocated array (Vector). |
| `String` | Struct | A heap-allocated, UTF-8 encoded string. |
| `&str` | Type | A string slice (reference to string data). |
| `Box<T>` | Struct | A pointer for heap allocation. |

## Part 4: Practical Syntax Examples

### 1. The Turbofish and Collect
```rust
// split returns an iterator. collect needs to know the destination type.
let items = "apple,banana,cherry"
    .split(',')
    .collect::<Vec<&str>>();