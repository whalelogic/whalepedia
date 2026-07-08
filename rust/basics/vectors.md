# Vectors 🦀

`Vec<T>` (pronounced "vector") is a **growable, heap-allocated** list of values, all of the same type `T`. It's one of the most commonly used collection types in Rust.

It's helpful to think of vectors as the dynamic version of a fixed array. Like `String`, a `Vec<T>` owns its data and will free its memory automatically when it goes out of scope.

## ⭐ Example

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
