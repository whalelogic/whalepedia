
# Rust Foundational Reference Documentation (`std`)

This document provides a mechanical reference for the core modules of the Rust Standard Library (`std`) responsible for file system operations, process e
xecution, environment interaction, and text manipulation.

---

## 1. Module Overview: `std` Foundational Components

The Rust Standard Library provides the essential interface between the Rust language and the underlying operating system.

- **`std::fs`**: Filesystem manipulation (Read, Write, Metadata, Permissions).
- **`std::process`**: Child process management (Execution, Input/Output redirection).
- **`std::env`**: Process environment (Arguments, Environment variables, Current directory).
- **`std::str` & `std::string`**: UTF-8 text processing and parsing.
- **`std::prelude`**: The set of items automatically imported into every module.

---

## 2. Construction and Initialization

### File Handles (`std::fs::File`)
Files are obtained via static methods or via the `OpenOptions` builder.

| Method | Behavior | Error Conditions |
| :--- | :--- | :--- |
| `File::open(path)` | Opens in **Read-only** mode. | Path does not exist; Permission denied. |
| `File::create(path)` | Opens in **Write-only** mode. Truncates existing file. | Permission denied; Path is a directory. |
| `OpenOptions::new()` | Initializes a builder for custom access modes. | N/A (Internal allocation). |

### Process Spawning (`std::process::Command`)
Processes are initialized via the `Command` struct.

| Method | Behavior | Notes |
| :--- | :--- | :--- |
| `Command::new(program)` | Constructs a builder for the specified executable. | Does not execute immediately. |

---

## 3. The Method Matrix

### File Access Modes (`OpenOptions`)
`OpenOptions` allows combinatorial configuration of file behavior.

| Option | Type | Effect |
| :--- | :--- | :--- |
| `read` | `bool` | Enables read access. |
| `write` | `bool` | Enables write access. |
| `append` | `bool` | Sets the file offset to the end before every write. |
| `truncate` | `bool` | Sets file length to 0 if it exists. Requires `write(true)`. |
| `create` | `bool` | Creates file if it doesn't exist. Requires `write(true)` or `append(true)`. |
| `create_new` | `bool` | Creates file; fails if it already exists. |

### Execution Modes (`Command`)
Methods to transition a `Command` from configuration to execution.

| Method | Return Type | Use Case |
| :--- | :--- | :--- |
| `status()` | `Result<ExitStatus>` | Run to completion; ignore output; get exit code. |
| `output()` | `Result<Output>` | Run to completion; capture `stdout` and `stderr` into memory. |
| `spawn()` | `Result<Child>` | Run asynchronously; returns a handle for manual management. |

---

## 4. Method Reference: `std::fs`

### `File` Struct
Methods for interacting with an open file handle.

- **`read(&mut self, buf: &mut [u8]) -> Result<usize>`**
  - Reads up to `buf.len()` bytes into the provided buffer.
  - Returns the number of bytes read. Returns `0` at EOF.
- **`write(&mut self, buf: &[u8]) -> Result<usize>`**
  - Attempts to write all bytes from `buf` to the file.
  - Returns the number of bytes successfully written.
- **`sync_all(&self) -> Result<()>`**
  - Flushes OS buffers and ensures data is physically written to the underlying storage.
- **`metadata(&self) -> Result<Metadata>`**
  - Returns file size, modified times, and permissions without closing the handle.

### Module Functions
Direct functions that do not require an explicit `File` handle.

- **`fs::read_to_string<P: AsRef<Path>>(path: P) -> Result<String>`**
  - **Contract**: Reads the entire file into a `String`. 
  - **Panics**: If file content is not valid UTF-8.
- **`fs::write<P: AsRef<Path>, C: AsRef<[u8]>>(path: P, contents: C) -> Result<()>`**
  - **Contract**: Atomic-style write. Creates or truncates file and writes the entire buffer.

---

## 5. Method Reference: `std::process`

### `Command` Configuration
- **`arg(val: S) -> &mut Command`**: Appends a single argument to the command.
- **`args(vals: I) -> &mut Command`**: Appends multiple arguments from an iterator.
- **`env(key: K, val: V) -> &mut Command`**: Sets an environment variable for the child.
- **`stdin(cfg: Stdio) -> &mut Command`**: Configures the standard input (e.g., `Stdio::piped()`, `Stdio::null()`).

