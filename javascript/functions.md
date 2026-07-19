# JavaScript Functions

JavaScript functions are first-class values and power callbacks, async flows, and composition.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| Function declaration | Hoisted named function | `function add(a, b) { return a + b; }` |
| Function expression | Assign function to variable | `const add = function(a, b) { ... }` |
| Arrow function | Concise lexical-`this` function | `const add = (a, b) => a + b;` |
| Default params | Optional argument defaults | `function f(x = 0) {}` |
| Rest params `...args` | Variadic arguments | `function sum(...args) {}` |

## Common Built-ins Used with Functions

| API | Purpose | Example |
| --- | --- | --- |
| `setTimeout` / `setInterval` | Schedule callbacks | `setTimeout(fn, 500)` |
| `Array.prototype.map` | Transform collection with callback | `arr.map(x => x * 2)` |
| `Array.prototype.filter` | Select values by predicate | `arr.filter(x => x > 0)` |
| `Promise.then` / `catch` | Async callback chaining | `fetch().then(parse).catch(handle)` |
| `Function.prototype.bind` | Bind `this` and preset args | `handler.bind(ctx)` |

## Examples

```javascript
const withLog = (fn) => (...args) => {
  console.log('calling', fn.name);
  return fn(...args);
};
```
