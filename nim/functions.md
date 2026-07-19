# Nim Functions

Nim distinguishes between `proc`, `func`, `method`, and iterator-style callable constructs.

## Function/Callable Patterns

| Construct | Purpose | Example |
| --- | --- | --- |
| `proc` | General procedure (can have side effects) | `proc add(a, b: int): int = a + b` |
| `func` | Side-effect-free function (enforced) | `func sq(x: int): int = x * x` |
| `method` | Dynamically dispatched routine | `method draw(s: Shape)` |
| `iterator` | Lazy-yield sequence values | `iterator nums(): int = ...` |
| `template` | Compile-time code expansion | `template log(x) = echo x` |

## Common Built-ins and Routine Helpers

| Routine | Purpose | Example |
| --- | --- | --- |
| `echo` | Output values | `echo value` |
| `assert` / `doAssert` | Validate assumptions | `doAssert n >= 0` |
| `len` / `high` / `low` | Collection/index helpers | `len(items)` |
| `mapIt` / `filterIt` | Functional sequence transforms | `items.mapIt(it * 2)` |
| `try/except` + `raise` | Error handling flow | `raise newException(...)` |

## Examples

```nim
proc transform(values: seq[int], op: proc (x: int): int): seq[int] =
  result = values.map(op)
```
