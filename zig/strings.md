# Zig Strings

Zig strings are usually `[]const u8` slices, manipulated with `std.mem`, `std.ascii`, and formatting APIs.

## Common String-Related APIs

| API | Purpose | Example |
| --- | --- | --- |
| `s.len` | Slice length | `s.len` |
| `std.mem.eql(u8, a, b)` | Exact equality check | `std.mem.eql(u8, a, b)` |
| `std.mem.startsWith` / `endsWith` | Prefix/suffix checks | `std.mem.startsWith(u8, s, "pre")` |
| `std.mem.indexOf` / `lastIndexOf` | Find substring position | `std.mem.indexOf(u8, s, "api")` |
| `std.mem.splitScalar` / `tokenizeScalar` | Split iterator by delimiter | `std.mem.splitScalar(u8, s, ',')` |
| `std.mem.replace` | Replace bytes into destination buffer | `std.mem.replace(u8, src, "_", "-", out)` |
| `std.mem.trim` | Trim bytes from both ends | `std.mem.trim(u8, s, " ")` |
| `std.ascii.upperString` / `lowerString` | ASCII case conversion | `std.ascii.lowerString(buf, s)` |
| `std.fmt.bufPrint` | Build formatted string in buffer | `std.fmt.bufPrint(&buf, "{s}", .{s})` |
| `std.mem.concat` | Concatenate slices with allocator | `std.mem.concat(alloc, u8, &.{a, b})` |

## Examples

```zig
const std = @import("std");
const raw = " whale_pedia ";
const trimmed = std.mem.trim(u8, raw, " ");
const idx = std.mem.indexOf(u8, trimmed, "pedia");
_ = idx;
```
