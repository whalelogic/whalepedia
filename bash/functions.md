# Bash Functions

Bash functions organize shell logic and are commonly paired with built-in command helpers.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `name() { ...; }` | Declare reusable function | `log() { printf '%s\n' "$1"; }` |
| `local var=value` | Scoped variables in function | `local count=0` |
| `return N` | Return status code (0 success) | `return 1` |
| `"$@"` | Forward all arguments safely | `run_all "$@"` |
| `$(func ...)` | Capture function output | `result=$(build_id)` |

## Built-in Commands Commonly Used in Functions

| Built-in | Purpose | Example |
| --- | --- | --- |
| `printf` | Safe output formatting | `printf 'id=%s\n' "$id"` |
| `read` | Read user input | `read -r name` |
| `test` / `[` | Conditional checks | `[ -f "$file" ]` |
| `declare` | Set attributes/types | `declare -i total=0` |
| `trap` | Cleanup on signals/exit | `trap cleanup EXIT` |

## Examples

```bash
greet() {
  local name="$1"
  printf 'hello, %s\n' "$name"
}

greet "whalepedia"
```
