# 🛰️ Tuples and Arrays 

Rust has two built-in **compound types** that let you group multiple values together: tuples and arrays. Both have a **fixed length** known at compile time, but they differ in how they handle types and how you access their elements.

## Tuples

A tuple groups together a fixed number of values of **potentially different types** into one compound value. Once declared, a tuple's length cannot grow or shrink. Elements are accessed either by **destructuring** or by a dot followed by their index (e.g. `.0`).

## Arrays 

An array is a fixed-length collection where **every element must be the same type**. Unlike tuples, arrays are commonly used when you want to iterate over elements or guarantee data is allocated on the stack. Arrays cannot grow or shrink — for a growable collection, you'd reach for `Vec<T>` instead.

## ✨ Example

```rust
fn main() {
    // Tuple: fixed length, mixed types allowed
    let person: (&str, i32, bool) = ("Alice", 30, true);

    // Access by index
    println!("Name: {}, Age: {}, Active: {}", person.0, person.1, person.2);

    // Destructuring a tuple
    let (name, age, is_active) = person;
    println!("Destructured -> {} is {} years old", name, age);

    // The unit type (): an empty tuple, often used as a "no value" return type
    let unit: () = ();

    // Array: fixed length, single type
    let numbers: [i32; 5] = [1, 2, 3, 4, 5];

    // Array with repeated values: [value; count]
    let zeros: [i32; 3] = [0; 3];

    // Accessing array elements by index
    println!("First number: {}", numbers[0]);

    // Iterating over an array
    for n in numbers.iter() {
        print!("{} ", n);
    }
    println!();

    // Arrays have a fixed size enforced at compile time
    println!("Array length: {}", numbers.len());
    println!("Zeros: {:?}", zeros);

    let _ = is_active;
    let _ = unit;
}
```

## Feature Comparison

| Feature                     | Tuple                                      | Array                                        |
|------------------------------|-----------------------------------------------|--------------------------------------------|
| Element types                | Can mix different types                     | All elements must be the same type          |
| Length                       | Fixed at compile time                       | Fixed at compile time                       |
| Type annotation              | `(T1, T2, T3, ...)`, e.g. `(i32, bool)`     | `[T; N]`, e.g. `[i32; 5]`                    |
| Access method                | Dot + index (`.0`, `.1`) or destructuring   | Square brackets (`[0]`, `[1]`)              |
| Iterable with `.iter()`      | No (not directly — types may differ)        | Yes                                          |
| Growable                     | No                                          | No                                          |
| Storage location              | Stack (unless it contains heap types)       | Stack (unless it contains heap types)       |
| Common use case               | Returning multiple values from a function, grouping unrelated data | Fixed-size collections of the same type, e.g. buffers, coordinates |
| Special case                  | `()` — the "unit type", represents an empty/no value | N/A                                          |
| Implements `Copy`             | Yes, if all elements implement `Copy`       | Yes, if the element type implements `Copy`  |

---

# `Vec<T>`

`Vec<T>` (pronounced "vector") is a **growable, heap-allocated** list of values, all of the same type `T`. It's one of the most commonly used collection types in Rust — think of it as the dynamic counterpart to a fixed-size array. Like `String`, a `Vec<T>` owns its data and will free its memory automatically when it goes out of scope.

## Example

```rust
fn main() {
    // Creating a Vec explicitly
    let mut numbers: Vec<i32> = Vec::new();
    numbers.push(1);
    numbers.push(2);
    numbers.push(3);

    // Creating a Vec with the vec! macro
    let fruits = vec!["apple", "banana", "cherry"];

    println!("Numbers: {:?}", numbers);
    println!("Fruits: {:?}", fruits);

    // Accessing elements
    println!("First fruit: {}", fruits[0]);

    // Safe access with .get() (returns Option<&T>)
    match numbers.get(10) {
        Some(n) => println!("Found: {}", n),
        None => println!("No element at index 10"),
    }

    // Iterating and mutating
    for n in numbers.iter_mut() {
        *n *= 10;
    }
    println!("Doubled: {:?}", numbers);

    // Removing the last element
    let popped = numbers.pop();
    println!("Popped: {:?}, Remaining: {:?}", popped, numbers);

    // Length and capacity
    println!("Length: {}, Is empty? {}", numbers.len(), numbers.is_empty());
}
```

## ⚖️ Feature Comparison

| Feature                     | Array (`[T; N]`)                            | `Vec<T>`                                     |
|------------------------------|-----------------------------------------------|-----------------------------------------------|
| Length                       | Fixed at compile time                        | Growable at runtime                           |
| Storage location              | Stack (unless element type is heap-allocated) | Heap                                          |
| Ownership                    | Owned                                         | Owned                                         |
| Can push/pop elements        | No                                            | Yes (`.push()`, `.pop()`)                     |
| Common creation methods      | Array literal `[1, 2, 3]`, `[value; count]`  | `Vec::new()`, `vec![...]`, `.collect()`       |
| Safe indexed access          | `.get(index)` → `Option<&T>`                 | `.get(index)` → `Option<&T>`                  |
| Direct indexed access        | `arr[index]` (panics if out of bounds)       | `vec[index]` (panics if out of bounds)        |
| Typical use case             | Fixed-size, performance-critical data         | Dynamic lists, collections that grow/shrink at runtime |
| Slicing                      | Yes, via `&arr[..]`                          | Yes, via `&vec[..]`                           |
| Memory cleanup               | Automatic (stack unwind or `Drop` for elements) | Automatic via `Drop` when it goes out of scope |

