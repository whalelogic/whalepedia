# Nim Objects

This guide summarizes common member patterns for this language.

| Concept | Description | Example |
| --- | --- | --- |
| Field/Property | Stores state | `name`, `count` |
| Method | Behavior attached to type/object | `save()`, `toString()` |
| Constructor/Initializer | Creates new value | `new Type(...)` or equivalent |
| Composition | Build larger types from smaller ones | embedded members |

## Example

```text
Type { field, method }
```
