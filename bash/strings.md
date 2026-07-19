# Bash Strings

Bash treats strings as byte sequences and relies on parameter expansion and core tools for manipulation.

## Built-in String Operations

| Operation | Purpose | Example |
| --- | --- | --- |
| `${#s}` | String length | `${#name}` |
| `${s:offset:length}` | Substring extraction | `${name:0:5}` |
| `${s/pat/repl}` | Replace first match | `${path/home/opt}` |
| `${s//pat/repl}` | Replace all matches | `${csv//,/ }` |
| `${s#prefix}` / `${s##prefix}` | Remove shortest/longest prefix match | `${url#https://}` |
| `${s%suffix}` / `${s%%suffix}` | Remove shortest/longest suffix match | `${file%.txt}` |
| `${s^}` / `${s^^}` | Uppercase first/all chars | `${word^^}` |
| `${s,}` / `${s,,}` | Lowercase first/all chars | `${word,,}` |
| `[[ $s == *pat* ]]` | Contains/pattern match | `[[ $msg == *error* ]]` |
| `printf '%s' "$s"` | Safe string output/formatting | `printf 'user=%s\n' "$user"` |

## Examples

```bash
name="whale_pedia"
echo "len=${#name}"
echo "prefix removed: ${name#whale_}"
echo "replace: ${name/_/-}"
echo "upper: ${name^^}"
```
