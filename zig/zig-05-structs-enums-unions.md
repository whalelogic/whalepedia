# Zig: Structs, Enums & Unions

Zig's data types are plain and explicit: structs are just grouped fields
with optional methods, enums are named integer constants, and unions come
in both an unsafe C-style form and a memory-safe "tagged" form.

## Structs: Basics

```zig
const std = @import("std");

const Point = struct {
    x: i32,
    y: i32,
};

const p = Point{ .x = 1, .y = 2 };       // fields set with .name = value
std.debug.print("{}, {}\n", .{ p.x, p.y });

var mutable_point = Point{ .x = 0, .y = 0 };
mutable_point.x = 10;                       // mutate a field (struct itself must be `var`)
```

## Struct Methods

```zig
const Rectangle = struct {
    width: f64,
    height: f64,

    fn area(self: Rectangle) f64 {          // takes self by value
        return self.width * self.height;
    }

    fn scale(self: *Rectangle, factor: f64) void {   // takes self by pointer to mutate
        self.width *= factor;
        self.height *= factor;
    }
};

var rect = Rectangle{ .width = 10, .height = 5 };
std.debug.print("{}\n", .{rect.area()});      // 50
rect.scale(2);
std.debug.print("{}\n", .{rect.area()});         // 200
```

Methods are just functions defined inside the struct's body whose first
parameter is conventionally named `self`. Calling `rect.scale(2)` is sugar
for `Rectangle.scale(&rect, 2)`.

## Default Field Values

```zig
const Config = struct {
    port: u16 = 8080,           // default value
    host: []const u8 = "localhost",
    debug: bool = false,
};

const default_config = Config{};                    // uses all defaults
const custom_config = Config{ .port = 3000 };          // override just one field
```

## Constructor Pattern (No Built-in `new`)

```zig
const Vector2 = struct {
    x: f64,
    y: f64,

    fn init(x: f64, y: f64) Vector2 {      // conventional "constructor" is just a function
        return Vector2{ .x = x, .y = y };
    }

    fn zero() Vector2 {                       // named "constructors" for common cases
        return Vector2{ .x = 0, .y = 0 };
    }

    fn add(self: Vector2, other: Vector2) Vector2 {
        return Vector2{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

const v1 = Vector2.init(1, 2);
const v2 = Vector2.zero();
const v3 = v1.add(v2);
```

There's no `new` keyword; a function named `init` (by convention, not a
language rule) that returns an instance of the struct fills that role.

## Nested Structs

```zig
const Address = struct {
    street: []const u8,
    city: []const u8,
};

const Person = struct {
    name: []const u8,
    address: Address,
};

const person = Person{
    .name = "Alice",
    .address = .{ .street = "Main St", .city = "Springfield" },   // `.{}` infers the type
};

std.debug.print("{s}\n", .{person.address.city});
```

## Anonymous Structs

```zig
const point = .{ .x = 1, .y = 2 };        // anonymous struct, type inferred from usage

fn printPoint(p: anytype) void {              // accepts any struct-like value
    std.debug.print("{}, {}\n", .{ p.x, p.y });
}
printPoint(point);
printPoint(.{ .x = 5, .y = 10 });             // works without naming a type at all
```

Anonymous structs are common for one-off argument bundles, especially as
the second argument to `std.debug.print`, which itself takes an anonymous
struct as its format-argument tuple.

## Enums: Basics

```zig
const Color = enum {
    red,
    green,
    blue,
};

const c: Color = .red;             // `.red` infers Color from context
std.debug.print("{}\n", .{c});

switch (c) {
    .red => std.debug.print("it's red\n", .{}),
    .green => std.debug.print("it's green\n", .{}),
    .blue => std.debug.print("it's blue\n", .{}),
}
```

## Enums with Explicit Backing Values

```zig
const Status = enum(u8) {
    ok = 200,
    not_found = 404,
    server_error = 500,
};

const s = Status.not_found;
std.debug.print("{}\n", .{@intFromEnum(s)});      // 404
```

## Enums with Methods

```zig
const Direction = enum {
    north,
    south,
    east,
    west,

    fn opposite(self: Direction) Direction {
        return switch (self) {
            .north => .south,
            .south => .north,
            .east => .west,
            .west => .east,
        };
    }
};

const d = Direction.north;
std.debug.print("{}\n", .{d.opposite()});     // .south
```

Zig's exhaustive `switch` means adding a new enum variant without updating
every switch over that enum is a compile error — a useful safety net when
extending a type used throughout a codebase.

## Unions: C-Style (Untagged)

```zig
const RawValue = union {
    int: i32,
    float: f32,
    boolean: bool,
};

var v = RawValue{ .int = 42 };
std.debug.print("{}\n", .{v.int});

v = RawValue{ .float = 3.14 };
std.debug.print("{}\n", .{v.float});
// accessing v.int here would be undefined behavior — nothing tracks which field is active
```

