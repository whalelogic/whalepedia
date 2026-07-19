# Crystal Strings

Crystal strings are UTF-8 and provide Ruby-like methods with strong typing.

## Core String Methods

| Method | Purpose | Example |
| --- | --- | --- |
| `size` | Character count | `s.size` |
| `bytesize` | Byte length | `s.bytesize` |
| `includes?` | Substring check | `s.includes?("api")` |
| `starts_with?` / `ends_with?` | Prefix/suffix checks | `s.starts_with?("pre")` |
| `upcase` / `downcase` | Case conversion | `s.upcase` |
| `capitalize` | Capitalize first character | `s.capitalize` |
| `split` | Split into array | `s.split(",")` |
| `gsub` / `sub` | Replace all/first matches | `s.gsub("-", " ")` |
| `strip` / `lstrip` / `rstrip` | Trim whitespace | `s.strip` |
| `chars` | Convert to character array | `s.chars` |

## Examples

```crystal
s = " whale-pedia "
puts s.strip.gsub("-", " ").capitalize
puts s.includes?("pedia")
```