### `Child` Handle
- **`wait() -> Result<ExitStatus>`**: Blocks until the child exits.
- **`kill() -> Result<()>`**: Sends a termination signal (SIGKILL on Unix) to the child.
- **`wait_with_output() -> Result<Output>`**: Consumes the child handle and returns captured output.

---

## 6. Method Reference: Text Parsing (`str` and `String`)

Rust distinguishes between `&str` (fixed-size string slice) and `String` (growable, heap-allocated).

### Parsing Operations
- **`parse::<T>() -> Result<T, T::Err>`**
  - Attempts to convert a string into type `T` (e.g., `i32`, `f64`).
  - **Returns**: `Ok(val)` if successful, `Err` if the string format is invalid for `T`.
- **`split(pattern: P) -> Split<P>`**
  - Returns an iterator over substrings separated by the pattern.
  - **Edge Case**: Splitting an empty string returns one empty string element.

### Search and Match
- **`contains(pattern: P) -> bool`**: Returns `true` if the pattern exists in the string.
- **`find(pattern: P) -> Option<usize>`**: Returns the byte index of the first match.
- **`matches(pattern: P) -> Matches<P>`**: Returns an iterator of all non-overlapping matches.

---

## 7. Built-in Macros and Functions (The Prelude)

These are globally available without explicit import.

### Macros
- **`println!(fmt, ...)`**: Prints to `stdout` with a newline. Panics if `stdout` is closed.
- **`format!(fmt, ...)`**: Returns a `String` containing the formatted text. Does not print.
- **`panic!(msg)`**: Terminates the current thread immediately with the provided message.
- **`vec![...]`**: Constructs a `Vec<T>` with initial elements.
- **`assert!(expr)` / `assert_eq!(a, b)`**: Panics if the condition is false.

### Core Types (Behaviors)
- **`Option<T>`**: `Some(val)` or `None`. Used for nullable values.
- **`Result<T, E>`**: `Ok(val)` or `Err(err)`. Mandatory for functions that can fail.

---

## 8. Concurrency and Safety

| Component | Concurrency Contract | Safety |
| :--- | :--- | :--- |
| `File` | Thread-safe (`Sync` and `Send`). Multiple threads can read from the same handle. | OS-level locking is not enforced by Rust; race conditions p
ossible at the filesystem level. |
| `String` | `Send` and `Sync` (if immutable). `&mut String` is exclusive. | Memory safe; UTF-8 validity is guaranteed for all `String` methods. |
| `Command` | Not typically shared; intended to be built and consumed by a single thread. | Child processes are isolated; Rust does not prevent "fork bom
bs" or resource exhaustion. |

---

## 9. Performance Characteristics

1.  **Allocation**: 
    - `fs::read_to_string` and `Command::output` allocate memory for the entire content. Use `std::io::BufReader` for large files to process in chunks.
    - `String::new()` and `Vec::new()` do not allocate until the first element is added.
2.  **Syscalls**: 
    - Every call to `File::read` or `File::write` results in a system call. Wrapping in `BufReader` or `BufWriter` reduces syscall overhead by buffering 
in user-space.
3.  **UTF-8 Validation**: 
    - `str` and `String` methods perform O(n) UTF-8 validation upon creation from raw bytes.

---

## 10. Code Examples

### File Read/Write (Safe)
```rust
use std::fs::File;
use std::io::{Read, Write};

fn main() -> std::io::Result<()> {
    // 1. Create/Write
    let mut file = File::create("data.txt")?;
    file.write_all(b"Mechanical documentation content")?;

    // 2. Open/Read
    let mut file = File::open("data.txt")?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    
    assert_eq!(contents, "Mechanical documentation content");
    Ok(())
}
```

### Command Execution with Pipes
```rust
use std::process::{Command, Stdio};
use std::io::Write;

fn main() -> std::io::Result<()> {
    let mut child = Command::new("cat")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    // Access stdin handle
    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    stdin.write_all(b"Hello from Rust")?;
    drop(stdin); // Close stdin so cat exits

    let output = child.wait_with_output()?;
    assert_eq!(output.stdout, b"Hello from Rust");
    Ok(())
}
```

### Parsing String to Integer
```rust
fn main() {
    let input = "1024";
    // Explicit type turbofish syntax
    match input.parse::<i32>() {
        Ok(n) => println!("Parsed integer: {}", n),
        Err(e) => panic!("Failed to parse: {}", e),
    }
}
```

