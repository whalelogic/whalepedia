# Zig: Comptime & Generics

Zig has no separate templates, macros, or generics syntax. Instead it has a
single unifying feature — `comptime` — that runs ordinary Zig code at
compile time. Generics, constants, and metaprogramming are all built on top
of this one mechanism.

## The Core Idea: Code That Runs at Compile Time

```zig
const std = @import("std");

fn factorial(n: u64) u64 {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

const precomputed = comptime factorial(10);    // evaluated during compilation, not at runtime

pub fn main() void {
    std.debug.print("{}\n", .{precomputed});      // just prints the baked-in constant
}
```

Any expression can be forced to evaluate at compile time with the
`comptime` keyword. The compiler runs an interpreter over ordinary Zig
functions to do this — there is no separate "macro language" to learn.

## `comptime` Variables and Parameters

```zig
comptime var total: i32 = 0;      // a variable that only exists during compilation

fn addAtComptime(comptime a: i32, comptime b: i32) i32 {   // parameters known at compile time
    return a + b;
}

const sum = addAtComptime(2, 3);     // must be called with compile-time-known arguments
```

Marking a function parameter `comptime` requires every call site to supply
a value the compiler can resolve during compilation — this is the
foundation for generic types and functions.

## Generic Functions via `comptime type` Parameters

```zig
fn max(comptime T: type, a: T, b: T) T {    // T is a type, known at compile time
    return if (a > b) a else b;
}

const int_max = max(i32, 3, 7);
const float_max = max(f64, 3.14, 2.71);
```

This is Zig's entire generics story: a function parameter whose type is
`type`. The compiler generates a specialized version of the function for
each concrete `T` it's called with — similar in effect to C++ templates or
Rust generics, but expressed as plain function parameters instead of a
separate angle-bracket syntax.

## Generic Data Structures

```zig
fn Stack(comptime T: type) type {      // a function that RETURNS a type
    return struct {
        items: std.ArrayList(T),

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{ .items = std.ArrayList(T).init(allocator) };
        }

        pub fn push(self: *Self, item: T) !void {
            try self.items.append(item);
        }

        pub fn pop(self: *Self) ?T {
            return self.items.popOrNull();
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }
    };
}

var int_stack = Stack(i32).init(allocator);
defer int_stack.deinit();
try int_stack.push(1);
try int_stack.push(2);
const top = int_stack.pop();       // ?i32
```

`Stack(i32)` is not syntax sugar for something else — it's an ordinary
function call that happens to return a `type`, evaluated at compile time.
`std.ArrayList(T)` in the standard library works exactly the same way.

## `@This()` — Referring to the Enclosing Type

```zig
const Point = struct {
    x: i32,
    y: i32,

    const Self = @This();      // Self now refers to Point

    fn origin() Self {
        return Self{ .x = 0, .y = 0 };
    }
};
```

`@This()` is commonly aliased to `Self` inside a struct so methods can
refer to their own type generically, which matters a lot inside generic
functions like `Stack(T)` above where the type doesn't have a fixed name.

## `anytype`: Duck-Typed Compile-Time Generics

```zig
fn printAnything(value: anytype) void {
    std.debug.print("{}\n", .{value});
}

printAnything(42);
printAnything("hello");
printAnything(3.14);

fn sum(a: anytype, b: @TypeOf(a)) @TypeOf(a) {   // @TypeOf infers a matching type
    return a + b;
}
```

`anytype` accepts any type and lets the compiler infer what operations are
valid inside the function body — errors surface only when the function is
actually instantiated with an incompatible type, similar to C++ template
duck-typing.

## Compile-Time Reflection with `@typeInfo`

```zig
fn describeType(comptime T: type) void {
    const info = @typeInfo(T);
    switch (info) {
        .Int => |int_info| std.debug.print("integer, {} bits\n", .{int_info.bits}),
        .Float => std.debug.print("floating point\n", .{}),
        .Struct => |struct_info| std.debug.print("struct with {} fields\n", .{struct_info.fields.len}),
        else => std.debug.print("other type\n", .{}),
    }
}

describeType(i32);
describeType(f64);
```

