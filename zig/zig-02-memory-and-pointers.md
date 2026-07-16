# Zig: Memory & Pointers

Zig has no hidden allocations and no garbage collector. Every allocation is
explicit, routed through an "allocator" value you pass around, and every
pointer's mutability and nullability is part of its type.

## Pointer Basics

```zig
var x: i32 = 10;
const p: *i32 = &x;          // pointer to a mutable i32
p.* = 20;                       // dereference to read/write: x is now 20

const y: i32 = 5;
const q: *const i32 = &y;         // pointer to a const i32 — cannot write through q
// q.* = 10;                        // compile error: cannot assign through const pointer

std.debug.print("{}\n", .{p.*});      // print the pointed-to value
```

## Pointer Types

| Type | Meaning |
|---|---|
| `*T` | Pointer to exactly one mutable `T` |
| `*const T` | Pointer to exactly one immutable `T` |
| `[*]T` | Pointer to unknown number of `T` (C-style, no bounds info) |
| `[*]const T` | Same, but pointee is immutable |
| `?*T` | Optional pointer — may be `null` |
| `[]T` | Slice: pointer + length, mutable elements |
| `[]const T` | Slice: pointer + length, immutable elements |

## Optional Pointers (No Null Pointer Bugs by Default)

```zig
var maybe_ptr: ?*i32 = null;         // explicitly nullable
var value: i32 = 42;
maybe_ptr = &value;

if (maybe_ptr) |ptr| {                  // unwraps the optional inside the block
    std.debug.print("{}\n", .{ptr.*});
} else {
    std.debug.print("was null\n", .{});
}

const forced = maybe_ptr.?;               // force-unwrap; panics if null in safe builds
```

A plain `*T` in Zig can **never** be null — nullability must be opted into
via `?*T`. This eliminates an entire class of null-pointer bugs at the type
level, similar to Rust's `Option<&T>` or Crystal's nilable types.

## Slices (Pointer + Length, the Idiomatic Way to Handle Arrays)

```zig
const array = [_]i32{ 10, 20, 30, 40, 50 };
const slice: []const i32 = array[1..4];    // elements at index 1,2,3 -> {20,30,40}

std.debug.print("{}\n", .{slice.len});         // length is tracked, no separate variable needed
std.debug.print("{}\n", .{slice[0]});             // indexing into the slice

var mutable_arr = [_]i32{ 1, 2, 3 };
var mut_slice: []i32 = mutable_arr[0..2];
mut_slice[0] = 100;                                  // mutates mutable_arr[0]

const full_slice = array[0..];                          // slice covering the whole array
```

Slices carry their length, so bounds checking is automatic in
safety-checked builds — indexing out of range triggers a panic rather than
undefined behavior.

## Allocators: Explicit Memory Management

Zig has no global allocator. Every function that allocates takes an
`std.mem.Allocator` as an explicit parameter — you always know where memory
comes from.

```zig
const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();               // check for leaks when the program exits
    const allocator = gpa.allocator();

    const buffer = try allocator.alloc(u8, 100);   // allocate 100 bytes
    defer allocator.free(buffer);                     // free when this scope exits

    buffer[0] = 'A';
}
```

## Common Allocators

| Allocator | Use case |
|---|---|
| `std.heap.GeneralPurposeAllocator` | General purpose, leak/double-free detection in debug |
| `std.heap.page_allocator` | Directly requests pages from the OS, simple but coarse |
| `std.heap.ArenaAllocator` | Bump-allocate many objects, free them all at once |
| `std.heap.FixedBufferAllocator` | Allocate from a fixed, pre-existing stack/static buffer |
| `std.testing.allocator` | Used in tests; panics loudly on leaks |

## Arena Allocator (Free Everything at Once)

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();               // frees ALL allocations made through this arena
const allocator = arena.allocator();

const a = try allocator.alloc(u8, 10);
const b = try allocator.alloc(u8, 20);
// no need to free a or b individually — arena.deinit() handles it all
```

Arenas are ideal for short-lived batches of allocations (e.g. per-request
in a server, or a single compiler pass) where per-object bookkeeping is
unnecessary overhead.

## Allocating and Freeing Single Items vs Slices

```zig
const single = try allocator.create(i32);    // allocate one i32
defer allocator.destroy(single);                // free one i32
single.* = 42;

