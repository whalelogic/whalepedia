# C Field Guide

C is a low-level, statically typed, compiled language that gives direct
control over memory and hardware. It underpins most operating systems,
compilers, and embedded systems.

## Compilation

```bash
gcc file.c -o program              # compile with GCC
clang file.c -o program              # compile with Clang
gcc -Wall -Wextra file.c -o program    # enable common warnings
gcc -O2 file.c -o program                # optimize for speed
gcc -g file.c -o program                   # include debug symbols
gcc -std=c11 file.c -o program               # target a specific C standard
gcc -c file.c -o file.o                        # compile to object file only
gcc file1.o file2.o -o program                   # link object files
gcc file.c -lm -o program                          # link math library
./program                                            # run the compiled binary
```

## Hello World

```c
#include <stdio.h>

int main(void) {
    printf("Hello, World!\n");
    return 0;
}
```

## Data Types

```c
int i = 42;                    // integer, typically 4 bytes
short s = 10;                    // short integer, at least 2 bytes
long l = 100000L;                  // long integer
long long ll = 10000000000LL;        // long long, at least 8 bytes
unsigned int u = 42u;                  // unsigned integer
float f = 3.14f;                         // single precision float
double d = 3.14159;                        // double precision float
char c = 'A';                                // single character
_Bool b = 1;                                   // boolean (C99+, or use stdbool.h)
size_t sz = sizeof(int);                         // unsigned type for sizes

#include <stdbool.h>
bool flag = true;                                  // requires stdbool.h
```

## Type Sizes and Limits

```c
#include <limits.h>
#include <float.h>

printf("%zu\n", sizeof(int));       // print size in bytes
printf("%d\n", INT_MAX);              // maximum int value
printf("%d\n", INT_MIN);                // minimum int value
printf("%f\n", DBL_MAX);                  // maximum double value
```

## Variables and Constants

```c
int x = 10;                     // mutable variable
const int y = 20;                 // constant, cannot be reassigned
#define PI 3.14159                 // preprocessor macro constant
static int counter = 0;              // retains value across function calls
extern int globalVar;                  // declared elsewhere, linked at compile time
```

## Operators

```c
int a = 10, b = 3;
a + b; a - b; a * b; a / b; a % b;        // arithmetic
a == b; a != b; a > b; a < b; a >= b; a <= b;  // comparison
a && b; a || b; !a;                          // logical
a & b; a | b; a ^ b; ~a; a << 1; a >> 1;       // bitwise
a += 1; a -= 1; a *= 2; a /= 2;                  // compound assignment
a++; a--; ++a; --a;                                // increment/decrement
```

## Control Flow

```c
if (x > 10) {
    printf("big\n");
} else if (x > 5) {
    printf("medium\n");
} else {
    printf("small\n");
}

switch (x) {
    case 1:
        printf("one\n");
        break;
    case 2:
    case 3:
        printf("two or three\n");
        break;
    default:
        printf("other\n");
}

int result = (x > 10) ? 1 : 0;      // ternary operator
```

## Loops

```c
for (int i = 0; i < 10; i++) {
    printf("%d\n", i);
}

int i = 0;
while (i < 5) {
    printf("%d\n", i);
    i++;
}

int j = 0;
do {
    printf("%d\n", j);
    j++;
} while (j < 5);

for (int i = 0; i < 5; i++) {
    if (i == 3) continue;    // skip this iteration
    if (i == 4) break;         // exit loop early
}
```

## Functions

```c
int add(int a, int b) {
    return a + b;
}

void printMessage(const char *msg) {   // no return value
    printf("%s\n", msg);
}

int add(int a, int b);        // function prototype/declaration
int main(void) {
    printf("%d\n", add(2, 3));
    return 0;
}
int add(int a, int b) { return a + b; }  // definition after use

int factorial(int n) {          // recursion
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
```

## Pointers

