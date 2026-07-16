# Zig: Testing & the Build System

Testing is a first-class, built-in language feature (`test` blocks compiled
directly into your source files), and `build.zig` is a real Zig program
that describes how to build your project — there is no separate DSL or
external build tool required.

## Writing Tests

```zig
const std = @import("std");
const testing = std.testing;

fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "addition works" {
    try testing.expectEqual(@as(i32, 5), add(2, 3));
}

test "addition with negatives" {
    try testing.expectEqual(@as(i32, -1), add(2, -3));
}
```

A `test "name" { ... }` block is compiled only when running `zig test`, and
is otherwise entirely absent from normal builds — no runtime cost, no
separate test framework dependency.

## Running Tests

```bash
zig test file.zig                    # compile and run all tests in a file
zig test file.zig --test-filter add    # run only tests whose name contains "add"
zig build test                          # run tests defined via build.zig (project-wide)
```

## Assertion Functions in `std.testing`

```zig
const testing = std.testing;

try testing.expect(1 + 1 == 2);                          // generic boolean assertion
try testing.expectEqual(@as(i32, 4), 2 + 2);                // equality (types must match exactly)
try testing.expectEqualStrings("hello", "hello");              // string equality
try testing.expectEqualSlices(i32, &.{ 1, 2 }, &.{ 1, 2 });       // slice equality
try testing.expectError(error.OutOfMemory, failingFunction());     // expects a specific error
try testing.expect(false);                                            // fails the test unconditionally
```

`expectEqual` requires both sides to already be the same type, which is why
`@as(i32, 4)` appears frequently — it's coercing an integer literal to
match the type being compared against.

## Testing Errors

```zig
const MyError = error{Invalid};

fn validate(x: i32) MyError!void {
    if (x < 0) return MyError.Invalid;
}

test "validate rejects negative numbers" {
    try testing.expectError(MyError.Invalid, validate(-1));
}

test "validate accepts positive numbers" {
    try validate(5);       // no error expected; test fails if this returns an error
}
```

## Testing with Allocators (Leak Detection)

```zig
test "no memory leaks" {
    const allocator = testing.allocator;      // panics loudly if anything isn't freed

    const buffer = try allocator.alloc(u8, 10);
    defer allocator.free(buffer);               // remove this line and the test fails on leak

    buffer[0] = 42;
    try testing.expectEqual(@as(u8, 42), buffer[0]);
}
```

`std.testing.allocator` is a `GeneralPurposeAllocator` configured to fail
the test explicitly if any allocation isn't freed by the time the test
ends — this catches leaks automatically without a separate tool.

## Setup and Teardown Patterns

Zig has no dedicated "beforeEach"/"afterEach" hooks; the idiomatic pattern
is a small helper function plus `defer`.

```zig
fn setupTestData(allocator: std.mem.Allocator) !std.ArrayList(i32) {
    var list = std.ArrayList(i32).init(allocator);
    try list.appendSlice(&.{ 1, 2, 3 });
    return list;
}

test "list operations" {
    var list = try setupTestData(testing.allocator);
    defer list.deinit();

    try testing.expectEqual(@as(usize, 3), list.items.len);
}
```

## Testing Structs and Methods

```zig
const Counter = struct {
    count: i32 = 0,

    fn increment(self: *Counter) void {
        self.count += 1;
    }
};

test "counter increments" {
    var counter = Counter{};
    counter.increment();
    counter.increment();
    try testing.expectEqual(@as(i32, 2), counter.count);
}
```

## The Build System: `build.zig`

`build.zig` is an ordinary Zig source file containing a `build` function
that the `zig build` command executes. There is no separate configuration
language — the build script is compiled and run just like any other Zig
program.

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

```bash
zig build             # builds according to build.zig, output in zig-out/
zig build run           # builds and immediately runs the "run" step defined above
zig build -Doptimize=ReleaseFast    # pass build options
```

## Adding a Test Step to build.zig

```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_tests.step);
}
```

```bash
zig build test          # now runs all `test` blocks across the project
```

## Declaring a Library

```zig
const lib = b.addStaticLibrary(.{
    .name = "mylib",
    .root_source_file = b.path("src/lib.zig"),
    .target = target,
    .optimize = optimize,
});
b.installArtifact(lib);

// Or a shared/dynamic library:
const shared_lib = b.addSharedLibrary(.{
    .name = "mylib",
    .root_source_file = b.path("src/lib.zig"),
    .target = target,
    .optimize = optimize,
});
```

## Adding Dependencies (build.zig.zon)

Zig's package manager tracks dependencies in `build.zig.zon` (Zig Object
Notation), referenced from `build.zig`.

```zig
// build.zig.zon
.{
    .name = "myapp",
    .version = "0.1.0",
    .dependencies = .{
        .somepkg = .{
            .url = "https://github.com/user/somepkg/archive/refs/tags/v1.0.0.tar.gz",
            .hash = "1220abcdef...",
        },
    },
}
```

```zig
// build.zig
const somepkg_dep = b.dependency("somepkg", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("somepkg", somepkg_dep.module("somepkg"));
```

```bash
zig fetch --save https://github.com/user/somepkg/archive/refs/tags/v1.0.0.tar.gz
```

`zig fetch --save` downloads a dependency, computes its hash, and writes
the entry into `build.zig.zon` automatically.

## Optimization Modes

| Mode | Behavior |
|---|---|
| `Debug` | No optimizations, all safety checks on, fastest compile |
| `ReleaseSafe` | Optimized, safety checks (bounds, overflow) still on |
| `ReleaseFast` | Optimized, safety checks off, maximum speed |
| `ReleaseSmall` | Optimized for binary size, safety checks off |

```bash
zig build -Doptimize=Debug
zig build -Doptimize=ReleaseSafe
zig build -Doptimize=ReleaseFast
zig build -Doptimize=ReleaseSmall
```

## Cross-Compilation

```bash
zig build -Dtarget=x86_64-linux
zig build -Dtarget=aarch64-macos
zig build -Dtarget=x86_64-windows
zig targets                            # list all supported target triples
```

Cross-compilation is a built-in, first-class feature — Zig ships its own
bundled libc implementations for common targets, so cross-compiling C or
Zig code to another OS/architecture typically requires no extra toolchain
installation.

## Project Layout Convention

```
myapp/
├── build.zig
├── build.zig.zon
├── src/
│   └── main.zig
└── zig-out/            # build output, created by `zig build`
    └── bin/
        └── myapp
```

## Common `zig build` Invocations

```bash
zig build                      # default build step
zig build run                    # run the "run" step (if defined)
zig build test                     # run the "test" step (if defined)
zig build --help                     # list all steps defined by build.zig
zig build -Dtarget=wasm32-freestanding   # cross-compile to WebAssembly
```

## Tips

- Tests live directly next to the code they test, in the same file — there
  is no expectation of a separate `tests/` directory for unit tests,
  though larger integration tests may still live separately.
- `std.testing.allocator` should be your default allocator in tests
  specifically because it makes leaks a hard test failure instead of a
  silent bug.
- `build.zig` being real Zig code means you can use loops, conditionals,
  and helper functions to describe complex build graphs — there's no
  templating language limitation to work around.
- Use `zig build --help` on an unfamiliar project to discover what custom
  steps (`run`, `test`, `docs`, etc.) its `build.zig` defines.