const many = try allocator.alloc(i32, 10);      // allocate a slice of 10 i32s
defer allocator.free(many);                        // free the whole slice
many[0] = 1;
```

## ArrayList: A Growable Slice

```zig
var list = std.ArrayList(i32).init(allocator);
defer list.deinit();

try list.append(1);
try list.append(2);
try list.append(3);

std.debug.print("{}\n", .{list.items.len});     // .items is the underlying slice
std.debug.print("{}\n", .{list.items[0]});

for (list.items) |item| {
    std.debug.print("{}\n", .{item});
}

_ = list.pop();               // remove and return the last item
try list.insert(0, 99);         // insert at a specific index
```

## HashMap: Key-Value Storage

```zig
var map = std.StringHashMap(i32).init(allocator);
defer map.deinit();

try map.put("apples", 5);
try map.put("bananas", 3);

if (map.get("apples")) |count| {
    std.debug.print("{}\n", .{count});
}

var it = map.iterator();
while (it.next()) |entry| {
    std.debug.print("{s}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
}
```

## Stack vs Heap: Where Values Live

```zig
fn stackExample() i32 {
    var local: i32 = 10;         // lives on the stack, freed when function returns
    return local;
}

fn heapExample(allocator: std.mem.Allocator) !*i32 {
    const heap_val = try allocator.create(i32);    // lives on the heap until freed
    heap_val.* = 10;
    return heap_val;
}
```

Returning a pointer to a stack-local variable is a compile error in Zig in
common cases — the compiler tracks lifetimes well enough to catch the most
obvious dangling-pointer mistakes, though it is not a full borrow checker
like Rust's.

## `defer` and `errdefer` for Cleanup

```zig
fn processFile(allocator: std.mem.Allocator) !void {
    const buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer);          // always runs when the function returns

    const resource = try acquireResource();
    errdefer releaseResource(resource);      // only runs if an error is returned after this point

    try doWorkThatMightFail(resource);
    releaseResource(resource);                 // normal cleanup on the success path
}
```

`defer` runs on every exit path (return or error). `errdefer` runs only if
the function exits via an error — useful for "clean up partially
constructed state" logic without duplicating cleanup code in every error
branch.

## Copying vs Aliasing

```zig
const a = [_]i32{ 1, 2, 3 };
const b = a;                     // arrays are value types: this COPIES all elements

var arr = [_]i32{ 1, 2, 3 };
const slice_of_arr = arr[0..];     // slices ALIAS the original memory, no copy
slice_of_arr[0] = 99;                 // this mutates arr[0] too
```

Arrays are value types (copied on assignment); slices and pointers alias
the original memory. Knowing which one you're holding is essential to
avoiding accidental copies or accidental aliasing bugs.

## memcpy / memset via std.mem

```bash
```

```zig
var dest: [5]u8 = undefined;
const src = [_]u8{ 1, 2, 3, 4, 5 };
std.mem.copyForwards(u8, &dest, &src);      // copy src into dest

var buf: [10]u8 = undefined;
@memset(&buf, 0);                              // zero-fill a buffer
```

## Common Pitfalls

- Forgetting to `defer allocator.free(...)` after `alloc`/`create` leaks
  memory — `std.testing.allocator` will catch this loudly in tests.
- Returning a slice that points into a stack-allocated array outlives the
  function call — the compiler catches some but not all of these cases.
- Mixing up `[*]T` (unknown length, C-style, unsafe indexing) with `[]T`
  (known length, bounds-checked) — prefer slices unless interfacing with C.
- Using `page_allocator` for many small allocations is wasteful; prefer
  `GeneralPurposeAllocator` or an arena for anything beyond a handful of
  large allocations.

## Tips

- Pass `std.mem.Allocator` as a parameter to any function that needs to
  allocate — this makes memory ownership visible in every signature.
- Prefer arenas for batches of short-lived allocations that all die
  together (e.g. one HTTP request, one compiler pass).
- Use `std.testing.allocator` in tests specifically because it panics on
  leaks, catching bugs that `page_allocator` would silently tolerate.
- Reach for slices (`[]T`) by default; only drop to raw pointers (`[*]T`)
  when interoperating with C APIs.
