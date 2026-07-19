# Dart Functions

Dart functions are first-class values with optional named parameters and strong static typing.

## Function Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `T name(...) {}` | Typed function declaration | `int add(int a, int b) => a + b;` |
| Arrow syntax `=>` | Concise single-expression function | `String label(x) => 'id:$x';` |
| Optional positional `[]` | Optional ordered parameters | `f(int a, [int b = 0])` |
| Named params `{}` | Self-documenting call sites | `g({required String name})` |
| `typedef` / function type | Reusable callable signatures | `typedef Mapper = String Function(String);` |

## Common Built-in Function Helpers

| Helper | Purpose | Example |
| --- | --- | --- |
| `print` | Console output | `print(value)` |
| `assert` | Runtime contract in debug mode | `assert(count >= 0)` |
| `Function.apply` | Dynamic invocation | `Function.apply(fn, [1, 2])` |
| `map` / `where` (iterables) | Functional transforms/filters | `items.map((x) => x * 2)` |
| `Future.then` | Async function chaining | `fetch().then(handle)` |

## Examples

```dart
String formatUser(String name, {bool excited = false}) {
  return excited ? '$name!' : name;
}
print(formatUser('whale', excited: true));
```
