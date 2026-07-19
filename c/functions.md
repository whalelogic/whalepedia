# C Functions

C functions are declared with explicit signatures and often use standard library calls for core tasks.

## Function Syntax and Patterns

| Pattern | Purpose | Example |
| --- | --- | --- |
| `ret name(args);` | Forward declaration (prototype) | `int add(int a, int b);` |
| `ret name(args) {}` | Function definition | `int add(int a, int b) { return a+b; }` |
| `void` return | Procedure with no return value | `void log_msg(const char *s)` |
| Function pointer | Pass behavior as argument | `int (*cmp)(const void*, const void*)` |
| `static` function | Internal linkage/file scope | `static int parse(const char *s)` |

## Common Standard Library Functions

| Function | Purpose | Example |
| --- | --- | --- |
| `printf` / `fprintf` | Formatted output | `printf("%d\n", n)` |
| `snprintf` | Bounded formatted output | `snprintf(buf, sz, "%s", s)` |
| `malloc` / `calloc` / `free` | Dynamic memory lifecycle | `ptr = malloc(sz); free(ptr);` |
| `qsort` | Generic sorting | `qsort(arr, n, sizeof(int), cmp)` |
| `bsearch` | Binary search in sorted data | `bsearch(&key, arr, n, sz, cmp)` |

## Examples

```c
static int add(int a, int b) { return a + b; }
printf("sum=%d\n", add(2, 3));
```
