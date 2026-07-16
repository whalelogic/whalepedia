# Zig: Error Handling

Zig has no exceptions. Errors are ordinary values, propagated through a
built-in "error union" type that the compiler forces you to handle
explicitly at every call site.

## Error Sets: Declaring What Can Go Wrong

```zig
const FileError = error{
    NotFound,
    PermissionDenied,
    OutOfSpace,
};

const MathError = error{
    DivisionByZero,
    Overflow,
};
```

An error set is just an enum-like list of named error values. Functions
declare which errors they can return as part of their type signature.

## Error Union Types: `ErrorSet!ReturnType`

```zig
fn divide(a: i32, b: i32) MathError!i32 {
    if (b == 0) return MathError.DivisionByZero;
    return @divTrunc(a, b);
}

fn divideInferred(a: i32, b: i32) !i32 {   // `!i32` lets Zig infer the error set
    if (b == 0) return error.DivisionByZero;
    return @divTrunc(a, b);
}
```

`!i32` means "either an error, or an `i32`." The bare `!T` form (inferred
error set) is common and lets the compiler collect every possible error
your function's body can produce.

## Handling Errors: `try`

```zig
fn process() !void {
    const result = try divide(10, 2);       // propagate error upward if divide() fails
    std.debug.print("{}\n", .{result});
}
```

`try expr` is shorthand for: "evaluate `expr`; if it's an error, return
that error immediately from the current function; otherwise, unwrap the
success value." It requires the enclosing function to itself return an
error union.

## Handling Errors: `catch`

```zig
const result = divide(10, 0) catch 0;              // supply a fallback value on error
const result2 = divide(10, 0) catch |err| {          // inspect the error
    std.debug.print("Error: {}\n", .{err});
    return;
};

const result3 = divide(10, 0) catch unreachable;      // assert this can never fail (panics if wrong)
```

`catch` lets you handle an error inline instead of propagating it — supply
a default value, run a block, or explicitly mark the path as impossible
with `unreachable`.

## Switch on Errors

```zig
fn handle(a: i32, b: i32) void {
    const result = divide(a, b) catch |err| switch (err) {
        MathError.DivisionByZero => {
            std.debug.print("cannot divide by zero\n", .{});
            return;
        },
        MathError.Overflow => {
            std.debug.print("overflow occurred\n", .{});
            return;
        },
    };
    std.debug.print("{}\n", .{result});
}
```

## Combining Error Sets

```zig
const AppError = FileError || MathError;    // merge two error sets with ||

fn doSomething() AppError!void {
    return FileError.NotFound;                  // valid: NotFound is part of AppError
}
```

## `if` with Error Unions

```zig
if (divide(10, 2)) |value| {
    std.debug.print("Got: {}\n", .{value});
} else |err| {
    std.debug.print("Error: {}\n", .{err});
}
```

This is the error-union counterpart to unwrapping an optional with `if`.

## Errors and Optionals Together

```zig
fn find(items: []const i32, target: i32) !?usize {   // may error AND may not find anything
    if (items.len == 0) return error.EmptyList;
    for (items, 0..) |item, i| {
        if (item == target) return i;
    }
    return null;
}

const maybe_index = try find(&.{ 1, 2, 3 }, 2);
if (maybe_index) |index| {
    std.debug.print("found at {}\n", .{index});
} else {
    std.debug.print("not found\n", .{});
}
```

`!?T` reads as "an error, or an optional T" — a common pattern for
operations that can both fail and legitimately return "nothing."

## `main` Returning an Error Union

```zig
const std = @import("std");

pub fn main() !void {              // main can return !void
    const file = try std.fs.cwd().openFile("data.txt", .{});
    defer file.close();
}
```

If `main` returns an error, Zig prints the error name and a non-zero exit
code automatically — no manual top-level error handling boilerplate needed
for simple programs.

## `errdefer`: Cleanup Only on the Error Path

```zig
fn openAndPrepare(allocator: std.mem.Allocator) !*Resource {
    const resource = try allocator.create(Resource);
    errdefer allocator.destroy(resource);     // only runs if a LATER step fails

    try resource.initialize();                    // if this fails, errdefer above fires
    return resource;                                 // success: errdefer is skipped
}
```