`@typeInfo` exposes the full structure of any type as data you can branch
on at compile time — this is how generic serialization, ORMs, and print
formatting are implemented in the standard library without a separate
reflection API layer.

## `inline for` — Compile-Time Loop Unrolling Over Types

```zig
const types = .{ i32, f64, bool };

inline for (types) |T| {
    std.debug.print("{}\n", .{@typeName(T)});
}
```

`inline for` runs its loop body at compile time once per element, allowing
iteration over a heterogeneous tuple of types — something an ordinary
runtime `for` loop cannot do, since runtime loops need a single element
type.

## Compile-Time Assertions

```zig
fn requiresPositive(comptime n: i32) void {
    if (n <= 0) @compileError("n must be positive");    // fails compilation, not runtime
}

comptime {
    if (@sizeOf(usize) != 8) {
        @compileError("this code assumes a 64-bit target");
    }
}
```

`@compileError` immediately fails compilation with a custom message — used
throughout the standard library to give clear errors when a generic
function is misused, instead of a cryptic type mismatch deep in generated
code.

## `comptime` Blocks for One-Time Setup

```zig
const lookup_table = blk: {
    var table: [256]u8 = undefined;
    for (&table, 0..) |*entry, i| {
        entry.* = @intCast(i * 2);
    }
    break :blk table;
};
```

This builds a 256-entry lookup table entirely at compile time — the
resulting binary contains only the final baked-in array, with zero runtime
cost for the computation that produced it.

## Generic Constraints via `@typeInfo` Checks

```zig
fn sumAll(comptime T: type, items: []const T) T {
    comptime {
        switch (@typeInfo(T)) {
            .Int, .Float => {},
            else => @compileError("sumAll requires a numeric type"),
        }
    }
    var total: T = 0;
    for (items) |item| total += item;
    return total;
}
```

Since Zig has no trait/interface system, "constraining" a generic parameter
means writing a `comptime` check that calls `@compileError` when the
supplied type doesn't satisfy your requirements.

## Common `comptime`-Related Builtins

| Builtin | Purpose |
|---|---|
| `@TypeOf(expr)` | Get the type of an expression |
| `@typeInfo(T)` | Get a data description of a type's structure |
| `@typeName(T)` | Get a type's name as a string |
| `@sizeOf(T)` | Size of a type in bytes |
| `@compileError(msg)` | Fail compilation with a custom message |
| `@compileLog(args)` | Print debug info during compilation |
| `@This()` | Refer to the innermost enclosing struct/enum/union type |
| `@field(obj, name)` | Access a struct field by a comptime-known name string |

## Practical Full Example: A Generic `Pair`

```zig
fn Pair(comptime A: type, comptime B: type) type {
    return struct {
        first: A,
        second: B,

        const Self = @This();

        pub fn init(first: A, second: B) Self {
            return Self{ .first = first, .second = second };
        }

        pub fn swap(self: Self) Pair(B, A) {
            return Pair(B, A).init(self.second, self.first);
        }
    };
}

const p = Pair(i32, []const u8).init(1, "one");
const swapped = p.swap();     // Pair([]const u8, i32){ first: "one", second: 1 }
```

## Tips

- Generics in Zig are not a special syntax — they're ordinary functions
  that take and return `type`, evaluated at compile time.
- `anytype` is convenient for quick duck-typed helpers; `comptime T: type`
  is more explicit and better for public APIs and generic data structures.
- Use `@compileError` inside `comptime` blocks to give generic code clear,
  early failure messages instead of letting misuse surface as confusing
  errors deep inside generated code.
- Because everything is just Zig code interpreted at compile time, there's
  no separate template language to learn — the same debugging intuition
  that applies to runtime code mostly applies to `comptime` code too.
