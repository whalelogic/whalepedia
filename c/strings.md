# C Strings

C string handling is mostly done through `string.h` and related byte-memory helpers.

## Common `string.h` / Related Functions

| Function | Purpose | Example |
| --- | --- | --- |
| `strlen` | Length (excluding null terminator) | `strlen(s)` |
| `strcmp` / `strncmp` | Lexicographic comparison | `strcmp(a, b)` |
| `strcpy` / `strncpy` | Copy string into buffer | `strncpy(dst, src, n)` |
| `strcat` / `strncat` | Append to destination buffer | `strncat(dst, src, n)` |
| `strchr` / `strrchr` | Find first/last character | `strchr(s, ':')` |
| `strstr` | Find substring | `strstr(s, "token")` |
| `strtok` | Tokenize by delimiter set | `strtok(line, ",")` |
| `snprintf` | Safe formatted write | `snprintf(buf, sz, "%d", n)` |
| `memcpy` / `memmove` | Copy byte ranges | `memmove(dst, src, len)` |
| `memset` | Fill memory with a byte value | `memset(buf, 0, sz)` |

## Examples

```c
char src[] = "whalepedia";
char dst[32];
snprintf(dst, sizeof(dst), "%s-%zu", src, strlen(src));
char *p = strstr(dst, "pedia");
```
