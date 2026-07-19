# TypeScript Functions

TypeScript extends JavaScript functions with static types, overloads, and richer signatures.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `function name(...)` | Named function declaration | `function add(a: number, b: number): number` |
| Arrow function | Concise lexical-`this` function | `const add = (a: number, b: number) => a + b` |
| Optional params `?` | Optional argument support | `fn(x: string, y?: number)` |
| Default params | Provide default values | `fn(limit = 10)` |
| Rest params `...args` | Variadic arguments | `fn(...ids: string[])` |
| Function overloads | Multiple call signatures | `function parse(x: string): number; ...` |

## Common Built-ins Used with Functions

| API | Purpose | Example |
| --- | --- | --- |
| `setTimeout` / `setInterval` | Schedule callback execution | `setTimeout(run, 500)` |
| `Array.map` / `filter` / `reduce` | Functional transforms/aggregation | `items.reduce(sum, 0)` |
| `Promise.then` / `catch` / `finally` | Async chaining and recovery | `fetch().then(parse).catch(handle)` |
| `bind` / `call` / `apply` | Control invocation context | `fn.bind(ctx)` |
| `console.log` / `console.error` | Logging and diagnostics | `console.error(err)` |

## Examples

```ts
type Mapper<T, U> = (value: T) => U;
const transform = <T, U>(values: T[], fn: Mapper<T, U>): U[] => values.map(fn);
```
