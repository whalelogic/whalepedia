# Ruby Functions

Ruby behavior is primarily expressed with methods, lambdas, and blocks.

## Method/Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `def name(args)` | Define method | `def add(a, b)` |
| Default args | Optional parameter values | `def greet(name = 'dev')` |
| Splat args `*args` | Variadic arguments | `def sum(*nums)` |
| Keyword args `name:` | Explicit named parameters | `def user(id:, active: true)` |
| Block/yield | Inject caller behavior | `def around; yield; end` |

## Common Built-in Functions/Kernel Methods

| Method | Purpose | Example |
| --- | --- | --- |
| `puts` / `print` / `p` | Output values | `puts value` |
| `raise` | Raise exception | `raise ArgumentError, 'bad'` |
| `loop` | Repeating execution with break | `loop { ... break }` |
| `format` / `%` | Format output strings | `format('%02d', n)` |
| `proc` / `lambda` | Create callable object | `handler = ->(x) { x * 2 }` |

## Examples

```ruby
def with_log(label)
  puts "start: #{label}"
  yield
ensure
  puts "done: #{label}"
end
```