```c
int x = 10;
int *p = &x;              // p holds the address of x
printf("%d\n", *p);          // dereference: get value at address
*p = 20;                       // modify x through the pointer
printf("%p\n", (void*)p);        // print the address itself

int **pp = &p;                     // pointer to a pointer

void increment(int *n) {             // pass by reference
    (*n)++;
}
int val = 5;
increment(&val);                       // val is now 6

int *nullPtr = NULL;                     // null pointer, always check before use
if (nullPtr != NULL) {
    printf("%d\n", *nullPtr);
}
```

## Arrays

```c
int arr[5] = {1, 2, 3, 4, 5};
printf("%d\n", arr[0]);              // access first element
int len = sizeof(arr) / sizeof(arr[0]);  // number of elements

int matrix[2][3] = {{1, 2, 3}, {4, 5, 6}};  // 2D array
printf("%d\n", matrix[1][2]);

// Arrays decay to pointers when passed to functions
void printArray(int *arr, int len) {
    for (int i = 0; i < len; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}
printArray(arr, 5);
```

## Strings (Null-Terminated char Arrays)

```c
#include <string.h>

char str[] = "Hello, C!";
char buffer[50];

printf("%zu\n", strlen(str));           // length (excludes null terminator)
strcpy(buffer, str);                       // copy string
strcat(buffer, " More");                     // concatenate
if (strcmp(str, "Hello, C!") == 0) {           // compare strings
    printf("equal\n");
}
char *found = strstr(str, "C!");                 // find substring
char *token = strtok(str, ",");                    // tokenize by delimiter

// Safer bounded variants (recommended)
strncpy(buffer, str, sizeof(buffer) - 1);
strncat(buffer, " More", sizeof(buffer) - strlen(buffer) - 1);
snprintf(buffer, sizeof(buffer), "%s more", str);
```

## Structs

```c
struct Point {
    int x;
    int y;
};

struct Point p1 = {1, 2};
printf("%d, %d\n", p1.x, p1.y);

struct Point *pp = &p1;
printf("%d\n", pp->x);              // arrow operator for pointer-to-struct

typedef struct {
    char name[50];
    int age;
} Person;

Person alice = {"Alice", 30};
printf("%s is %d\n", alice.name, alice.age);
```

## Unions and Enums

```c
union Data {
    int i;
    float f;
    char str[20];
};                                  // all members share the same memory

union Data d;
d.i = 42;

enum Color { RED, GREEN, BLUE };      // RED=0, GREEN=1, BLUE=2 by default
enum Color c = GREEN;

enum Status { OK = 200, NOT_FOUND = 404 };  // explicit values
```

## Dynamic Memory Allocation

```c
#include <stdlib.h>

int *arr = malloc(5 * sizeof(int));      // allocate uninitialized memory
if (arr == NULL) {                          // always check allocation success
    fprintf(stderr, "allocation failed\n");
    exit(1);
}
arr[0] = 1;

int *zeroed = calloc(5, sizeof(int));       // allocate and zero-initialize

arr = realloc(arr, 10 * sizeof(int));         // resize existing allocation

free(arr);                                       // release memory
arr = NULL;                                        // avoid dangling pointer
```

## File I/O

```c
#include <stdio.h>

FILE *fp = fopen("file.txt", "r");    // open for reading
if (fp == NULL) {
    perror("fopen failed");
    return 1;
}

char line[256];
while (fgets(line, sizeof(line), fp) != NULL) {
    printf("%s", line);
}
fclose(fp);

FILE *out = fopen("output.txt", "w");   // open for writing (truncates)
fprintf(out, "Hello, %s!\n", "file");
fclose(out);

FILE *append = fopen("log.txt", "a");     // open for appending
fputs("new log entry\n", append);
fclose(append);
```

## Preprocessor Directives

```c
#include <stdio.h>              // include a header
#define MAX_SIZE 100               // define a macro constant
#define SQUARE(x) ((x) * (x))         // function-like macro
#ifdef DEBUG                             // conditional compilation
    printf("debug mode\n");
#endif
#ifndef HEADER_H
#define HEADER_H
// header guard contents
#endif
#pragma once                                // alternate header guard (compiler-specific)
```

