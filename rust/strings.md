# Rust Strings

Rust provides `String` (owned) and `&str` (borrowed slice) for string handling.

## Common `String` / `str` Methods

| Method | Purpose | Example |
| --- | --- | --- |
| `len()` | Byte length | `s.len()` |
| `contains()` | Substring check | `s.contains("api")` |
| `starts_with()` / `ends_with()` | Prefix/suffix checks | `s.starts_with("pre")` |
| `find()` / `rfind()` | Locate substring index | `s.find('/')` |
| `split()` / `split_whitespace()` | Iterate split parts | `s.split(',')` |
| `replace()` / `replacen()` | Replacement helpers | `s.replace('_', "-")` |
| `trim()` / `trim_start()` / `trim_end()` | Trim whitespace | `s.trim()` |
| `to_uppercase()` / `to_lowercase()` | Case conversion | `s.to_lowercase()` |
| `push()` / `push_str()` | Append chars/text to `String` | `owned.push_str("!")` |
| `chars()` | Unicode scalar iteration | `for c in s.chars() {}` |

## Examples

```rust
let raw = " whale_pedia ";
let clean = raw.trim().replace('_', "-");
let parts: Vec<&str> = clean.split('-').collect();
```