`errdefer` is essential for constructors that allocate multiple resources
in sequence — each step's cleanup only needs to be registered once, right
after the resource is acquired.

## Panics vs Errors: Two Different Failure Modes

```zig
// Recoverable: caller decides what to do
fn parseNumber(s: []const u8) !i32 {
    return std.fmt.parseInt(i32, s, 10);
}

// Unrecoverable: a programmer bug, not a runtime condition
fn getElement(arr: []const i32, index: usize) i32 {
    return arr[index];    // panics (out-of-bounds) in safety-checked builds if index is bad
}

std.debug.assert(1 + 1 == 2);    // panics if the condition is false
unreachable;                        // asserts this code path is never reached
@panic("custom failure message");     // explicit, immediate panic
```

Zig distinguishes between **errors** (expected, recoverable failure modes
like "file not found") and **panics** (programmer bugs like out-of-bounds
access or integer overflow in safe builds) — errors are values you handle,
panics crash the program to surface bugs immediately.

## Integer Overflow Is a Panic, Not Silent Wraparound

```zig
var x: u8 = 255;
// x += 1;                         // panics in Debug/ReleaseSafe: "integer overflow"

var y: u8 = 255;
y +%= 1;                              // explicit wraparound addition: y becomes 0
const z = @addWithOverflow(y, 1);       // returns {result, overflow_bit} explicitly
```

Ordinary `+` panics on overflow in safety-checked builds — you must opt
into wraparound (`+%`) or overflow-checked (`@addWithOverflow`) arithmetic
explicitly, which prevents silent bugs common in C.

## Testing That an Error Occurs

```zig
const std = @import("std");
const testing = std.testing;

test "division by zero returns an error" {
    try testing.expectError(MathError.DivisionByZero, divide(10, 0));
}

test "successful division" {
    const result = try divide(10, 2);
    try testing.expectEqual(@as(i32, 5), result);
}
```

```bash
zig test file.zig       # compiles and runs all `test` blocks in the file
```

## Practical Full Example

```zig
const std = @import("std");

const ConfigError = error{
    MissingField,
    InvalidValue,
};

const Config = struct {
    port: u16,
    host: []const u8,
};

fn parseConfig(raw_port: ?[]const u8, raw_host: ?[]const u8) ConfigError!Config {
    const port_str = raw_port orelse return ConfigError.MissingField;
    const host = raw_host orelse return ConfigError.MissingField;

    const port = std.fmt.parseInt(u16, port_str, 10) catch return ConfigError.InvalidValue;

    return Config{ .port = port, .host = host };
}

pub fn main() !void {
    const config = parseConfig("8080", "localhost") catch |err| {
        std.debug.print("Failed to parse config: {}\n", .{err});
        return;
    };
    std.debug.print("Listening on {s}:{}\n", .{ config.host, config.port });
}
```

## `orelse`: Default Value for Optionals (Related Pattern)

```zig
const raw_port: ?[]const u8 = null;
const port_str = raw_port orelse "8080";     // fallback value if null
```

`orelse` is the optional-type sibling of `catch` — same idea, applied to
`?T` instead of `E!T`.

## Quick Reference

| Construct | Purpose |
|---|---|
| `E!T` | Error union: either error set `E` or success value `T` |
| `try expr` | Propagate error upward automatically |
| `catch fallback` | Provide a default value on error |
| `catch \|err\| {...}` | Handle the error explicitly |
| `errdefer` | Run cleanup only if the function later returns an error |
| `if (x) \|v\| {} else \|e\| {}` | Branch on error union success/failure |
| `unreachable` | Assert a code path is impossible (panics if reached) |
| `@panic("msg")` | Immediately crash with a message |
| `orelse` | Default value for an optional (`?T`), not an error union |

## Tips

- Prefer the inferred error set (`!T`) unless you need to expose a specific,
  documented error set as part of a public API.
- Use `errdefer` liberally in multi-step resource acquisition — it keeps
  cleanup logic next to the acquisition it corresponds to.
- Reserve panics (`unreachable`, `@panic`, assertion failures) for actual
  programmer bugs; use error unions for anything a caller could reasonably
  expect to happen (missing files, bad input, network failures).
- Integer overflow panics by default in safe builds — this catches bugs
  that silently corrupt data in C.
