# Crystal Functions

Crystal uses methods for behavior and supports blocks, procs, and strong return type inference.

## Function/Method Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `def name(args)` | Define instance/global-style method | `def add(a, b)` |
| Type annotations | Clarify argument/return contracts | `def add(a : Int32, b : Int32) : Int32` |
| Default args | Optional parameters | `def greet(name = "dev")` |
| Splat args `*args` | Variadic arguments | `def sum(*nums)` |
| Blocks `yield` | Callback-style extensibility | `def with_log; yield; end` |

## Common Built-ins Related to Functions

| Built-in | Purpose | Example |
| --- | --- | --- |
| `puts` / `print` | Output values | `puts value` |
| `raise` | Raise exception | `raise "bad input"` |
| `proc` / `->` | First-class callable | `adder = ->(x : Int32) { x + 1 }` |
| `tap` | Run block and return receiver | `value.tap { |v| puts v }` |
| `times` | Repeated execution block | `3.times { puts "hi" }` |

## Examples

```crystal
def transform(value : String, &block : String -> String)
  block.call(value)
end
puts transform("whale") { |v| v.upcase }
```
