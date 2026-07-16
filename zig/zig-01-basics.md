# Zig: Basics — Variables & Functions

Zig is a low-level systems language that aims to be a simpler, safer
alternative to C, with no hidden control flow, no hidden memory allocations,
and first-class compile-time execution. This sheet covers the absolute
foundation: how variables and functions actually work.

## Setup and Compilation

```bash
zig version                       # check installed version
zig init                            # scaffold a new project (build.zig + src/)
zig build-exe file.zig                # compile to a native executable
zig build-exe file.zig -O ReleaseFast   # optimized build
zig run file.zig                          # compile and run in one step
zig build                                   # build using build.zig
zig build run                                 # build and run project
zig test file.zig                               # run tests in a file
zig fmt file.zig                                  # format code
```

## Hello World

```zig
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, World!\n", .{});
}
```

`@import` pulls in a module. `std.debug.print` takes a format string and a
tuple of arguments (`.{}` is an empty tuple here).

## Variables: `const` vs `var`

Zig has exactly two variable declaration keywords, and the distinction is
enforced by the compiler, not just convention.

```zig
const x: i32 = 10;    // immutable binding — cannot be reassigned
var y: i32 = 20;        // mutable binding — can be reassigned

y = 30;                    // OK
// x = 40;                 // compile error: cannot assign to constant
```

**Rule of thumb:** default to `const`. Only use `var` when you actually need
to mutate the value later. The compiler will error if you declare something
`var` but never mutate it — Zig enforces this instead of just linting it.

## Type Inference and Explicit Types

```zig
const a = 10;              // type inferred: comptime_int, coerced to usage context
const b: i32 = 10;           // explicit type: 32-bit signed integer
const c: u8 = 255;             // explicit type: 8-bit unsigned integer
const name = "Zig";              // type inferred: *const [3:0]u8 (string literal)
const pi: f64 = 3.14159;           // explicit float type

var count: usize = 0;                // usize: pointer-sized unsigned integer,
                                        // the idiomatic type for lengths/indices
```

Zig requires explicit types far more often than languages like Nim or Rust
in practice — integer literals are "comptime_int" until they're used in a
context that pins them to a concrete type.

## Basic Types

```zig
// Signed integers
const i8_val: i8 = -128;
const i16_val: i16 = -32768;
const i32_val: i32 = -2147483648;
const i64_val: i64 = -9223372036854775808;

// Unsigned integers
const u8_val: u8 = 255;
const u16_val: u16 = 65535;
const u32_val: u32 = 4294967295;
const u64_val: u64 = 18446744073709551615;

// Arbitrary-width integers (unique to Zig)
const odd_width: u4 = 15;     // 4-bit unsigned integer, max value 15
const bitflag: u1 = 1;          // single bit

// Floats
const f32_val: f32 = 3.14;
const f64_val: f64 = 3.14159265358979;

// Boolean
const flag: bool = true;

// Pointer-sized
const size: usize = 100;         // unsigned, matches pointer width
const signed_size: isize = -100;   // signed, matches pointer width

// void — represents no value
fn doNothing() void {}
```

## Constants vs Comptime Constants

```zig
const regular_const: i32 = 10;          // known at compile time, typed
comptime var counter: i32 = 0;            // mutable, but only during compilation

const array_size = 5;                        // used to size arrays below
var buffer: [array_size]u8 = undefined;
```

`undefined` explicitly marks a value as uninitialized — the compiler will not
silently zero it for you, and using an `undefined` value before assignment
is a bug the compiler can help catch with safety checks in debug builds.

## Functions: Declaration and Basics

```zig
fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn publicAdd(a: i32, b: i32) i32 {   // pub makes it visible outside the file/module
    return a + b;
}

fn noReturn() void {                       // void means "returns nothing"
    std.debug.print("done\n", .{});
}

fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

const result = add(2, 3);
```

Every function parameter type and return type must be explicit — Zig does
not infer function signatures the way it infers local variable types.

## Function Parameters Are Immutable by Default

```zig
fn increment(x: i32) i32 {
    // x += 1;         // compile error: x is a const parameter, cannot mutate
    return x + 1;         // must create a new value instead
}

fn incrementViaPointer(x: *i32) void {   // pass a pointer to mutate the caller's value
    x.* += 1;                               // .* dereferences the pointer
}

var value: i32 = 5;
incrementViaPointer(&value);               // &value takes the address
// value is now 6
```

This mirrors C's pass-by-value semantics, but Zig makes the immutability of
parameters explicit and compiler-enforced rather than a convention.

## Multiple Return Values via Structs

Zig has no native multiple-return-value syntax; the idiomatic pattern is to
return a small anonymous struct.

