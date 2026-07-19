# Zig Functions

Zig functions are explicit, compile-time friendly, and can return errors or optionals.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `fn name(args) T {}` | Standard function definition | `fn add(a: i32, b: i32) i32 { ... }` |
| `pub fn` | Export public API | `pub fn parse(...) !Result` |
| Error union `!T` | Return value or error | `fn read(...) !usize` |
| Optional `?T` | Return nullable-like value | `fn find(...) ?usize` |
| `comptime` params | Compile-time specialization | `fn make(comptime T: type) type` |

## Common Built-in Functions

| Built-in | Purpose | Example |
| --- | --- | --- |
| `@import` | Load module/file | `@import("std")` |
| `@TypeOf` / `@typeInfo` | Type introspection | `@TypeOf(value)` |
| `@as` / `@intCast` | Explicit casting | `@as(u32, x)` |
| `@memcpy` / `@memset` | Memory operations | `@memcpy(dst, src)` |
| `@panic` | Abort execution with message | `@panic("unreachable")` |

## Examples

```zig
fn mapInt(values: []const i32, f: fn (i32) i32, out: []i32) void {
    for (values, 0..) |v, i| out[i] = f(v);
}
```
