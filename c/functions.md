# C Functions

Function patterns and common C standard-library calls.

| Function Pattern | Description |
| --- | --- |
| Named function | Reusable unit with a stable name |
| Variadic function | Uses `...` with `stdarg.h` (`printf`, etc.) |
| Function pointer callback | Pass behavior to another function |
| Dispatcher function | Routes work based on flags/types |

| Common C Function | Purpose |
| --- | --- |
| `printf` / `fprintf` | Formatted output |
| `snprintf` | Safe formatted string write with size limit |
| `qsort` | Generic array sort with comparator callback |
| `bsearch` | Binary search with comparator callback |
| `perror` | Print readable error message from `errno` |

## Example

```c
int add(int a, int b) {
    return a + b;
}
```
