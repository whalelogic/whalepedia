# Python Functions

Python functions are first-class objects with flexible argument models.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `def name(...)` | Standard function definition | `def add(a, b):` |
| Type hints | Declare expected types/contracts | `def add(a: int, b: int) -> int:` |
| Default args | Optional values | `def greet(name='dev'):` |
| `*args` / `**kwargs` | Variadic positional/keyword args | `def f(*args, **kwargs):` |
| `lambda` | Small anonymous function | `lambda x: x * 2` |

## Common Built-in Functions

| Built-in | Purpose | Example |
| --- | --- | --- |
| `print` | Output values | `print(value)` |
| `len` | Collection/string length | `len(items)` |
| `map` / `filter` | Functional transforms/filters | `map(str, nums)` |
| `enumerate` | Index + value iteration | `enumerate(items, start=1)` |
| `zip` | Parallel iteration over iterables | `zip(a, b)` |
| `sum` / `min` / `max` | Aggregate values | `sum(scores)` |

## Examples

```python
def transform(values: list[int], fn):
    return [fn(v) for v in values]
```
