# Ruby Strings

Ruby strings are mutable by default and include many built-in transformation helpers.

## Common `String` Methods

| Method | Purpose | Example |
| --- | --- | --- |
| `length` / `size` | String length | `s.length` |
| `include?` | Substring check | `s.include?('api')` |
| `start_with?` / `end_with?` | Prefix/suffix checks | `s.start_with?('pre')` |
| `[]` / `slice` | Extract substring | `s[0, 5]` |
| `split` | Split into array | `s.split(',')` |
| `gsub` / `sub` | Replace all/first match | `s.gsub('_', '-')` |
| `strip` / `lstrip` / `rstrip` | Trim whitespace | `s.strip` |
| `upcase` / `downcase` / `capitalize` | Case conversion | `s.capitalize` |
| `index` / `rindex` | Find position of substring | `s.index('/')` |
| `to_sym` / `intern` | Convert to symbol | `s.to_sym` |

## Examples

```ruby
raw = ' whale_pedia '
clean = raw.strip.gsub('_', '-')
parts = clean.split('-')
```
