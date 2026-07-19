# Python Strings

Python strings are immutable Unicode sequences with a rich method set.

## Common `str` Methods

| Method / Function | Purpose | Example |
| --- | --- | --- |
| `len(s)` | Length | `len(s)` |
| `in` | Substring membership | `'api' in s` |
| `startswith` / `endswith` | Prefix/suffix checks | `s.startswith('pre')` |
| `find` / `rfind` | Locate substring index | `s.find('/')` |
| `split` / `rsplit` | Split into list | `s.split(',')` |
| `join` | Join iterable into string | `'-'.join(parts)` |
| `replace` | Replace all occurrences | `s.replace('_', '-')` |
| `strip` / `lstrip` / `rstrip` | Trim whitespace/chars | `s.strip()` |
| `upper` / `lower` / `title` | Case transforms | `s.title()` |
| `format` / f-strings | String formatting | `f"user={name}"` |

## Examples

```python
raw = " whale_pedia "
clean = raw.strip().replace("_", "-")
parts = clean.split("-")
```
