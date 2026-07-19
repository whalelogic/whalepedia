# Go Strings

Go strings are immutable byte slices; most operations come from the `strings` package.

## Common `strings` Package Functions

| Function | Purpose | Example |
| --- | --- | --- |
| `len(s)` | Byte length | `len(s)` |
| `strings.Contains` | Substring check | `strings.Contains(s, "api")` |
| `strings.HasPrefix` / `HasSuffix` | Prefix/suffix checks | `strings.HasPrefix(s, "go")` |
| `strings.Split` / `SplitN` | Split into slices | `strings.Split(csv, ",")` |
| `strings.Join` | Join slices into string | `strings.Join(parts, "-")` |
| `strings.ReplaceAll` | Replace all matches | `strings.ReplaceAll(s, "_", "-")` |
| `strings.TrimSpace` / `Trim` | Trim whitespace/chars | `strings.TrimSpace(s)` |
| `strings.ToUpper` / `ToLower` | Case conversion | `strings.ToLower(s)` |
| `strings.Index` / `LastIndex` | Find substring position | `strings.Index(s, "/")` |
| `[]rune(s)` | Unicode-safe iteration/conversion | `for _, r := range []rune(s) {}` |

## Examples

```go
s := " whale_pedia "
clean := strings.TrimSpace(strings.ReplaceAll(s, "_", "-"))
parts := strings.Split(clean, "-")
```
