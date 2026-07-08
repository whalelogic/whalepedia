# Go Data Types & Standard Library Types — Comprehensive Reference

> Covers every built-in primitive, all composite type forms, and the most significant named types across the Go standard library. Go 1.21+.

---

## Table of Contents

1. [Primitive / Built-in Types](#1-primitive--built-in-types)
   - [Boolean](#boolean)
   - [Integer Types](#integer-types)
   - [Floating-Point Types](#floating-point-types)
   - [Complex Types](#complex-types)
   - [string](#string)
   - [byte](#byte)
   - [rune](#rune)
   - [error](#error)
   - [any](#any)
   - [comparable](#comparable)
2. [Composite Types](#2-composite-types)
   - [Array](#array)
   - [Slice](#slice)
   - [Map](#map)
   - [Struct](#struct)
   - [Pointer](#pointer)
   - [Function Type](#function-type)
   - [Interface](#interface)
   - [Channel](#channel)
3. [strings Package](#3-strings-package)
4. [bytes Package](#4-bytes-package)
5. [bufio Package](#5-bufio-package)
6. [regexp Package](#6-regexp-package)
7. [fmt Package](#7-fmt-package)
8. [errors Package](#8-errors-package)
9. [sort & slices Packages](#9-sort--slices-packages)
10. [sync Package](#10-sync-package)
11. [sync/atomic Package](#11-syncatomic-package)
12. [context Package](#12-context-package)
13. [time Package](#13-time-package)
14. [os Package](#14-os-package)
15. [net Package](#15-net-package)
16. [net/http Package](#16-nethttp-package)
17. [net/url Package](#17-neturl-package)
18. [encoding/json Package](#18-encodingjson-package)
19. [math/big Package](#19-mathbig-package)
20. [reflect Package](#20-reflect-package)
21. [database/sql Package](#21-databasesql-package)
22. [log/slog Package](#22-logslog-package)
23. [container Package](#23-container-package)
24. [Quick Index](#24-quick-index)

---

## 1. Primitive / Built-in Types

---

### Boolean

#### `bool`

Represents a truth value. The zero value is `false`. Boolean expressions are the only values accepted by `if`, `for`, and `&&`/`||` — Go has no implicit numeric truthiness.

```go
var active bool        // false (zero value)
enabled := true
flag := x > 0 && y != nil

// Booleans are not integers — this does NOT compile:
// if 1 { }
// if ptr { }  — must be: if ptr != nil { }
```

---

### Integer Types

Go has both sized and architecture-dependent integer types. All integer types have defined zero values of `0`.

| Type | Size | Range |
|---|---|---|
| `int8` | 8-bit signed | −128 to 127 |
| `int16` | 16-bit signed | −32,768 to 32,767 |
| `int32` | 32-bit signed | −2,147,483,648 to 2,147,483,647 |
| `int64` | 64-bit signed | −9.2×10¹⁸ to 9.2×10¹⁸ |
| `int` | Platform-sized signed | 32-bit on 32-bit systems; 64-bit on 64-bit systems |
| `uint8` | 8-bit unsigned | 0 to 255 |
| `uint16` | 16-bit unsigned | 0 to 65,535 |
| `uint32` | 32-bit unsigned | 0 to 4,294,967,295 |
| `uint64` | 64-bit unsigned | 0 to 1.8×10¹⁹ |
| `uint` | Platform-sized unsigned | 32 or 64-bit |
| `uintptr` | Unsigned, pointer-sized | Large enough to hold any pointer value |

> **Rule of thumb:** Use `int` for general-purpose counters, indices, and sizes unless you have a specific reason for a sized type (e.g., binary I/O, protocol parsing, memory layout).

```go
var count int = 0
var age uint8 = 30
var offset int64 = -1_000_000

// Integer literals
dec  := 255
hex  := 0xFF
oct  := 0o377
bin  := 0b11111111
big  := 1_000_000   // underscores for readability

// Conversion is always explicit
var x int32 = 42
var y int64 = int64(x)   // must cast

// Overflow wraps silently (no panic)
var b uint8 = 255
b++   // b is now 0

// math/bits constants for sized bounds
import "math"
fmt.Println(math.MaxInt8)    // 127
fmt.Println(math.MinInt64)   // -9223372036854775808
fmt.Println(math.MaxUint32)  // 4294967295
```

#### `uintptr`

An integer type wide enough to hold the bit pattern of any pointer. It is not a pointer — the garbage collector does not trace it. Used only for unsafe low-level operations.

```go
import "unsafe"

x := 42
ptr := uintptr(unsafe.Pointer(&x))   // raw address as integer
// Do not store uintptr long-term; GC may move x
```

---

### Floating-Point Types

#### `float32`

Single-precision IEEE 754 floating-point. ~7 significant decimal digits of precision. 32 bits.

```go
var temp float32 = 98.6
const pi32 float32 = 3.14159265
```

#### `float64`

Double-precision IEEE 754 floating-point. ~15–17 significant decimal digits of precision. 64 bits. **This is the default floating-point type in Go** — untyped float literals default to `float64`.

```go
var ratio float64 = 1.6180339887
pi := 3.141592653589793   // inferred as float64

import "math"
fmt.Println(math.MaxFloat64)   // 1.7976931348623157e+308
fmt.Println(math.SmallestNonzeroFloat64)
fmt.Println(math.IsNaN(math.NaN()))   // true
fmt.Println(math.IsInf(1/0.0, 1))     // true

// Precision comparison: never use == for floats
const epsilon = 1e-9
if math.Abs(a-b) < epsilon {
    // considered equal
}
```

---

### Complex Types

#### `complex64`

A complex number with `float32` real and imaginary parts.

```go
var c complex64 = 1 + 2i
```

#### `complex128`

A complex number with `float64` real and imaginary parts. The default complex type.

```go
c := 3.0 + 4.0i            // complex128
r := real(c)               // 3.0
i := imag(c)               // 4.0
c2 := complex(1.0, -1.0)   // construct from parts

import "math/cmplx"
fmt.Println(cmplx.Abs(c))     // 5.0 (magnitude)
fmt.Println(cmplx.Sqrt(-1))   // (0+1i)
```

---

### `string`

An immutable sequence of bytes. Strings in Go are not required to contain valid UTF-8, but string literals are always valid UTF-8. The zero value is `""`.

```go
var s string               // ""
name := "Hello, 世界"

// Length is in bytes, not characters
fmt.Println(len(name))     // 13 (not 9)

// Index returns a byte
fmt.Println(name[0])       // 72 (byte value of 'H')

// Range iterates over Unicode code points (runes)
for i, r := range name {
    fmt.Printf("%d: %c (%d)\n", i, r, r)
}

// Substring (still byte-indexed)
sub := name[7:13]          // "世界"

// Strings are immutable — assignment copies the header
a := "hello"
b := a
b = "world"   // a is still "hello"

// Concatenation: use strings.Builder for many joins
result := "foo" + "bar"

// Raw string literals: no escape interpretation
raw := `Line 1\nLine 2\t still literal`

// String ↔ []byte conversion (copies memory)
data := []byte(name)
back := string(data)

// String ↔ []rune conversion
runes := []rune(name)
fmt.Println(len(runes))    // 9 (character count)
```

---

### `byte`

An alias for `uint8`. Used to represent a single byte of data, particularly in I/O and binary operations. Interchangeable with `uint8` at the type level.

```go
var b byte = 'A'   // 65
data := []byte{72, 101, 108, 108, 111}
fmt.Println(string(data))   // "Hello"

// byte and uint8 are identical
var x uint8 = 200
var y byte = x    // no conversion needed
```

---

### `rune`

An alias for `int32`. Represents a Unicode code point. Used whenever you need to operate on characters rather than bytes.

```go
var r rune = '世'   // 19990
fmt.Printf("%c %d %U\n", r, r, r)   // 世 19990 U+4E16

// Rune literals use single quotes
letter := 'A'           // rune, value 65
emoji  := '🐹'          // rune, value 128057

import "unicode"
fmt.Println(unicode.IsLetter(r))    // true
fmt.Println(unicode.IsUpper('A'))   // true
fmt.Println(unicode.ToLower('Z'))   // 'z'
```

---

### `error`

The built-in error interface. Any type implementing `Error() string` satisfies it. The zero value `nil` indicates no error.

```go
type error interface {
    Error() string
}

// Creating errors
err1 := errors.New("something went wrong")
err2 := fmt.Errorf("failed to open %s: %w", path, err1)

// Custom error type
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}

// Checking errors
if err != nil { ... }

// Unwrapping (errors.Is traverses the chain)
if errors.Is(err, os.ErrNotExist) { ... }

// Extracting typed errors
var ve *ValidationError
if errors.As(err, &ve) {
    fmt.Println("Field:", ve.Field)
}
```

---

### `any`

An alias for `interface{}` introduced in Go 1.18. Holds a value of any type. Requires a type assertion or type switch to use the underlying value.

```go
var v any = 42
v = "now a string"
v = []int{1, 2, 3}

// Type assertion (panics if wrong type)
s := v.(string)

// Safe type assertion
s, ok := v.(string)
if !ok {
    fmt.Println("not a string")
}

// Type switch
switch t := v.(type) {
case int:
    fmt.Println("int:", t)
case string:
    fmt.Println("string:", t)
case []int:
    fmt.Println("slice:", t)
default:
    fmt.Printf("unknown: %T\n", t)
}
```

---

### `comparable`

A built-in constraint (introduced in Go 1.18) satisfied by any type that supports `==` and `!=`. Used as a type parameter constraint. All primitive types, arrays of comparable types, structs with all comparable fields, pointers, channels, and interfaces are `comparable`. Slices, maps, and functions are not.

```go
func Contains[T comparable](slice []T, item T) bool {
    for _, v := range slice {
        if v == item {
            return true
        }
    }
    return false
}

Contains([]int{1, 2, 3}, 2)         // true
Contains([]string{"a", "b"}, "c")   // false
```

---

## 2. Composite Types

---

### Array

A fixed-length, ordered sequence of elements of a single type. The length is part of the type — `[3]int` and `[4]int` are distinct types. Arrays are value types; assignment copies the entire array.

```go
// Declaration and initialization
var a [5]int                    // [0 0 0 0 0]
b := [3]string{"a", "b", "c"}  // literal
c := [...]int{10, 20, 30}       // compiler counts length → [3]int

// Access and mutation
a[0] = 1
fmt.Println(a[0], len(a))

// Arrays are comparable if element type is comparable
x := [2]int{1, 2}
y := [2]int{1, 2}
fmt.Println(x == y)   // true

// Passing to a function copies the entire array
// Use a pointer to avoid the copy
func sum(arr *[5]int) int { ... }

// Multidimensional
matrix := [3][3]int{
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1},
}
```

---

### Slice

A dynamically-sized, flexible view into an array. The most commonly used sequence type in Go. A slice header contains three fields: a pointer to the underlying array, a length, and a capacity. The zero value is `nil`.

```go
// Creation
var s []int                      // nil slice (len=0, cap=0)
s = []int{1, 2, 3}              // literal
s = make([]int, 5)              // length 5, cap 5, all zeros
s = make([]int, 3, 10)          // length 3, cap 10

// From array or slice
arr := [5]int{1, 2, 3, 4, 5}
sl := arr[1:4]                  // [2 3 4], shares memory with arr
sl2 := sl[:2]                   // [2 3]
sl3 := arr[2:]                  // [3 4 5]

// Three-index slice: limits capacity of result
limited := arr[1:3:4]           // len=2, cap=3 (cap limited to index 4)

// Append — may allocate a new backing array
s = append(s, 6, 7)
s = append(s, other...)         // unpack and append another slice

// Copy — safe independent copy
dst := make([]int, len(s))
copy(dst, s)

// Nil vs empty
var nilSlice []int              // nil, len=0
emptySlice := []int{}           // not nil, len=0
fmt.Println(nilSlice == nil)    // true
fmt.Println(emptySlice == nil)  // false

// 2D slices
matrix := make([][]int, 3)
for i := range matrix {
    matrix[i] = make([]int, 3)
}

// Delete element at index i (order-preserving)
s = append(s[:i], s[i+1:]...)

// Delete element at index i (fast, unordered)
s[i] = s[len(s)-1]
s = s[:len(s)-1]

// Clear (Go 1.21)
clear(s)   // zeroes all elements, keeps length
```

---

### Map

An unordered collection of key-value pairs. Keys must be `comparable`. Maps are reference types — assignment copies the reference. The zero value is `nil`; reads on nil maps return zero values, but writes panic.

```go
// Creation
var m map[string]int             // nil map — reads OK, writes panic
m = make(map[string]int)
m = make(map[string]int, 100)    // pre-allocated hint
m = map[string]int{"a": 1, "b": 2}   // literal

// Read (zero value if missing)
v := m["key"]                    // 0 if missing

// "comma ok" — distinguish zero value from missing
v, ok := m["key"]
if !ok {
    fmt.Println("key not present")
}

// Write
m["key"] = 42
m["count"]++   // works; reads 0 if missing, then writes 1

// Delete
delete(m, "key")

// Iteration (order is randomized)
for k, v := range m {
    fmt.Println(k, v)
}

// Check length
fmt.Println(len(m))

// Clear all entries (Go 1.21)
clear(m)

// Struct as value
type Point struct{ X, Y int }
points := map[string]Point{
    "origin": {0, 0},
    "unit":   {1, 1},
}

// Nested maps
nested := map[string]map[string]int{
    "outer": {"inner": 1},
}
```

---

### Struct

A composite type grouping named fields of potentially different types. The zero value of a struct has each field set to its own zero value. Structs are value types.

```go
// Definition
type User struct {
    ID        int
    Name      string
    Email     string
    CreatedAt time.Time
    Active    bool
}

// Anonymous / embedded struct
type Admin struct {
    User                    // embedded — promotes User's fields and methods
    Permissions []string
}

// Initialization
var u User                          // zero value
u2 := User{ID: 1, Name: "Alice"}   // named fields (preferred)
u3 := User{1, "Bob", "b@x.com", time.Now(), true}   // positional (fragile)

// Field access
fmt.Println(u2.Name)

// Pointer to struct (avoids copying)
pu := &User{ID: 2, Name: "Carol"}
pu.Name = "Caroline"   // auto-dereferenced

// Anonymous fields (embedding)
admin := Admin{
    User:        User{ID: 3, Name: "Dave"},
    Permissions: []string{"read", "write"},
}
fmt.Println(admin.Name)   // promoted from embedded User

// Struct tags (used by encoding/json, database/sql, etc.)
type Profile struct {
    FirstName string `json:"first_name" db:"first_name"`
    LastName  string `json:"last_name"  db:"last_name"`
    Age       int    `json:"age,omitempty"`
    Password  string `json:"-"`           // omit from JSON always
}

// Structs are comparable if all fields are comparable
p1 := struct{ X, Y int }{1, 2}
p2 := struct{ X, Y int }{1, 2}
fmt.Println(p1 == p2)   // true

// Anonymous struct (useful for test data, one-off JSON)
record := struct {
    Name  string
    Score int
}{"Alice", 95}
```

---

### Pointer

Stores the memory address of a value. Zero value is `nil`. Dereferencing a nil pointer panics. Go has no pointer arithmetic (use `unsafe` for that).

```go
x := 42
p := &x        // *int, address of x
fmt.Println(*p)   // 42 — dereference
*p = 100       // modifies x through the pointer
fmt.Println(x)    // 100

// new allocates zeroed storage
p2 := new(int)    // *int pointing to 0

// Pointer to struct
type Node struct {
    Value int
    Next  *Node   // self-referential
}
head := &Node{Value: 1, Next: &Node{Value: 2}}

// Nil check always before dereference
if p != nil {
    fmt.Println(*p)
}

// Passing a pointer enables mutation by the callee
func increment(n *int) { *n++ }
increment(&x)
```

---

### Function Type

Functions are first-class values in Go. A function type describes the parameter and return types of a function. The zero value is `nil`.

```go
// Function type declaration
type Handler func(w http.ResponseWriter, r *http.Request)
type Predicate[T any] func(T) bool
type Transform func(string) string

// Function variable
var fn func(int) int
fn = func(x int) int { return x * 2 }

// Closure — captures variables from enclosing scope
func makeCounter() func() int {
    n := 0
    return func() int {
        n++
        return n
    }
}

// Variadic function type
type Logger func(format string, args ...any)

// Functions as arguments (higher-order)
func Filter(s []int, pred func(int) bool) []int {
    var result []int
    for _, v := range s {
        if pred(v) {
            result = append(result, v)
        }
    }
    return result
}

evens := Filter([]int{1, 2, 3, 4}, func(x int) bool { return x%2 == 0 })

// Method values and method expressions
type Greeter struct{ Name string }
func (g Greeter) Greet() string { return "Hello, " + g.Name }

g := Greeter{"World"}
greetFn := g.Greet    // method value — bound to g
fmt.Println(greetFn())
```

---

### Interface

An interface type specifies a set of method signatures. A type implicitly satisfies an interface by implementing all its methods — no explicit declaration required. The zero value is `nil`.

```go
// Interface definition
type Stringer interface {
    String() string
}

type Shape interface {
    Area() float64
    Perimeter() float64
}

// Embedding interfaces
type ReadWriter interface {
    io.Reader
    io.Writer
}

// Implicit satisfaction
type Circle struct{ Radius float64 }

func (c Circle) Area() float64      { return math.Pi * c.Radius * c.Radius }
func (c Circle) Perimeter() float64 { return 2 * math.Pi * c.Radius }

var s Shape = Circle{Radius: 5}   // Circle satisfies Shape

// Interface internals: (type, value) pair
// A nil interface has both fields nil
// An interface holding a nil pointer is NOT nil
var p *Circle = nil
var sh Shape = p      // sh is non-nil! (type=*Circle, value=nil)
fmt.Println(sh == nil)   // false — common gotcha

// Type assertion
c, ok := s.(Circle)

// Type switch
switch v := s.(type) {
case Circle:
    fmt.Println("radius:", v.Radius)
case *Circle:
    fmt.Println("pointer to circle")
}

// Empty interface (pre-1.18 any)
var anything interface{} = "hello"

// Generic constraints as interfaces (Go 1.18+)
type Number interface {
    int | int32 | int64 | float32 | float64
}

func Sum[T Number](values []T) T {
    var total T
    for _, v := range values {
        total += v
    }
    return total
}
```

---

### Channel

A typed conduit for communication between goroutines. Channels are reference types. The zero value is `nil`. Sending or receiving on a nil channel blocks forever.

```go
// Creation
ch := make(chan int)        // unbuffered: send blocks until received
bch := make(chan int, 10)   // buffered: send blocks only when full

// Directional channel types
var send chan<- int   // send-only
var recv <-chan int   // receive-only

// Sending and receiving
ch <- 42         // send
v := <-ch        // receive
v, ok := <-ch   // receive with close check: ok=false when closed and empty

// Close signals no more values will be sent
close(ch)   // only sender should close

// Range over channel (exits when closed)
for v := range ch {
    fmt.Println(v)
}

// Select: wait on multiple channels
select {
case v := <-ch1:
    fmt.Println("from ch1:", v)
case ch2 <- x:
    fmt.Println("sent to ch2")
case <-time.After(1 * time.Second):
    fmt.Println("timeout")
default:
    fmt.Println("no channel ready")
}

// Fan-out pattern
func fanOut(in <-chan int, n int) []<-chan int {
    outs := make([]<-chan int, n)
    for i := range outs {
        out := make(chan int)
        outs[i] = out
        go func() {
            for v := range in { out <- v }
            close(out)
        }()
    }
    return outs
}

// Done channel for cancellation
done := make(chan struct{})
go func() {
    defer close(done)
    doWork()
}()
<-done   // wait for completion
```

---

## 3. `strings` Package

---

### `strings.Builder`

An efficient, append-only buffer for building strings. Preferred over repeated `+` concatenation for many strings. Its zero value is ready to use. Must not be copied after first use.

```go
var b strings.Builder
for i := 0; i < 5; i++ {
    fmt.Fprintf(&b, "item %d\n", i)
}
result := b.String()
b.Reset()   // reuse the buffer

// Methods
b.WriteByte('A')
b.WriteRune('界')
b.WriteString("hello")
b.Write([]byte{0x48, 0x69})
fmt.Println(b.Len())   // current byte count
fmt.Println(b.Cap())   // current capacity
```

---

### `strings.Reader`

Implements `io.Reader`, `io.ReaderAt`, `io.Seeker`, `io.WriterTo`, `io.ByteReader`, and `io.ByteScanner` over a string. Useful for passing a string where an `io.Reader` is required without copying to `[]byte`.

```go
r := strings.NewReader("Hello, World!")
buf := make([]byte, 5)
n, _ := r.Read(buf)    // reads "Hello"

fmt.Println(r.Len())   // remaining bytes: 8
r.Seek(0, io.SeekStart)   // rewind
```

---

## 4. `bytes` Package

---

### `bytes.Buffer`

A variable-sized buffer of bytes. Implements `io.Reader`, `io.Writer`, `io.ByteReader`, `io.ByteWriter`, and `fmt.Stringer`. The zero value is an empty buffer ready to use. Unlike `strings.Builder`, a `bytes.Buffer` supports reading from the front.

```go
var buf bytes.Buffer
buf.WriteString("Hello")
buf.WriteByte(',')
buf.WriteRune(' ')
buf.Write([]byte("World"))

fmt.Println(buf.String())    // "Hello, World"
fmt.Println(buf.Len())       // remaining unread bytes

// Reading consumes from the front
chunk := make([]byte, 5)
n, _ := buf.Read(chunk)      // "Hello"

// Convenience constructors
buf2 := bytes.NewBuffer([]byte{1, 2, 3})
buf3 := bytes.NewBufferString("initial content")

// Truncate / Reset
buf.Truncate(3)    // keep first 3 bytes
buf.Reset()        // discard all content

// ReadFrom / WriteTo for io.Reader/Writer integration
buf.ReadFrom(resp.Body)
buf.WriteTo(outputFile)
```

---

### `bytes.Reader`

Implements `io.Reader`, `io.ReaderAt`, `io.Seeker`, `io.WriterTo`, `io.ByteReader`, and `io.ByteScanner` over a `[]byte`. Unlike `bytes.Buffer`, it does not support writing; it is a read-only, seekable view of a byte slice.

```go
r := bytes.NewReader([]byte{1, 2, 3, 4, 5})
r.Seek(2, io.SeekStart)
b, _ := r.ReadByte()   // 3
fmt.Println(r.Len())   // 2 (remaining)
```

---

## 5. `bufio` Package

---

### `bufio.Reader`

Wraps an `io.Reader` and adds an in-memory read buffer, reducing the number of system calls for small, frequent reads. Essential for line-by-line text processing.

```go
r := bufio.NewReader(file)
r2 := bufio.NewReaderSize(conn, 64*1024)   // custom buffer size

// Read a line (including the newline delimiter)
line, err := r.ReadString('\n')

// Read a line as bytes (no copy if line fits in buffer)
lineBytes, isPrefix, err := r.ReadLine()

// Peek without consuming
peeked, err := r.Peek(4)   // look at next 4 bytes

// Read single byte or rune
b, err := r.ReadByte()
ch, size, err := r.ReadRune()

// Unread (push back one byte/rune)
r.UnreadByte()
r.UnreadRune()

// Discard bytes
discarded, err := r.Discard(100)
```

---

### `bufio.Writer`

Wraps an `io.Writer` with a write buffer, coalescing small writes into fewer, larger system calls. Must be flushed to guarantee all data reaches the underlying writer.

```go
w := bufio.NewWriter(file)
w2 := bufio.NewWriterSize(conn, 64*1024)

w.WriteString("Hello\n")
w.WriteByte('\t')
w.WriteRune('界')
w.Write(data)

fmt.Fprintf(w, "Value: %d\n", 42)   // satisfies io.Writer

// CRITICAL: always flush
if err := w.Flush(); err != nil {
    return err
}

fmt.Println(w.Buffered())   // bytes currently in buffer
fmt.Println(w.Available())  // space remaining in buffer
```

---

### `bufio.Scanner`

Reads tokens (lines, words, or custom-delimited chunks) from an `io.Reader`. The default split function splits on lines. More ergonomic than `bufio.Reader` for line-at-a-time processing.

```go
scanner := bufio.NewScanner(file)

// Default: split by lines
for scanner.Scan() {
    line := scanner.Text()    // string (copies)
    raw := scanner.Bytes()    // []byte (valid until next Scan)
    _ = line
    _ = raw
}
if err := scanner.Err(); err != nil {
    return err
}

// Split functions
scanner.Split(bufio.ScanWords)   // split by whitespace-delimited words
scanner.Split(bufio.ScanBytes)   // one byte at a time
scanner.Split(bufio.ScanRunes)   // one UTF-8 rune at a time
scanner.Split(bufio.ScanLines)   // default: lines

// Custom split function
scanner.Split(func(data []byte, atEOF bool) (advance int, token []byte, err error) {
    // Return advance=0, token=nil, err=nil to request more data
    // Return err=bufio.ErrFinalToken to stop after returning token
    ...
})

// Increase max token size (default 64KiB)
buf := make([]byte, 1024*1024)
scanner.Buffer(buf, len(buf))
```

---

### `bufio.ReadWriter`

Combines `bufio.Reader` and `bufio.Writer`, satisfying both `io.Reader` and `io.Writer` with buffering. Commonly used for bidirectional network connections.

```go
rw := bufio.NewReadWriter(
    bufio.NewReader(conn),
    bufio.NewWriter(conn),
)
rw.WriteString("HELLO\n")
rw.Flush()
response, _ := rw.ReadString('\n')
```

---

## 6. `regexp` Package

---

### `regexp.Regexp`

A compiled regular expression. Compiling is expensive; always store compiled regexps in a package-level variable rather than recompiling inside functions. Uses RE2 syntax — no backtracking, guaranteed linear-time matching.

```go
// Compilation — panics on invalid pattern (use in init/var)
re := regexp.MustCompile(`\b\d{4}-\d{2}-\d{2}\b`)

// Safe compilation — returns error
re2, err := regexp.Compile(`(?i)^hello`)
if err != nil {
    return err
}

// Matching
fmt.Println(re.MatchString("Date: 2026-05-25"))   // true

// Finding
match := re.FindString("Date: 2026-05-25 and 2026-06-01")
// "2026-05-25" (first match)

all := re.FindAllString("2026-05-25 and 2026-06-01", -1)
// ["2026-05-25", "2026-06-01"]

// Subgroup capture
dateParts := regexp.MustCompile(`(\d{4})-(\d{2})-(\d{2})`)
groups := dateParts.FindStringSubmatch("2026-05-25")
// groups[0]="2026-05-25", groups[1]="2026", groups[2]="05", groups[3]="25"

// Named captures
named := regexp.MustCompile(`(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})`)
match2 := named.FindStringSubmatch("2026-05-25")
idx := named.SubexpIndex("year")
fmt.Println(match2[idx])   // "2026"

// Replace
result := re.ReplaceAllString("Date: 2026-05-25", "[DATE]")
result2 := re.ReplaceAllStringFunc("2026-05-25", strings.ToUpper)

// Split
re3 := regexp.MustCompile(`\s+`)
words := re3.Split("  hello   world  ", -1)

// FindAllStringIndex returns byte positions
positions := re.FindAllStringIndex("2026-05-25 2026-06-01", -1)
```

---

## 7. `fmt` Package

---

### `fmt.Stringer`

The most commonly implemented interface in Go. When a type implements `String() string`, `fmt` functions call it automatically to produce human-readable output.

```go
type Stringer interface {
    String() string
}

type Point struct{ X, Y float64 }

func (p Point) String() string {
    return fmt.Sprintf("(%.2f, %.2f)", p.X, p.Y)
}

p := Point{3.14, 2.71}
fmt.Println(p)           // (3.14, 2.71)
fmt.Printf("%v\n", p)   // (3.14, 2.71)
fmt.Printf("%s\n", p)   // (3.14, 2.71)
```

---

### `fmt.GoStringer`

Implemented to control the `%#v` output (Go-syntax representation). Useful for types whose default `%#v` representation is unreadable.

```go
type GoStringer interface {
    GoString() string
}

func (p Point) GoString() string {
    return fmt.Sprintf("Point{X: %g, Y: %g}", p.X, p.Y)
}

fmt.Printf("%#v\n", Point{1, 2})   // Point{X: 1, Y: 2}
```

---

### `fmt.Formatter`

Implemented for complete control over `fmt` formatting for all verbs.

```go
type Formatter interface {
    Format(f State, verb rune)
}

// fmt.State provides access to flags (+, #, -, 0, space) and width/precision
```

---

### `fmt.Errorf` Wrapping

```go
// %w wraps an error — unwrappable with errors.Is / errors.As
err := fmt.Errorf("database query failed: %w", originalErr)

// Multiple wraps (Go 1.20+)
err2 := fmt.Errorf("operation failed: %w; also: %w", err1, err2)
```

---

## 8. `errors` Package

---

### `errors.New`

Creates a simple error value with a static message. Each call to `errors.New` returns a distinct error value, even with the same message — sentinel errors rely on this.

```go
var ErrNotFound = errors.New("not found")
var ErrPermission = errors.New("permission denied")

if err == ErrNotFound { ... }       // pointer comparison
if errors.Is(err, ErrNotFound) { }  // also traverses wrapped errors
```

---

### `errors.Is`

Reports whether any error in the chain matches the target. The chain is constructed by successive calls to `Unwrap()`. Prefer this over direct `==` comparison when errors may be wrapped.

```go
if errors.Is(err, os.ErrNotExist) {
    // handles both os.ErrNotExist directly and wrapped variants
}
```

---

### `errors.As`

Finds the first error in the chain that matches the target type and sets the target to that value.

```go
var pathErr *os.PathError
if errors.As(err, &pathErr) {
    fmt.Println("path:", pathErr.Path)
    fmt.Println("op:", pathErr.Op)
}
```

---

### `errors.Unwrap`

Returns the result of calling `Unwrap()` on the error, or `nil` if the error does not implement `Unwrap`. Used for manual chain traversal.

```go
unwrapped := errors.Unwrap(err)
```

---

### `errors.Join` (Go 1.20+)

Creates an error that wraps a list of errors. `Unwrap() []error` returns the list. `nil` errors in the list are discarded.

```go
err := errors.Join(err1, err2, err3)
// err.Error() joins non-nil messages with newlines
```

---

## 9. `sort` & `slices` Packages

---

### `sort.Interface`

The interface required to use `sort.Sort`. Implementing it enables sorting of any collection.

```go
type Interface interface {
    Len() int
    Less(i, j int) bool
    Swap(i, j int)
}

type ByLength []string

func (b ByLength) Len() int           { return len(b) }
func (b ByLength) Less(i, j int) bool { return len(b[i]) < len(b[j]) }
func (b ByLength) Swap(i, j int)      { b[i], b[j] = b[j], b[i] }

sort.Sort(ByLength{"banana", "apple", "fig"})
// ["fig", "apple", "banana"]
```

---

### `sort.Slice` / `sort.SliceStable`

Sort a slice using a less function, without implementing `sort.Interface`. `SliceStable` preserves original order of equal elements.

```go
people := []struct{ Name string; Age int }{
    {"Alice", 30}, {"Bob", 25}, {"Carol", 30},
}

sort.Slice(people, func(i, j int) bool {
    return people[i].Age < people[j].Age
})

sort.SliceStable(people, func(i, j int) bool {
    if people[i].Age != people[j].Age {
        return people[i].Age < people[j].Age
    }
    return people[i].Name < people[j].Name
})
```

---

### `slices` Package (Go 1.21+)

Generic replacements for common slice operations.

```go
import "slices"

s := []int{3, 1, 4, 1, 5, 9}

slices.Sort(s)                        // in-place sort
slices.SortFunc(s, func(a, b int) int { return a - b })
slices.SortStableFunc(s, cmp.Compare)

idx, found := slices.BinarySearch(s, 4)   // requires sorted input
fmt.Println(slices.Contains(s, 5))         // true
fmt.Println(slices.Index(s, 9))            // index of first 9
fmt.Println(slices.Max(s))                 // 9
fmt.Println(slices.Min(s))                 // 1

s2 := slices.Clone(s)                // shallow copy
slices.Reverse(s2)
slices.Compact(s)                    // remove consecutive duplicates (like uniq)
slices.Equal(s, s2)                  // element-wise equality
slices.Replace(s, 1, 3, 99, 100)     // replace subrange
```

---

## 10. `sync` Package

---

### `sync.Mutex`

A mutual exclusion lock. Only one goroutine holds it at a time. Zero value is an unlocked mutex. Must not be copied after first use.

```go
type SafeCounter struct {
    mu sync.Mutex
    v  map[string]int
}

func (c *SafeCounter) Inc(key string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.v[key]++
}

func (c *SafeCounter) Value(key string) int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.v[key]
}
```

---

### `sync.RWMutex`

A reader/writer mutual exclusion lock. Any number of readers may hold it simultaneously; writers demand exclusive access. Use when reads are frequent and writes are rare.

```go
type Cache struct {
    mu   sync.RWMutex
    data map[string]string
}

func (c *Cache) Get(key string) (string, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    v, ok := c.data[key]
    return v, ok
}

func (c *Cache) Set(key, val string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = val
}
```

---

### `sync.WaitGroup`

Waits for a collection of goroutines to finish. `Add` increments the counter; `Done` decrements it; `Wait` blocks until the counter reaches zero.

```go
var wg sync.WaitGroup

for _, url := range urls {
    wg.Add(1)
    go func(u string) {
        defer wg.Done()
        fetch(u)
    }(url)
}

wg.Wait()   // blocks until all goroutines call Done
```

---

### `sync.Once`

Guarantees that `Do` calls its function exactly once, regardless of how many goroutines call it concurrently. The function executes on the first call; subsequent calls block until the first completes.

```go
var (
    instance *DB
    once     sync.Once
)

func GetDB() *DB {
    once.Do(func() {
        instance = connectDB()
    })
    return instance
}
```

---

### `sync.Map`

A concurrent map safe for use by multiple goroutines without additional locking. Optimized for two specific cases: when entries are only written once and read many times (caches), or when goroutines operate on disjoint key sets. For general use, a `map` protected by a `sync.RWMutex` is often simpler and faster.

```go
var m sync.Map

m.Store("key", "value")

val, ok := m.Load("key")
if ok {
    fmt.Println(val.(string))
}

// Load or store: atomically store and return actual value
actual, loaded := m.LoadOrStore("key", "default")

// Delete
m.Delete("key")

// LoadAndDelete
val2, loaded2 := m.LoadAndDelete("key")

// Iterate
m.Range(func(key, value any) bool {
    fmt.Println(key, value)
    return true   // return false to stop iteration
})
```

---

### `sync.Pool`

A pool of temporary objects that can be reused to reduce allocator pressure. Objects may be evicted by the garbage collector at any time. Never store state that must survive across GC cycles in a Pool.

```go
var bufPool = sync.Pool{
    New: func() any {
        return new(bytes.Buffer)
    },
}

func process(data []byte) {
    buf := bufPool.Get().(*bytes.Buffer)
    defer func() {
        buf.Reset()
        bufPool.Put(buf)
    }()

    buf.Write(data)
    // use buf...
}
```

---

### `sync.Cond`

A condition variable associated with a `sync.Locker`. Enables goroutines to wait for a condition to become true and to signal or broadcast when it does. Lower-level than channels; prefer channels when possible.

```go
type Queue struct {
    mu   sync.Mutex
    cond *sync.Cond
    data []int
}

func NewQueue() *Queue {
    q := &Queue{}
    q.cond = sync.NewCond(&q.mu)
    return q
}

func (q *Queue) Push(v int) {
    q.mu.Lock()
    q.data = append(q.data, v)
    q.cond.Signal()   // wake one waiter
    q.mu.Unlock()
}

func (q *Queue) Pop() int {
    q.mu.Lock()
    for len(q.data) == 0 {
        q.cond.Wait()   // releases lock, waits, re-acquires lock
    }
    v := q.data[0]
    q.data = q.data[1:]
    q.mu.Unlock()
    return v
}
```

---

## 11. `sync/atomic` Package

---

### `atomic.Value`

Provides atomic load and store of an `any` value. All stored values must be of the same concrete type. Zero value stores `nil`.

```go
import "sync/atomic"

var config atomic.Value

// Store (value must be non-nil and same type as previous stores)
config.Store(&AppConfig{Timeout: 30})

// Load
cfg := config.Load().(*AppConfig)

// Swap: store new value and return old value
old := config.Swap(&AppConfig{Timeout: 60}).(*AppConfig)

// CompareAndSwap: store only if current value equals expected
swapped := config.CompareAndSwap(old, &AppConfig{Timeout: 90})
```

---

### `atomic.Int64`, `atomic.Uint64`, `atomic.Int32`, `atomic.Bool` (Go 1.19+)

Type-safe atomic integers and booleans, avoiding the unsafe pointer casting required with the older function-based API.

```go
var counter atomic.Int64

counter.Add(1)
counter.Add(-1)
val := counter.Load()
counter.Store(100)
old := counter.Swap(0)
swapped := counter.CompareAndSwap(0, 1)

var flag atomic.Bool
flag.Store(true)
fmt.Println(flag.Load())
```

---

## 12. `context` Package

---

### `context.Context`

Carries deadlines, cancellation signals, and request-scoped key-value pairs across API boundaries. Passed as the first argument to functions that perform I/O, call external services, or need lifecycle control.

```go
type Context interface {
    Deadline() (deadline time.Time, ok bool)
    Done() <-chan struct{}
    Err() error              // nil, context.Canceled, or context.DeadlineExceeded
    Value(key any) any
}
```

---

### `context.Background`

Returns the root context. Used at the top of call chains — in `main`, server handlers, and test functions.

```go
ctx := context.Background()
```

---

### `context.TODO`

Returns a non-nil, empty context. Use when the correct context is not yet determined (e.g., during refactoring). Signals intent to replace it later.

```go
ctx := context.TODO()
```

---

### `context.WithCancel`

Returns a child context with a new `Done` channel and a `CancelFunc`. Calling `cancel` closes the `Done` channel and releases resources. Always `defer cancel()`.

```go
ctx, cancel := context.WithCancel(parent)
defer cancel()

go func() {
    select {
    case <-ctx.Done():
        fmt.Println("cancelled:", ctx.Err())
    case result := <-work():
        process(result)
    }
}()

cancel()   // signal cancellation
```

---

### `context.WithTimeout` / `context.WithDeadline`

Returns a child context that automatically cancels after a duration or at a specific time. `WithTimeout(ctx, d)` is shorthand for `WithDeadline(ctx, time.Now().Add(d))`.

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
resp, err := http.DefaultClient.Do(req)
if errors.Is(err, context.DeadlineExceeded) {
    fmt.Println("request timed out")
}
```

---

### `context.WithValue`

Returns a child context carrying a key-value pair. Use a package-private key type to avoid collisions.

```go
type contextKey string
const requestIDKey contextKey = "requestID"

ctx := context.WithValue(parent, requestIDKey, "req-abc-123")

// Retrieve
id := ctx.Value(requestIDKey).(string)
```

---

### `context.WithCancelCause` (Go 1.20+)

Like `WithCancel`, but the cancel function accepts an error that becomes the cause. Retrieve it with `context.Cause(ctx)`.

```go
ctx, cancel := context.WithCancelCause(parent)
cancel(fmt.Errorf("user logged out"))

fmt.Println(context.Cause(ctx))   // "user logged out"
```

---

## 13. `time` Package

---

### `time.Time`

Represents an instant in time with nanosecond precision. Contains a wall clock reading and a monotonic clock reading (for duration measurement). The zero value is `January 1, year 1, 00:00:00.000000000 UTC`.

```go
now := time.Now()

// Accessors
fmt.Println(now.Year(), now.Month(), now.Day())
fmt.Println(now.Hour(), now.Minute(), now.Second())
fmt.Println(now.Nanosecond())
fmt.Println(now.Weekday())        // time.Monday etc.
fmt.Println(now.Unix())           // seconds since Unix epoch
fmt.Println(now.UnixMilli())      // milliseconds
fmt.Println(now.UnixNano())       // nanoseconds
fmt.Println(now.UTC())            // convert to UTC
fmt.Println(now.In(loc))         // convert to location

// Comparison
t1.Before(t2)
t1.After(t2)
t1.Equal(t2)

// Arithmetic
future := now.Add(24 * time.Hour)
past   := now.Add(-1 * time.Hour)
diff   := t2.Sub(t1)   // returns time.Duration

// Truncation / rounding
now.Truncate(time.Hour)    // floor to hour boundary
now.Round(time.Minute)     // round to nearest minute

// Formatting — reference time: Mon Jan 2 15:04:05 MST 2006
now.Format("2006-01-02")
now.Format("2006-01-02T15:04:05Z07:00")   // RFC3339
now.Format(time.RFC3339)
now.Format(time.RFC822)
now.Format("January 2, 2006 at 3:04pm")

// Parsing
t, err := time.Parse("2006-01-02", "2026-05-25")
t2, err := time.ParseInLocation("2006-01-02 15:04", "2026-05-25 13:00", loc)

// Marshaling
b, _ := now.MarshalJSON()   // RFC3339Nano
var t3 time.Time
t3.UnmarshalJSON(b)
```

---

### `time.Duration`

A `int64` nanosecond count representing elapsed time. Named constants make literal durations readable.

```go
type Duration int64

// Named constants
time.Nanosecond
time.Microsecond   // 1000 ns
time.Millisecond   // 1000 µs
time.Second        // 1000 ms
time.Minute        // 60 s
time.Hour          // 60 min

d := 2*time.Hour + 30*time.Minute + 15*time.Second
fmt.Println(d)                  // "2h30m15s"
fmt.Println(d.Hours())          // 2.504166...
fmt.Println(d.Minutes())        // 150.25
fmt.Println(d.Seconds())        // 9015.0
fmt.Println(d.Milliseconds())   // 9015000
fmt.Println(d.String())         // "2h30m15s"

// Truncate/Round a duration
d.Truncate(time.Second)
d.Round(time.Minute)
```

---

### `time.Location`

Represents a time zone. `time.UTC` and `time.Local` are predefined. Load named zones with `time.LoadLocation`.

```go
utc := time.UTC
local := time.Local

nyc, err := time.LoadLocation("America/New_York")
tokyo, err := time.LoadLocation("Asia/Tokyo")

now := time.Now().In(nyc)
fmt.Println(now.Format(time.RFC3339))
```

---

### `time.Timer`

Fires once after a duration. Must be stopped or the goroutine spawned by `time.AfterFunc` leaks. Do not reuse a `Timer` without calling `Stop` first.

```go
timer := time.NewTimer(2 * time.Second)
defer timer.Stop()

select {
case t := <-timer.C:
    fmt.Println("Timer fired at", t)
case <-ctx.Done():
    timer.Stop()
}

// Reset a stopped timer
timer.Stop()
timer.Reset(5 * time.Second)

// One-shot function call
time.AfterFunc(1*time.Second, func() {
    fmt.Println("Fired!")
})
```

---

### `time.Ticker`

Sends the current time on its channel at regular intervals. Unlike `time.Timer`, it fires repeatedly. Always call `Stop()` when done to prevent a goroutine leak.

```go
ticker := time.NewTicker(1 * time.Second)
defer ticker.Stop()

for {
    select {
    case t := <-ticker.C:
        fmt.Println("tick at", t)
    case <-done:
        return
    }
}
```

---

### `time.Weekday` / `time.Month`

Named integer types for day-of-week and month.

```go
// Weekday: Sunday=0 … Saturday=6
today := time.Now().Weekday()
fmt.Println(today == time.Monday)

// Month: January=1 … December=12
m := time.Now().Month()
fmt.Println(m == time.December)
fmt.Println(m.String())   // "December"
```

---

## 14. `os` Package

---

### `os.File`

Represents an open file descriptor. Implements `io.Reader`, `io.Writer`, `io.Closer`, `io.Seeker`, `io.ReaderAt`, and `io.WriterAt`. The zero value is `nil`; always check errors from open calls before using.

```go
// Open for reading
f, err := os.Open("data.txt")
if err != nil { return err }
defer f.Close()

// Create / truncate
f2, err := os.Create("out.txt")

// Full control: flags and permissions
f3, err := os.OpenFile("app.log",
    os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)

// Reading
buf := make([]byte, 512)
n, err := f.Read(buf)

// Writing
n, err = f2.Write([]byte("hello\n"))
n, err = f2.WriteString("world\n")
f2.WriteAt([]byte("x"), 0)   // write at specific offset

// Seeking
pos, err := f.Seek(0, io.SeekStart)   // rewind
pos, err = f.Seek(-10, io.SeekEnd)   // 10 bytes from end

// Metadata
info, err := f.Stat()
fmt.Println(info.Name(), info.Size(), info.ModTime())

// Sync flushes OS buffers to disk
f2.Sync()

// Truncate
f2.Truncate(1024)
```

---

### `os.FileInfo` / `fs.FileInfo`

Describes a file or directory. Returned by `os.Stat`, `os.Lstat`, and `(*os.File).Stat`.

```go
info, err := os.Stat("/etc/hosts")
if os.IsNotExist(err) {
    fmt.Println("file not found")
}

fmt.Println(info.Name())       // "hosts"
fmt.Println(info.Size())       // bytes
fmt.Println(info.Mode())       // file mode bits
fmt.Println(info.ModTime())    // time.Time
fmt.Println(info.IsDir())      // false
fmt.Println(info.Sys())        // platform-specific (*syscall.Stat_t on Unix)

// Mode bits
mode := info.Mode()
fmt.Println(mode.IsRegular())       // is a regular file
fmt.Println(mode.IsDir())           // is a directory
fmt.Println(mode.Perm())            // permission bits (0644 etc)
fmt.Println(mode&os.ModeSymlink != 0)  // is a symlink
```

---

### `os.FileMode`

A bitmask encoding file type and permission bits. Combines with named constants.

```go
// Common permission patterns
const (
    userReadWrite  os.FileMode = 0600
    userReadAll    os.FileMode = 0644
    userExecAll    os.FileMode = 0755
    privateDir     os.FileMode = 0700
)

os.Mkdir("newdir", 0755)
os.WriteFile("secret.key", data, 0600)

// ModeDir, ModeSymlink, ModeNamedPipe, ModeSocket, ModeDevice etc.
info.Mode()&os.ModeDir != 0
```

---

### `os.Process` / `os.ProcessState`

`Process` represents a running OS process. `ProcessState` holds the status of a finished process.

```go
proc, err := os.StartProcess("/usr/bin/ls", []string{"ls", "-la"}, &os.ProcAttr{
    Files: []*os.File{os.Stdin, os.Stdout, os.Stderr},
})

proc.Signal(os.Interrupt)   // send SIGINT
proc.Kill()                 // send SIGKILL
state, err := proc.Wait()   // block until process exits

fmt.Println(state.Pid())
fmt.Println(state.ExitCode())   // -1 if signalled
fmt.Println(state.Success())    // exit code was 0
fmt.Println(state.Exited())     // exited normally (not signalled)
```

---

### `os.Signal`

Interface satisfied by `syscall.Signal`. Used with `signal.Notify` to intercept OS signals.

```go
import "os/signal"

sigs := make(chan os.Signal, 1)
signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

go func() {
    sig := <-sigs
    fmt.Println("Received:", sig)
    shutdown()
    os.Exit(0)
}()
```

---

## 15. `net` Package

---

### `net.Conn`

The universal interface for a network connection. Implements `io.Reader`, `io.Writer`, and `io.Closer`, plus deadline control.

```go
type Conn interface {
    Read(b []byte) (n int, err error)
    Write(b []byte) (n int, err error)
    Close() error
    LocalAddr() Addr
    RemoteAddr() Addr
    SetDeadline(t time.Time) error
    SetReadDeadline(t time.Time) error
    SetWriteDeadline(t time.Time) error
}

conn, err := net.Dial("tcp", "example.com:80")
defer conn.Close()

conn.SetDeadline(time.Now().Add(30 * time.Second))
conn.Write([]byte("GET / HTTP/1.0\r\n\r\n"))
io.Copy(os.Stdout, conn)
```

---

### `net.Listener`

A network listener for stream-oriented protocols. `Accept` blocks until a new connection arrives.

```go
type Listener interface {
    Accept() (Conn, error)
    Close() error
    Addr() Addr
}

ln, err := net.Listen("tcp", ":8080")
defer ln.Close()

for {
    conn, err := ln.Accept()
    if err != nil {
        return err
    }
    go handleConn(conn)
}
```

---

### `net.IP`

A slice of bytes representing an IPv4 or IPv6 address. IPv4 addresses are 4 bytes; IPv6 are 16 bytes.

```go
type IP []byte

ip := net.ParseIP("192.168.1.1")     // returns nil if invalid
ip6 := net.ParseIP("::1")

fmt.Println(ip.String())              // "192.168.1.1"
fmt.Println(ip.IsLoopback())          // false
fmt.Println(ip.IsPrivate())           // true (RFC 1918)
fmt.Println(ip.IsMulticast())         // false
fmt.Println(ip.Equal(net.ParseIP("192.168.1.1")))  // true

// Convert IPv4 to 4-byte form
ip4 := ip.To4()    // nil if not IPv4
ip16 := ip.To16()  // always 16 bytes
```

---

### `net.IPNet`

Represents an IP network (IP address + mask). Used for CIDR range checks.

```go
_, network, err := net.ParseCIDR("192.168.1.0/24")

fmt.Println(network.IP)      // network address
fmt.Println(network.Mask)    // subnet mask
fmt.Println(network.Contains(net.ParseIP("192.168.1.42")))  // true
fmt.Println(network.String())  // "192.168.1.0/24"
```

---

### `net.TCPAddr` / `net.UDPAddr`

Concrete address types for TCP and UDP endpoints.

```go
addr := &net.TCPAddr{
    IP:   net.ParseIP("127.0.0.1"),
    Port: 8080,
    Zone: "",   // IPv6 zone
}

// Resolve hostname to address
tcpAddr, err := net.ResolveTCPAddr("tcp", "localhost:8080")

// Direct TCP connection
conn, err := net.DialTCP("tcp", nil, tcpAddr)
```

---

### `net.Dialer`

Provides more control over connection establishment than `net.Dial`, including timeouts, local address binding, and TCP keep-alive.

```go
dialer := &net.Dialer{
    Timeout:   30 * time.Second,
    KeepAlive: 30 * time.Second,
    LocalAddr: &net.TCPAddr{IP: net.ParseIP("10.0.0.1")},
}

conn, err := dialer.DialContext(ctx, "tcp", "example.com:443")
```

---

## 16. `net/http` Package

---

### `http.Request`

Represents an HTTP request, both incoming (server-side) and outgoing (client-side).

```go
type Request struct {
    Method     string
    URL        *url.URL
    Proto      string     // "HTTP/1.1"
    Header     Header     // map[string][]string
    Body       io.ReadCloser
    Host       string
    Form       url.Values
    PostForm   url.Values
    MultipartForm *multipart.Form
    RemoteAddr string
    RequestURI string
    TLS        *tls.ConnectionState
    // ...
}

// Server-side usage
func handler(w http.ResponseWriter, r *http.Request) {
    // Method, path, headers
    fmt.Println(r.Method, r.URL.Path)
    fmt.Println(r.Header.Get("Content-Type"))
    fmt.Println(r.Header.Get("Authorization"))

    // Query parameters
    q := r.URL.Query()
    page := q.Get("page")

    // Body (JSON)
    defer r.Body.Close()
    var payload MyStruct
    json.NewDecoder(r.Body).Decode(&payload)

    // Form data
    r.ParseForm()
    name := r.FormValue("name")

    // Path params (using newer mux routing, Go 1.22+)
    id := r.PathValue("id")
}

// Client-side construction
req, err := http.NewRequestWithContext(ctx, "POST", url, body)
req.Header.Set("Content-Type", "application/json")
req.Header.Set("Authorization", "Bearer "+token)
```

---

### `http.ResponseWriter`

Interface used by HTTP handlers to construct and send a response.

```go
type ResponseWriter interface {
    Header() Header
    Write([]byte) (int, error)
    WriteHeader(statusCode int)
}

func handler(w http.ResponseWriter, r *http.Request) {
    // Set headers BEFORE WriteHeader or Write
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("X-Request-ID", requestID)

    // Write status code (200 is default if Write is called first)
    w.WriteHeader(http.StatusCreated)

    // Write body
    json.NewEncoder(w).Encode(response)

    // Convenience helpers
    http.Error(w, "not found", http.StatusNotFound)
    http.Redirect(w, r, "/login", http.StatusFound)
    http.ServeFile(w, r, "index.html")
}
```

---

### `http.Response`

Represents an HTTP response received by a client.

```go
type Response struct {
    Status     string   // "200 OK"
    StatusCode int      // 200
    Proto      string
    Header     Header
    Body       io.ReadCloser
    ContentLength int64
    TLS        *tls.ConnectionState
    Request    *Request
    // ...
}

resp, err := http.Get("https://api.example.com/data")
if err != nil { return err }
defer resp.Body.Close()

if resp.StatusCode != http.StatusOK {
    return fmt.Errorf("unexpected status: %s", resp.Status)
}

body, err := io.ReadAll(resp.Body)
ct := resp.Header.Get("Content-Type")
```

---

### `http.Client`

Performs HTTP requests. Safe for concurrent use. Reuse a single instance rather than creating per-request clients (it maintains connection pools).

```go
client := &http.Client{
    Timeout: 10 * time.Second,
    Transport: &http.Transport{
        MaxIdleConns:        100,
        MaxIdleConnsPerHost: 10,
        IdleConnTimeout:     90 * time.Second,
        TLSHandshakeTimeout: 10 * time.Second,
        DisableCompression:  false,
    },
    CheckRedirect: func(req *http.Request, via []*http.Request) error {
        if len(via) >= 5 {
            return fmt.Errorf("too many redirects")
        }
        return nil
    },
}

resp, err := client.Do(req)
resp, err = client.Get(url)
resp, err = client.Post(url, "application/json", body)
```

---

### `http.Handler` / `http.HandlerFunc`

`Handler` is the interface for HTTP request handlers. `HandlerFunc` is a function type that implements `Handler`, allowing ordinary functions to be used as handlers.

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}

type HandlerFunc func(ResponseWriter, *Request)

func (f HandlerFunc) ServeHTTP(w ResponseWriter, r *Request) { f(w, r) }

// Middleware pattern
func Logger(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
    })
}
```

---

### `http.ServeMux`

An HTTP request multiplexer. Routes incoming requests to registered handlers based on URL patterns. Go 1.22 added method-qualified patterns and path parameters.

```go
mux := http.NewServeMux()

// Static path
mux.HandleFunc("/health", healthHandler)

// Go 1.22+: method + path with parameter
mux.HandleFunc("GET /users/{id}", getUserHandler)
mux.HandleFunc("POST /users", createUserHandler)
mux.HandleFunc("DELETE /users/{id}", deleteUserHandler)

// Catch-all (trailing slash)
mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))

http.ListenAndServe(":8080", mux)
```

---

### `http.Header`

A map of HTTP header names to lists of values. Keys are canonicalized (Title-Case).

```go
type Header map[string][]string

h := http.Header{}
h.Set("Content-Type", "application/json")       // replaces
h.Add("Accept", "text/html")                    // appends
h.Add("Accept", "application/json")             // now two Accept values
fmt.Println(h.Get("Content-Type"))              // first value
fmt.Println(h.Values("Accept"))                 // all values
h.Del("X-Custom")
fmt.Println(h.Has("Content-Type"))              // Go 1.21+
```

---

### `http.Cookie`

Represents an HTTP cookie as parsed from a Set-Cookie header.

```go
type Cookie struct {
    Name     string
    Value    string
    Path     string
    Domain   string
    Expires  time.Time
    MaxAge   int
    Secure   bool
    HttpOnly bool
    SameSite SameSite
}

// Set a cookie
http.SetCookie(w, &http.Cookie{
    Name:     "session",
    Value:    sessionToken,
    Path:     "/",
    HttpOnly: true,
    Secure:   true,
    SameSite: http.SameSiteLaxMode,
    MaxAge:   86400,
})

// Read cookies
cookie, err := r.Cookie("session")
all := r.Cookies()   // []*http.Cookie
```

---

## 17. `net/url` Package

---

### `url.URL`

Represents a parsed URL. All fields are strings; use accessor methods for decoded values.

```go
type URL struct {
    Scheme      string
    Opaque      string
    User        *Userinfo
    Host        string   // host or host:port
    Path        string
    RawPath     string
    OmitHost    bool
    ForceQuery  bool
    RawQuery    string
    Fragment    string
    RawFragment string
}

u, err := url.Parse("https://user:pass@example.com:8080/path?key=val#frag")

fmt.Println(u.Scheme)        // "https"
fmt.Println(u.Host)          // "example.com:8080"
fmt.Println(u.Hostname())    // "example.com"
fmt.Println(u.Port())        // "8080"
fmt.Println(u.Path)          // "/path"
fmt.Println(u.RawQuery)      // "key=val"
fmt.Println(u.Fragment)      // "frag"
fmt.Println(u.User.Username())
pw, set := u.User.Password()

// Query params
q := u.Query()               // url.Values
q.Set("page", "2")
u.RawQuery = q.Encode()
fmt.Println(u.String())      // rebuild URL string

// Resolve relative reference
base, _ := url.Parse("https://example.com/base/")
ref, _ := url.Parse("../other")
resolved := base.ResolveReference(ref)
```

---

### `url.Values`

A map of URL query parameter keys to lists of values. Used for building and parsing query strings and form data.

```go
type Values map[string][]string

// Build query string
params := url.Values{}
params.Set("q", "golang generics")
params.Add("page", "1")
params.Add("sort", "date")
fmt.Println(params.Encode())   // "page=1&q=golang+generics&sort=date"

// Parse query string
params, err := url.ParseQuery("page=1&tag=go&tag=stdlib")
fmt.Println(params.Get("page"))      // "1"
fmt.Println(params["tag"])           // ["go", "stdlib"]
fmt.Println(params.Has("sort"))      // false
```

---

## 18. `encoding/json` Package

---

### `json.Decoder`

Reads and decodes JSON values from an `io.Reader` stream. Preferred over `json.Unmarshal` for network or file streams to avoid loading the entire payload into memory.

```go
dec := json.NewDecoder(r.Body)
dec.DisallowUnknownFields()   // error on unexpected fields

var payload MyStruct
if err := dec.Decode(&payload); err != nil {
    return fmt.Errorf("decode: %w", err)
}

// Decode a stream of JSON objects (newline-delimited JSON)
for dec.More() {
    var item Item
    if err := dec.Decode(&item); err != nil { break }
    process(item)
}

// Peek at type via Token
tok, err := dec.Token()
switch v := tok.(type) {
case json.Delim:    // '{', '}', '[', ']'
case string:
case float64:
case bool:
case nil:
}
```

---

### `json.Encoder`

Writes JSON-encoded values to an `io.Writer` stream.

```go
enc := json.NewEncoder(w)
enc.SetIndent("", "  ")   // pretty-print
enc.SetEscapeHTML(false)  // do not escape < > &

if err := enc.Encode(response); err != nil {
    return err
}
```

---

### `json.RawMessage`

A raw, pre-encoded JSON value (`[]byte`). Delays decoding or pre-encodes a JSON fragment, useful for heterogeneous structures.

```go
type Event struct {
    Type    string          `json:"type"`
    Payload json.RawMessage `json:"payload"`   // decode later based on Type
}

var evt Event
json.Unmarshal(data, &evt)

switch evt.Type {
case "click":
    var click ClickPayload
    json.Unmarshal(evt.Payload, &click)
case "scroll":
    var scroll ScrollPayload
    json.Unmarshal(evt.Payload, &scroll)
}
```

---

### `json.Number`

A string type representing a JSON number. Used when decoding into `any` to avoid losing precision on large integers (which default to `float64`).

```go
dec := json.NewDecoder(strings.NewReader(`{"id": 9007199254740993}`))
dec.UseNumber()   // use json.Number instead of float64 for numbers

var m map[string]any
dec.Decode(&m)
n := m["id"].(json.Number)
i64, _ := n.Int64()    // 9007199254740993 (exact)
f64, _ := n.Float64()
fmt.Println(n.String())
```

---

### JSON Struct Tags

Control serialization behavior via struct field tags.

```go
type Article struct {
    ID          int       `json:"id"`
    Title       string    `json:"title"`
    Body        string    `json:"body,omitempty"`    // omit if empty
    Internal    string    `json:"-"`                  // always omit
    PublishedAt time.Time `json:"published_at"`
    Tags        []string  `json:"tags,omitempty"`
}

// Custom marshaling
type Duration struct{ time.Duration }

func (d Duration) MarshalJSON() ([]byte, error) {
    return json.Marshal(d.String())
}

func (d *Duration) UnmarshalJSON(b []byte) error {
    var s string
    if err := json.Unmarshal(b, &s); err != nil { return err }
    dur, err := time.ParseDuration(s)
    d.Duration = dur
    return err
}
```

---

## 19. `math/big` Package

---

### `big.Int`

Arbitrary-precision integer. The zero value represents 0. Always pass and store as a pointer.

```go
import "math/big"

a := new(big.Int)
a.SetInt64(1_000_000_000_000)

b, _ := new(big.Int).SetString("99999999999999999999999999", 10)

// Arithmetic (result stored in receiver)
sum := new(big.Int).Add(a, b)
diff := new(big.Int).Sub(b, a)
prod := new(big.Int).Mul(a, b)
quot, rem := new(big.Int).DivMod(b, a, new(big.Int))

// Powers
n := new(big.Int).Exp(big.NewInt(2), big.NewInt(256), nil)

// Bitwise
new(big.Int).And(a, b)
new(big.Int).Or(a, b)
new(big.Int).Lsh(a, 10)   // left shift

// Comparison
a.Cmp(b)    // -1, 0, 1
a.Sign()    // -1, 0, 1

// Conversion
fmt.Println(a.String())
fmt.Println(a.Text(16))    // hex
i64 := a.Int64()           // panics if out of range; use IsInt64 first
a.IsInt64()
```

---

### `big.Float`

Arbitrary-precision floating-point with configurable precision and rounding mode.

```go
f := new(big.Float).SetPrec(256).SetFloat64(math.Pi)
g, _ := new(big.Float).SetPrec(256).SetString("2.718281828459045235360287")

result := new(big.Float).Add(f, g)
fmt.Printf("%.50f\n", result)

f.Prec()           // current precision
f.SetMode(big.ToNearestEven)  // rounding mode
f64, accuracy := f.Float64()
fmt.Println(accuracy)   // big.Exact, big.Below, big.Above
```

---

### `big.Rat`

Exact rational numbers (fractions). Stored as a numerator/denominator pair of `big.Int`, always in lowest terms.

```go
r := new(big.Rat).SetFrac(big.NewInt(1), big.NewInt(3))   // 1/3
s, _ := new(big.Rat).SetString("2/7")

sum := new(big.Rat).Add(r, s)
fmt.Println(sum.RatString())    // "13/21"
fmt.Println(sum.FloatString(10))  // "0.6190476190"

r.Num()   // numerator as *big.Int
r.Denom() // denominator as *big.Int
r.IsInt() // true if denominator is 1
```

---

## 20. `reflect` Package

---

### `reflect.Type`

Represents a Go type at runtime. Obtained via `reflect.TypeOf`.

```go
var x int = 42
t := reflect.TypeOf(x)

fmt.Println(t.Name())       // "int"
fmt.Println(t.Kind())       // reflect.Int
fmt.Println(t.Size())       // 8 (bytes on 64-bit)
fmt.Println(t.PkgPath())    // "" (built-in)

// Struct fields
type Config struct {
    Host string `json:"host"`
    Port int    `json:"port"`
}
ct := reflect.TypeOf(Config{})
for i := 0; i < ct.NumField(); i++ {
    field := ct.Field(i)
    fmt.Println(field.Name, field.Type, field.Tag.Get("json"))
}

// Pointer / slice / map element types
st := reflect.TypeOf([]int{})
fmt.Println(st.Elem())    // int

mt := reflect.TypeOf(map[string]bool{})
fmt.Println(mt.Key(), mt.Elem())   // string, bool

// Method sets
fmt.Println(t.NumMethod())
m, found := t.MethodByName("String")
```

---

### `reflect.Value`

Represents a runtime value of any Go type. Obtained via `reflect.ValueOf`. Allows inspection and (for addressable values) mutation.

```go
v := reflect.ValueOf(42)
fmt.Println(v.Type())     // int
fmt.Println(v.Kind())     // reflect.Int
fmt.Println(v.Int())      // 42

// Settable values require a pointer
x := 42
vp := reflect.ValueOf(&x).Elem()   // addressable int
vp.SetInt(100)
fmt.Println(x)   // 100

// Structs
cfg := Config{Host: "localhost", Port: 8080}
vc := reflect.ValueOf(&cfg).Elem()

hostField := vc.FieldByName("Host")
fmt.Println(hostField.String())   // "localhost"
hostField.SetString("0.0.0.0")

// Call methods
method := reflect.ValueOf(&cfg).MethodByName("Validate")
results := method.Call(nil)

// Slice manipulation
sv := reflect.ValueOf([]int{1, 2, 3})
fmt.Println(sv.Len(), sv.Index(0).Int())
```

---

### `reflect.Kind`

An enum of the fundamental Go type categories, regardless of the named type.

```go
// All kinds
const (
    Invalid Kind = iota
    Bool
    Int; Int8; Int16; Int32; Int64
    Uint; Uint8; Uint16; Uint32; Uint64; Uintptr
    Float32; Float64
    Complex64; Complex128
    Array; Chan; Func; Interface; Map; Pointer; Slice; String; Struct; UnsafePointer
)

k := reflect.TypeOf(MyStruct{}).Kind()   // reflect.Struct
k == reflect.Slice   // false
```

---

### `reflect.StructField`

Describes a single field of a struct type.

```go
type StructField struct {
    Name    string
    PkgPath string       // empty if exported
    Type    reflect.Type
    Tag     StructTag
    Offset  uintptr
    Index   []int
    Anonymous bool
}

field, found := reflect.TypeOf(Config{}).FieldByName("Host")
tag := field.Tag.Get("json")
fmt.Println(field.IsExported())
```

---

## 21. `database/sql` Package

---

### `sql.DB`

A database handle representing a pool of connections. Safe for concurrent use. Call `Open` once at startup and reuse the handle.

```go
db, err := sql.Open("postgres", dsn)
if err != nil { log.Fatal(err) }
defer db.Close()

db.SetMaxOpenConns(25)
db.SetMaxIdleConns(5)
db.SetConnMaxLifetime(5 * time.Minute)
db.SetConnMaxIdleTime(1 * time.Minute)

// Verify connectivity
if err := db.PingContext(ctx); err != nil {
    log.Fatal("database unreachable:", err)
}

// Query returning multiple rows
rows, err := db.QueryContext(ctx, "SELECT id, name FROM users WHERE active = $1", true)
defer rows.Close()
for rows.Next() {
    var id int; var name string
    if err := rows.Scan(&id, &name); err != nil { return err }
}
if err := rows.Err(); err != nil { return err }

// Query returning one row
var count int
db.QueryRowContext(ctx, "SELECT count(*) FROM users").Scan(&count)

// Execute (INSERT/UPDATE/DELETE)
result, err := db.ExecContext(ctx,
    "INSERT INTO users (name, email) VALUES ($1, $2)", name, email)
id, _ := result.LastInsertId()
rows2, _ := result.RowsAffected()
```

---

### `sql.Tx`

Represents a database transaction. All methods match those on `sql.DB`. Either `Commit` or `Rollback` must be called to release the connection.

```go
tx, err := db.BeginTx(ctx, &sql.TxOptions{
    Isolation: sql.LevelSerializable,
    ReadOnly:  false,
})
if err != nil { return err }
defer tx.Rollback()   // no-op after Commit

_, err = tx.ExecContext(ctx, "UPDATE accounts SET balance = balance - $1 WHERE id = $2", amount, fromID)
if err != nil { return err }

_, err = tx.ExecContext(ctx, "UPDATE accounts SET balance = balance + $1 WHERE id = $2", amount, toID)
if err != nil { return err }

return tx.Commit()
```

---

### `sql.Stmt`

A prepared statement. Reuse for repeated execution of the same query with different parameters. More efficient than re-parsing the query each time.

```go
stmt, err := db.PrepareContext(ctx, "SELECT * FROM products WHERE category = $1")
if err != nil { return err }
defer stmt.Close()

rows1, err := stmt.QueryContext(ctx, "electronics")
rows2, err := stmt.QueryContext(ctx, "books")
```

---

### `sql.Rows`

The result of a multi-row query. Must be closed after use (via `defer rows.Close()`).

```go
rows, err := db.QueryContext(ctx, query)
if err != nil { return err }
defer rows.Close()

cols, err := rows.Columns()    // column names

for rows.Next() {
    // Scan into variables
    if err := rows.Scan(&col1, &col2); err != nil { return err }

    // Scan into []any (dynamic columns)
    vals := make([]any, len(cols))
    ptrs := make([]any, len(cols))
    for i := range vals { ptrs[i] = &vals[i] }
    rows.Scan(ptrs...)
}

return rows.Err()   // always check after loop
```

---

### `sql.NullString`, `sql.NullInt64`, `sql.NullBool`, `sql.NullFloat64`, `sql.NullTime`

Nullable SQL types that distinguish between a NULL database value and a Go zero value.

```go
type NullString struct {
    String string
    Valid  bool   // false if NULL
}

var ns sql.NullString
rows.Scan(&ns)
if ns.Valid {
    fmt.Println(ns.String)
}

// Writing a nullable value
ns := sql.NullString{String: "hello", Valid: true}
nullNs := sql.NullString{}   // NULL
db.ExecContext(ctx, "INSERT INTO t (col) VALUES ($1)", ns, nullNs)
```

---

## 22. `log/slog` Package (Go 1.21+)

---

### `slog.Logger`

Structured logger. The default logger writes JSON or text to stderr. Supports levels, key-value pairs, and groups.

```go
// Default package-level logger
slog.Info("server started", "port", 8080)
slog.Warn("high memory usage", "percent", 92.5)
slog.Error("request failed", "error", err, "path", r.URL.Path)
slog.Debug("cache hit", "key", key)

// Custom logger
logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
    Level: slog.LevelDebug,
    AddSource: true,
}))

// With pre-set fields (returns new Logger)
reqLogger := logger.With("request_id", id, "user_id", userID)
reqLogger.Info("processing request", "method", r.Method)

// Groups
logger.Info("db metrics",
    slog.Group("query",
        "duration_ms", 42,
        "rows", 100,
    ))
```

---

### `slog.Handler`

The interface backends must implement. Implement to write to external logging systems.

```go
type Handler interface {
    Enabled(context.Context, Level) bool
    Handle(context.Context, Record) error
    WithAttrs(attrs []Attr) Handler
    WithGroup(name string) Handler
}

// Built-in handlers
slog.NewTextHandler(os.Stderr, opts)   // key=value text
slog.NewJSONHandler(os.Stdout, opts)   // {"level":"INFO",...}
```

---

### `slog.Record`

A single log event. Contains the time, level, message, source location, and attributes.

```go
r := slog.NewRecord(time.Now(), slog.LevelInfo, "something happened", 0)
r.AddAttrs(
    slog.String("user", "alice"),
    slog.Int("attempt", 3),
    slog.Duration("elapsed", d),
)
logger.Handler().Handle(ctx, r)
```

---

### `slog.Level`

```go
const (
    LevelDebug Level = -4
    LevelInfo  Level = 0
    LevelWarn  Level = 4
    LevelError Level = 8
)

// Custom level
const LevelTrace = slog.Level(-8)
```

---

### `slog.Attr` / `slog.Value`

A key-value pair attached to a log record. `slog.Value` is a union type holding any loggable value without an allocation for common scalar types.

```go
// Type-safe constructors
slog.String("key", "value")
slog.Int("count", 42)
slog.Float64("ratio", 0.95)
slog.Bool("active", true)
slog.Duration("elapsed", d)
slog.Time("at", t)
slog.Any("err", err)
slog.Group("sub", "a", 1, "b", 2)
```

---

## 23. `container` Package

---

### `container/list` — `list.List` / `list.Element`

A doubly linked list. Elements are `*list.Element`; values are stored as `any`.

```go
import "container/list"

l := list.New()

// Push
front := l.PushFront("first")
back  := l.PushBack("last")
mid   := l.InsertAfter("middle", front)

// Access
fmt.Println(l.Front().Value.(string))
fmt.Println(l.Back().Value.(string))
fmt.Println(l.Len())

// Traverse
for e := l.Front(); e != nil; e = e.Next() {
    fmt.Println(e.Value)
}

// Remove
l.Remove(mid)

// Move
l.MoveToFront(back)
l.MoveToBack(front)

// Push entire list
l2 := list.New()
l.PushBackList(l2)
```

---

### `container/heap` — `heap.Interface`

Provides heap operations on any type implementing the interface. A min-heap by default; invert `Less` for a max-heap.

```go
import "container/heap"

type IntHeap []int

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *IntHeap) Push(x any) { *h = append(*h, x.(int)) }
func (h *IntHeap) Pop() any {
    old := *h; n := len(old)
    x := old[n-1]; *h = old[:n-1]
    return x
}

h := &IntHeap{3, 1, 4, 1, 5}
heap.Init(h)
heap.Push(h, 2)
fmt.Println(heap.Pop(h))    // 1 (smallest)
fmt.Println((*h)[0])        // peek at minimum
```

---

### `container/ring` — `ring.Ring`

A circular doubly linked list. Every element is both a list and an element — there is no separate list type.

```go
import "container/ring"

r := ring.New(5)   // 5-element ring

// Set values
for i, e := 0, r; i < r.Len(); i, e = i+1, e.Next() {
    e.Value = i
}

// Iterate
r.Do(func(v any) {
    fmt.Println(v)
})

// Advance
r = r.Next()     // one forward
r = r.Prev()     // one backward
r = r.Move(3)    // n steps forward (negative = backward)

// Link/unlink
r2 := ring.New(3)
r.Link(r2)       // inserts r2 after r, returns removed segment
r.Unlink(2)      // removes 2 elements after r
```

---

## 24. Quick Index

| Type / Symbol | Package | Kind | Summary |
|---|---|---|---|
| `bool` | builtin | primitive | `true` / `false` |
| `int` | builtin | primitive | Platform-width signed integer |
| `int8` / `int16` / `int32` / `int64` | builtin | primitive | Sized signed integers |
| `uint` | builtin | primitive | Platform-width unsigned integer |
| `uint8` / `uint16` / `uint32` / `uint64` | builtin | primitive | Sized unsigned integers |
| `uintptr` | builtin | primitive | Pointer-sized unsigned integer |
| `float32` | builtin | primitive | 32-bit IEEE 754 float |
| `float64` | builtin | primitive | 64-bit IEEE 754 float (default) |
| `complex64` | builtin | primitive | Complex with float32 parts |
| `complex128` | builtin | primitive | Complex with float64 parts (default) |
| `string` | builtin | primitive | Immutable UTF-8 byte sequence |
| `byte` | builtin | alias | Alias for `uint8` |
| `rune` | builtin | alias | Alias for `int32`; Unicode code point |
| `error` | builtin | interface | `Error() string` |
| `any` | builtin | alias | Alias for `interface{}` |
| `comparable` | builtin | constraint | Types supporting `==` and `!=` |
| `[N]T` | builtin | composite | Fixed-length array, value type |
| `[]T` | builtin | composite | Slice: dynamic view over array |
| `map[K]V` | builtin | composite | Hash map, reference type |
| `struct{...}` | builtin | composite | Named field aggregate, value type |
| `*T` | builtin | composite | Pointer to type T |
| `func(...)...` | builtin | composite | First-class function |
| `interface{...}` | builtin | composite | Method set abstraction |
| `chan T` | builtin | composite | Goroutine communication channel |
| `strings.Builder` | strings | type | Efficient append-only string buffer |
| `strings.Reader` | strings | type | `io.Reader` over a string |
| `bytes.Buffer` | bytes | type | Read-write byte buffer |
| `bytes.Reader` | bytes | type | Read-only `io.Reader` over `[]byte` |
| `bufio.Reader` | bufio | type | Buffered `io.Reader` |
| `bufio.Writer` | bufio | type | Buffered `io.Writer` |
| `bufio.Scanner` | bufio | type | Token scanner over `io.Reader` |
| `bufio.ReadWriter` | bufio | type | Buffered bidirectional I/O |
| `regexp.Regexp` | regexp | type | Compiled RE2 regular expression |
| `fmt.Stringer` | fmt | interface | `String() string` |
| `fmt.GoStringer` | fmt | interface | `GoString() string` (for `%#v`) |
| `fmt.Formatter` | fmt | interface | Custom verb formatting |
| `errors.New` | errors | func | Static error value |
| `errors.Is` | errors | func | Error chain membership test |
| `errors.As` | errors | func | Error chain type extraction |
| `errors.Unwrap` | errors | func | Single-step chain unwrap |
| `errors.Join` | errors | func | Multi-error aggregation |
| `sort.Interface` | sort | interface | `Len / Less / Swap` |
| `slices.Sort` | slices | func | Generic in-place sort |
| `slices.BinarySearch` | slices | func | Generic binary search |
| `slices.Contains` | slices | func | Generic membership test |
| `slices.Clone` | slices | func | Shallow slice copy |
| `slices.Compact` | slices | func | Remove consecutive duplicates |
| `sync.Mutex` | sync | type | Exclusive lock |
| `sync.RWMutex` | sync | type | Reader/writer lock |
| `sync.WaitGroup` | sync | type | Goroutine barrier |
| `sync.Once` | sync | type | One-time initialization |
| `sync.Map` | sync | type | Concurrency-safe map |
| `sync.Pool` | sync | type | Object pool to reduce GC pressure |
| `sync.Cond` | sync | type | Condition variable |
| `atomic.Value` | sync/atomic | type | Atomic load/store of any |
| `atomic.Int64` | sync/atomic | type | Atomic 64-bit integer |
| `atomic.Bool` | sync/atomic | type | Atomic boolean |
| `context.Context` | context | interface | Deadline / cancellation / values |
| `context.Background` | context | func | Root context |
| `context.TODO` | context | func | Placeholder context |
| `context.WithCancel` | context | func | Cancellable child context |
| `context.WithTimeout` | context | func | Time-limited child context |
| `context.WithDeadline` | context | func | Deadline child context |
| `context.WithValue` | context | func | Key-value carrying child context |
| `context.WithCancelCause` | context | func | Cancellable with error cause |
| `time.Time` | time | type | Nanosecond-precision instant |
| `time.Duration` | time | type | Elapsed time (`int64` nanoseconds) |
| `time.Location` | time | type | Time zone |
| `time.Timer` | time | type | One-shot delayed event |
| `time.Ticker` | time | type | Repeating interval event |
| `time.Weekday` | time | type | Day of week (`int`) |
| `time.Month` | time | type | Month of year (`int`) |
| `os.File` | os | type | Open file descriptor |
| `os.FileInfo` | os | interface | File metadata |
| `os.FileMode` | os | type | File type and permission bitmask |
| `os.Process` | os | type | Running OS process |
| `os.ProcessState` | os | type | Finished process status |
| `os.Signal` | os | interface | OS signal (e.g. `syscall.SIGTERM`) |
| `net.Conn` | net | interface | Bidirectional network connection |
| `net.Listener` | net | interface | Network connection acceptor |
| `net.IP` | net | type | IPv4/IPv6 address (`[]byte`) |
| `net.IPNet` | net | type | IP network / CIDR range |
| `net.TCPAddr` | net | type | TCP endpoint address |
| `net.UDPAddr` | net | type | UDP endpoint address |
| `net.Dialer` | net | type | Configurable connection dialer |
| `http.Request` | net/http | type | HTTP request (client & server) |
| `http.ResponseWriter` | net/http | interface | HTTP response builder |
| `http.Response` | net/http | type | HTTP response (client-side) |
| `http.Client` | net/http | type | HTTP client with connection pool |
| `http.Handler` | net/http | interface | `ServeHTTP(ResponseWriter, *Request)` |
| `http.HandlerFunc` | net/http | type | Function satisfying `Handler` |
| `http.ServeMux` | net/http | type | HTTP request router |
| `http.Header` | net/http | type | HTTP headers (`map[string][]string`) |
| `http.Cookie` | net/http | type | HTTP cookie |
| `url.URL` | net/url | type | Parsed URL |
| `url.Values` | net/url | type | Query params / form data |
| `json.Decoder` | encoding/json | type | Streaming JSON decoder |
| `json.Encoder` | encoding/json | type | Streaming JSON encoder |
| `json.RawMessage` | encoding/json | type | Pre-encoded JSON fragment |
| `json.Number` | encoding/json | type | JSON number without float64 loss |
| `big.Int` | math/big | type | Arbitrary-precision integer |
| `big.Float` | math/big | type | Arbitrary-precision float |
| `big.Rat` | math/big | type | Exact rational number |
| `reflect.Type` | reflect | interface | Runtime type descriptor |
| `reflect.Value` | reflect | type | Runtime value of any type |
| `reflect.Kind` | reflect | type | Fundamental type category |
| `reflect.StructField` | reflect | type | Struct field descriptor |
| `sql.DB` | database/sql | type | Database connection pool |
| `sql.Tx` | database/sql | type | Database transaction |
| `sql.Stmt` | database/sql | type | Prepared statement |
| `sql.Rows` | database/sql | type | Multi-row query result |
| `sql.NullString` | database/sql | type | Nullable SQL string |
| `sql.NullInt64` | database/sql | type | Nullable SQL int64 |
| `sql.NullBool` | database/sql | type | Nullable SQL bool |
| `sql.NullTime` | database/sql | type | Nullable SQL time |
| `slog.Logger` | log/slog | type | Structured logger |
| `slog.Handler` | log/slog | interface | Logging backend |
| `slog.Record` | log/slog | type | Single structured log event |
| `slog.Level` | log/slog | type | Log severity level |
| `slog.Attr` | log/slog | type | Structured key-value log field |
| `list.List` | container/list | type | Doubly linked list |
| `list.Element` | container/list | type | Linked list node |
| `heap.Interface` | container/heap | interface | Heap operations contract |
| `ring.Ring` | container/ring | type | Circular doubly linked list |
