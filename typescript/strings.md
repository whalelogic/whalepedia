# TypeScript Strings

TypeScript uses JavaScript `String` methods with compile-time type safety.

## Common `String` Methods

| Method / Property | Purpose | Example |
| --- | --- | --- |
| `length` | Character count (UTF-16 code units) | `s.length` |
| `includes` | Substring check | `s.includes('api')` |
| `startsWith` / `endsWith` | Prefix/suffix checks | `s.startsWith('pre')` |
| `slice` / `substring` | Extract section | `s.slice(0, 5)` |
| `split` | Split into array | `s.split(',')` |
| `replace` / `replaceAll` | Replace first/all matches | `s.replaceAll('_', '-')` |
| `trim` / `trimStart` / `trimEnd` | Remove surrounding whitespace | `s.trim()` |
| `toUpperCase` / `toLowerCase` | Case conversion | `s.toUpperCase()` |
| `indexOf` / `lastIndexOf` | Find index of match | `s.indexOf('/')` |
| `match` / `matchAll` | Regex matching | `s.match(/\w+/g)` |

## Examples

```ts
const raw: string = ' whale_pedia ';
const clean = raw.trim().replaceAll('_', '-');
const parts = clean.split('-');
```
