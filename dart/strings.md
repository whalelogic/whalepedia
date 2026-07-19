# Dart Strings

Dart strings are immutable UTF-16 code-unit sequences with rich helpers on `String`.

## Common `String` Methods

| Method / Property | Purpose | Example |
| --- | --- | --- |
| `length` | Code unit length | `s.length` |
| `contains` | Substring/regex check | `s.contains('api')` |
| `startsWith` / `endsWith` | Prefix/suffix checks | `s.startsWith('pre')` |
| `substring` | Extract section | `s.substring(0, 5)` |
| `split` | Split into list | `s.split(',')` |
| `replaceAll` / `replaceFirst` | Replacement helpers | `s.replaceAll('-', ' ')` |
| `toUpperCase` / `toLowerCase` | Case conversion | `s.toUpperCase()` |
| `trim` / `trimLeft` / `trimRight` | Whitespace trimming | `s.trim()` |
| `padLeft` / `padRight` | Width padding | `id.padLeft(6, '0')` |
| `indexOf` / `lastIndexOf` | Position search | `s.indexOf('x')` |

## Examples

```dart
final raw = ' whale-pedia ';
final clean = raw.trim().replaceAll('-', ' ');
print(clean.split(' '));
```
