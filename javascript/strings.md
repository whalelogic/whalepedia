# JavaScript Strings

JavaScript strings are immutable UTF-16 sequences with many built-in prototype methods.

## Common `String` Methods

| Method / Property | Purpose | Example |
| --- | --- | --- |
| `length` | Character count (UTF-16 code units) | `s.length` |
| `includes` | Substring check | `s.includes('api')` |
| `startsWith` / `endsWith` | Prefix/suffix checks | `s.startsWith('pre')` |
| `slice` / `substring` | Extract part of string | `s.slice(0, 5)` |
| `split` | Split into array | `s.split(',')` |
| `replace` / `replaceAll` | Replace first/all matches | `s.replaceAll('-', ' ')` |
| `trim` / `trimStart` / `trimEnd` | Remove surrounding whitespace | `s.trim()` |
| `toUpperCase` / `toLowerCase` | Case conversion | `s.toUpperCase()` |
| `indexOf` / `lastIndexOf` | Locate substring index | `s.indexOf('/')` |
| `match` / `matchAll` | Regex matching | `s.match(/\w+/g)` |

## Examples

```javascript
const raw = ' whale-pedia ';
const clean = raw.trim().replaceAll('-', ' ');
const words = clean.split(' ');
```
