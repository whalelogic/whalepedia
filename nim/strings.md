# Nim Strings

Nim strings are mutable sequences of bytes with many helpers in `strutils`.

## Common String/`strutils` Routines

| Routine | Purpose | Example |
| --- | --- | --- |
| `len(s)` | Length | `len(s)` |
| `contains` | Substring check | `s.contains("api")` |
| `startsWith` / `endsWith` | Prefix/suffix checks | `s.startsWith("pre")` |
| `substr` | Extract substring | `s.substr(0, 4)` |
| `split` | Split into sequence | `s.split(",")` |
| `join` | Join sequence into string | `parts.join("-")` |
| `replace` | Replace substring | `s.replace("_", "-")` |
| `strip` | Trim whitespace/chars | `s.strip()` |
| `toUpperAscii` / `toLowerAscii` | ASCII case conversion | `s.toLowerAscii()` |
| `find` / `rfind` | Locate index of match | `s.find("/")` |

## Examples

```nim
import strutils
let raw = " whale_pedia "
let clean = raw.strip().replace("_", "-")
let parts = clean.split("-")
```
