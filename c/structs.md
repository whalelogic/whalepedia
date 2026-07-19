# C Structs

How C structs model data and composition.

| Concept | Description | Example |
| --- | --- | --- |
| Field | Stores state in a record | `name`, `count` |
| Initializer | Assigns initial values | `(Point){.x = 1, .y = 2}` |
| Function pointer field | Associates behavior via callback | `int (*cmp)(const void*, const void*)` |
| Nested struct | Composes larger records | `struct Address` inside `struct User` |

## Example

```c
struct Point {
    int x;
    int y;
};
```
