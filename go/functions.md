# Go Functions

Go functions are statically typed, support multiple returns, and are central to error-first design.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `func name(args) ret` | Standard declaration | `func Add(a, b int) int` |
| Multiple returns | Return value + error/state | `func Parse(s string) (int, error)` |
| Named returns | Documented return variables | `func Split() (head, tail string)` |
| Variadic `...T` | Accept variable arg count | `func Sum(nums ...int) int` |
| Anonymous/closure | Inline behavior with captured vars | `fn := func(x int) int { return x * 2 }` |

## Common Built-in Functions

| Built-in | Purpose | Example |
| --- | --- | --- |
| `len` / `cap` | Length/capacity of collections | `len(items)` |
| `make` | Initialize slices/maps/channels | `make([]int, 0, 8)` |
| `new` | Allocate zeroed value | `new(MyType)` |
| `append` | Grow slices | `append(nums, 10)` |
| `copy` / `delete` | Copy slices / remove map keys | `delete(m, "k")` |
| `panic` / `recover` | Exceptional control flow | `defer func(){ _ = recover() }()` |

## Examples

```go
func Divide(a, b float64) (float64, error) {
	if b == 0 { return 0, fmt.Errorf("divide by zero") }
	return a / b, nil
}
```