## Format Specifiers for printf/scanf

| Specifier | Type |
|---|---|
| `%d` | int |
| `%u` | unsigned int |
| `%ld` | long |
| `%lld` | long long |
| `%f` | float / double |
| `%.2f` | double, 2 decimal places |
| `%c` | char |
| `%s` | string (char*) |
| `%p` | pointer |
| `%x` | hexadecimal |
| `%o` | octal |
| `%%` | literal percent sign |

## Reading Input

```c
int x;
scanf("%d", &x);                     // read an integer

char name[50];
scanf("%49s", name);                    // read a string (bounded, avoids overflow)

char line[100];
fgets(line, sizeof(line), stdin);          // read a full line safely
```

## Command-Line Arguments

```c
int main(int argc, char *argv[]) {
    for (int i = 0; i < argc; i++) {
        printf("Argument %d: %s\n", i, argv[i]);
    }
    return 0;
}
```

## Error Handling Patterns

```c
#include <errno.h>
#include <string.h>

FILE *fp = fopen("missing.txt", "r");
if (fp == NULL) {
    fprintf(stderr, "Error: %s\n", strerror(errno));
    return 1;
}

int divide(int a, int b, int *result) {
    if (b == 0) return -1;      // error code convention
    *result = a / b;
    return 0;                     // success
}
```

## Multi-File Projects

`math_utils.h`:

```c
#ifndef MATH_UTILS_H
#define MATH_UTILS_H

int add(int a, int b);
int multiply(int a, int b);

#endif
```

`math_utils.c`:

```c
#include "math_utils.h"

int add(int a, int b) { return a + b; }
int multiply(int a, int b) { return a * b; }
```

`main.c`:

```c
#include <stdio.h>
#include "math_utils.h"

int main(void) {
    printf("%d\n", add(2, 3));
    return 0;
}
```

```bash
gcc main.c math_utils.c -o program
```

## Makefile Example

```makefile
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -O2

program: main.o math_utils.o
	$(CC) $(CFLAGS) -o program main.o math_utils.o

main.o: main.c math_utils.h
	$(CC) $(CFLAGS) -c main.c

math_utils.o: math_utils.c math_utils.h
	$(CC) $(CFLAGS) -c math_utils.c

clean:
	rm -f *.o program
```

```bash
make            # build using the Makefile
make clean       # remove build artifacts
```

## Common Standard Library Headers

| Header | Purpose |
|---|---|
| `stdio.h` | Input/output (printf, scanf, file I/O) |
| `stdlib.h` | Memory allocation, conversions, exit |
| `string.h` | String manipulation |
| `math.h` | Math functions (link with `-lm`) |
| `ctype.h` | Character classification (isalpha, isdigit) |
| `time.h` | Date and time functions |
| `errno.h` | Error number reporting |
| `assert.h` | Runtime assertions |
| `stdbool.h` | Boolean type (C99+) |
| `stdint.h` | Fixed-width integer types (int32_t, uint8_t) |

## Debugging Tools

```bash
gdb ./program                 # interactive debugger
gdb --args ./program arg1       # debug with arguments
valgrind ./program                # detect memory leaks and errors
valgrind --leak-check=full ./program
gcc -fsanitize=address file.c -o program   # AddressSanitizer build
gcc -fsanitize=undefined file.c -o program   # UndefinedBehaviorSanitizer build
```

## Tips

- Always check the return value of `malloc`/`calloc`/`realloc` before use.
- Pair every `malloc`/`calloc` with a corresponding `free` to avoid leaks;
  set freed pointers to `NULL` to avoid dangling-pointer bugs.
- Prefer bounded string functions (`snprintf`, `strncpy`) over unbounded ones
  (`sprintf`, `strcpy`) to avoid buffer overflows.
- Compile with `-Wall -Wextra` and treat warnings as errors during
  development; most memory bugs surface as warnings first.
- Use `valgrind` or sanitizer builds (`-fsanitize=address`) to catch memory
  errors that don't crash immediately but corrupt state.