```zig
fn divide(a: i32, b: i32) struct { quotient: i32, remainder: i32 } {
    return .{ .quotient = @divTrunc(a, b), .remainder = @mod(a, b) };
}

const result = divide(17, 5);
std.debug.print("{} r {}\n", .{ result.quotient, result.remainder });
```

## Control Flow

```zig
const x: i32 = 15;

if (x > 10) {
    std.debug.print("big\n", .{});
} else if (x > 5) {
    std.debug.print("medium\n", .{});
} else {
    std.debug.print("small\n", .{});
}

// if as an expression
const label = if (x > 10) "big" else "small";

// switch
switch (x) {
    1 => std.debug.print("one\n", .{}),
    2, 3 => std.debug.print("two or three\n", .{}),
    4...10 => std.debug.print("four to ten\n", .{}),
    else => std.debug.print("other\n", .{}),
}

// switch as an expression
const category = switch (x) {
    0...9 => "single digit",
    10...99 => "double digit",
    else => "large",
};
```

## Loops

```zig
var i: usize = 0;
while (i < 5) : (i += 1) {          // the `: (i += 1)` runs after each iteration
    std.debug.print("{}\n", .{i});
}

var j: usize = 0;
while (true) {
    if (j >= 5) break;
    std.debug.print("{}\n", .{j});
    j += 1;
}

const items = [_]i32{ 10, 20, 30 };
for (items) |item| {
    std.debug.print("{}\n", .{item});
}

for (items, 0..) |item, idx| {         // iterate with index
    std.debug.print("{}: {}\n", .{ idx, item });
}

outer: for (0..5) |a| {
    for (0..5) |b| {
        if (b == 3) continue :outer;     // labeled continue
        std.debug.print("{} {}\n", .{ a, b });
    }
}
```

## Blocks as Expressions

```zig
const value = blk: {
    const a = 5;
    const b = 10;
    break :blk a + b;      // `break :label value` returns a value from a block
};
```

This pattern is common inside `if`/`switch` branches that need more than one
statement to compute their result.

## Arrays

```zig
const fixed: [3]i32 = .{ 1, 2, 3 };          // fixed-size array, size is part of the type
const inferred = [_]i32{ 1, 2, 3, 4 };          // size inferred from literal

std.debug.print("{}\n", .{fixed.len});             // .len gives the length
std.debug.print("{}\n", .{fixed[0]});                // indexing

var mutable_array: [3]i32 = .{ 0, 0, 0 };
mutable_array[0] = 100;
```

## Basic String Handling

```zig
const greeting: []const u8 = "Hello, Zig!";     // string literal, slice of bytes

std.debug.print("{s}\n", .{greeting});             // {s} formats as a string
std.debug.print("{}\n", .{greeting.len});             // length in bytes

const std_ascii = std.ascii;
const upper_char = std_ascii.toUpper('a');              // per-character case conversion

if (std.mem.eql(u8, greeting, "Hello, Zig!")) {            // string comparison
    std.debug.print("matched\n", .{});
}
```

Zig has no built-in high-level string type; strings are just `[]const u8`
(a slice of bytes), and most string operations live in `std.mem` and
`std.ascii`.

## Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Variables / functions | camelCase | `myVariable`, `doSomething` |
| Types (structs, enums) | PascalCase | `MyStruct`, `Color` |
| Constants (comptime-known) | camelCase or SCREAMING_SNAKE for globals | `maxSize`, `MAX_SIZE` |
| Files | snake_case | `my_module.zig` |

## Printing / Formatting Cheat Sheet

```zig
std.debug.print("{}\n", .{42});           // default formatting
std.debug.print("{d}\n", .{42});            // decimal integer
std.debug.print("{s}\n", .{"text"});          // string
std.debug.print("{x}\n", .{255});               // hexadecimal
std.debug.print("{b}\n", .{5});                   // binary
std.debug.print("{.2}\n", .{3.14159});              // float, 2 decimal places (varies by fmt)
std.debug.print("{any}\n", .{someValue});             // generic fallback formatting
```

## Tips

- Default to `const`; the compiler forces you to use `var` only when you
  actually mutate a binding.
- Every unused variable is a compile error in Zig, not just a warning —
  prefix with `_` (e.g. `_ = someVar;`) to explicitly discard a value.
- Function parameters are always immutable; mutate through a pointer if you
  need the caller's value to change.
- `undefined` is a real, explicit value — Zig will not silently
  zero-initialize memory for you outside of safety-checked builds.
- There is no function overloading; use `comptime` parameters and generics
  (covered in the comptime sheet) for polymorphic behavior instead.