Plain `union` has no memory overhead but also no runtime information about
which field is currently valid — reading the wrong field is undefined
behavior, exactly like a C union. Use this only when interoperating with C
or when you have an external, out-of-band way of knowing which field is
active.

## Unions: Tagged (Safe, the Idiomatic Default)

```zig
const TaggedValue = union(enum) {
    int: i32,
    float: f32,
    boolean: bool,
    none: void,          // a variant carrying no data
};

var tv = TaggedValue{ .int = 42 };

switch (tv) {
    .int => |value| std.debug.print("int: {}\n", .{value}),
    .float => |value| std.debug.print("float: {}\n", .{value}),
    .boolean => |value| std.debug.print("bool: {}\n", .{value}),
    .none => std.debug.print("nothing\n", .{}),
}
```

`union(enum)` attaches a hidden tag that tracks which variant is currently
active, and `switch` on a tagged union is exhaustive and safe — this is
Zig's equivalent of a Rust `enum` or a Swift enum with associated values,
and is almost always preferable to a plain `union`.

## Tagged Union with an Explicit Enum Type

```zig
const ValueType = enum { int, float, boolean };

const Value = union(ValueType) {
    int: i32,
    float: f32,
    boolean: bool,
};

const val = Value{ .int = 10 };
std.debug.print("{}\n", .{@as(ValueType, val)});     // convert union to its active tag
```

## Packed Structs (Bit-Level Layout Control)

```zig
const Flags = packed struct {
    read: bool,
    write: bool,
    execute: bool,
    _padding: u5 = 0,      // pad out to a full byte
};

const perms = Flags{ .read = true, .write = true, .execute = false };
std.debug.print("{}\n", .{@sizeOf(Flags)});     // 1 byte total, no wasted padding
```

`packed struct` lays out fields with no compiler-inserted padding between
them, useful for matching hardware register layouts or wire formats
exactly.

## Extern Structs (C ABI Compatible Layout)

```zig
const CPoint = extern struct {     // matches C's struct layout rules exactly
    x: c_int,
    y: c_int,
};
```

Use `extern struct` specifically when a struct needs to match a C struct's
memory layout byte-for-byte, e.g. when passed across an FFI boundary.

## Comparing Structs

```zig
const std = @import("std");

const A = struct { x: i32, y: i32 };
const a1 = A{ .x = 1, .y = 2 };
const a2 = A{ .x = 1, .y = 2 };

// No built-in == for structs; compare field by field, or use std.meta.eql
const equal = std.meta.eql(a1, a2);
std.debug.print("{}\n", .{equal});
```

Zig deliberately does not overload `==` for structs (no operator
overloading at all, in fact) — use `std.meta.eql` for structural
comparison, or write your own `eql` method for custom logic.

## Interfaces via Tagged Unions or `anytype` (No `interface` Keyword)

```zig
const Shape = union(enum) {
    circle: struct { radius: f64 },
    rectangle: struct { width: f64, height: f64 },

    fn area(self: Shape) f64 {
        return switch (self) {
            .circle => |c| std.math.pi * c.radius * c.radius,
            .rectangle => |r| r.width * r.height,
        };
    }
};

const shapes = [_]Shape{
    .{ .circle = .{ .radius = 2 } },
    .{ .rectangle = .{ .width = 3, .height = 4 } },
};

for (shapes) |shape| {
    std.debug.print("{d}\n", .{shape.area()});
}
```

Without classical inheritance or interfaces, tagged unions are the
idiomatic way to express "one of several related shapes/kinds" with
exhaustive, type-safe handling at every use site.

## Quick Reference

| Construct | Use for |
|---|---|
| `struct` | Grouping named, typed fields; the default aggregate type |
| `packed struct` | Bit-exact layout, no padding, for hardware/wire formats |
| `extern struct` | C ABI-compatible layout, for FFI |
| `enum` | A closed set of named constant values |
| `enum(T)` | Enum with an explicit backing integer type/values |
| `union` | Overlapping storage, unsafe, C-style, no active-field tracking |
| `union(enum)` | Overlapping storage, safe, tracks the active variant |

## Tips

- Default to `union(enum)` over plain `union` unless you specifically need
  C-compatible untagged layout — the safety cost of plain unions is easy to
  trip over.
- Exhaustive `switch` over enums and tagged unions is a compile-time safety
  net: adding a new variant forces you to handle it everywhere it's
  switched on.
- There's no inheritance; prefer composition (nesting structs) or tagged
  unions (modeling "one of several kinds") over trying to simulate classes.
- Use `std.meta.eql` for structural equality since `==` doesn't work on
  structs — write an explicit `eql` method if you need custom comparison
  semantics.
