# Nim Cheatsheet

Nim is a statically typed, compiled language with Python-like syntax,
whitespace-significant blocks, and zero-cost abstractions that compile down
to C, C++, or JavaScript.

Nim Field Guide


## Table of Contents
1. [Setup and Compilation](#setup-and-compilation)
2. [Hello World](#hello-world)
3. [Variables](#variables)
4. [Basic Types](#basic-types)
5. [String Operations](#string-operations)
6. [Control Flow](#control-flow)
7. [Loops](#loops)
8. [Procedures (Functions)](#procedures-functions)
9. [Object-Oriented Programming](#object-oriented-programming)
10. [Types: Objects, Ref Objects, Enums](#types-objects-ref-objects-enums)
11. [Generics](#generics)
12. [Sequences and Collections](#sequences-and-collections)
13. [Exception Handling](#exception-handling)
14. [Modules and Imports](#modules-imports)
15. [Pragmas (Compiler Directives)](#pragma-compiler-directives)
16. [Concurrency](#concurrency)
17. [Compile-Time Execution](#compile-time-execution)
18. [Error / Nil Safety](#error--nil-safety)
19. [Common Standard Library Modules](#common-standard-library-modules)
20. [Testing](#testing)
21. [Nimble Project File Example](#nimble-project-file-example)
22. [Tips](#tips)


## Setup and Compilation

```bash
nim compile file.nim              # compile to executable
nim c file.nim                    # shorthand for compile
nim c -r file.nim                 # compile and run immediately
nim c -d:release file.nim         # optimized release build
nim c -d:danger file.nim          # release build, no runtime checks (fastest)
nim c --backend:js file.nim       # compile to JavaScript
nim c --backend:cpp file.nim      # compile via C++ backend
nim r file.nim                    # compile and run, discard binary
nimble init                       # create a new Nimble project
nimble build                      # build project per .nimble file
nimble install packagename        # install a package
```

## Hello World

```nim
echo "Hello, World!"
```

## Variables

```nim
var x = 10                 # mutable, type inferred
var y: int = 20            # mutable, explicit type
let z = 30                 # immutable binding (preferred default)
const PI = 3.14159         # compile-time constant

var a, b, c: int = 0       # multiple declarations, same type
var (m, n) = (1, 2)        # tuple unpacking
```

## Basic Types

```nim
var i: int = 42
var f: float = 3.14
var s: string = "hello"
var c: char = 'a'
var b: bool = true
var arr: array[3, int] = [1, 2, 3]     # fixed-size array
var sq: seq[int] = @[1, 2, 3]          # dynamic sequence
var t: tuple[x: int, y: int] = (1, 2)  # tuple with named fields
```

## String Operations

```nim
let s = "Hello, Nim!"
echo s.len                      # length
echo s.toUpperAscii()           # uppercase
echo s.toLowerAscii()           # lowercase
echo s & " More"                # concatenation
echo s.replace("Nim", "World")  # replace substring
echo s.split(",")                # split into seq[string]
echo s.strip()                    # trim whitespace
echo s.contains("Nim")             # substring check
echo s[0..4]                        # slice
echo fmt"{s} has {s.len} chars"      # string interpolation (needs std/strformat)
```

## Control Flow

```nim
if x > 10:
  echo "big"
elif x > 5:
  echo "medium"
else:
  echo "small"

# One-liner
let label = if x > 10: "big" else: "small"

case x
of 1: echo "one"
of 2, 3: echo "two or three"
of 4..10: echo "four to ten"
else: echo "other"

when defined(release):
  echo "release build"    # compile-time conditional
```

## Loops

```nim
for i in 0..9:
  echo i

for i in 0..<10:            # exclusive upper bound
  echo i

for i in countup(0, 10, 2):   # step by 2
  echo i

for i in countdown(10, 0):     # descending
  echo i

var i = 0
while i < 5:
  echo i
  inc i

for item in @[1, 2, 3]:
  echo item

for idx, item in @["a", "b", "c"]:
  echo idx, ": ", item

block outer:
  for i in 0..5:
    for j in 0..5:
      if j == 3:
        break outer
```

## Procedures (Functions)

```nim
proc add(a, b: int): int =
  return a + b

proc add2(a, b: int): int =
  a + b                       # implicit return of last expression

proc greet(name: string = "World"): string =
  "Hello, " & name & "!"      # default parameter

proc sum(nums: varargs[int]): int =
  result = 0                  # `result` is an implicit return variable
  for n in nums:
    result += n

echo sum(1, 2, 3, 4)

proc modifyVar(x: var int) =  # pass by mutable reference
  x = x * 2

proc apply(f: proc(x: int): int, val: int): int =  # higher-order function
  f(val)

echo apply(proc(x: int): int = x * x, 5)
```

## Object-Oriented Programming

```nim
type
  Animal = object of RootObj
    name: string
    age: int

  Dog = object of Animal
    breed: string

method speak(a: Animal): string {.base.} =
  "..."

method speak(d: Dog): string =
  d.name & " says Woof!"

var d = Dog(name: "Rex", age: 3, breed: "Labrador")
echo d.speak()
```

## Types: Objects, Ref Objects, Enums

```nim
type
  Point = object
    x, y: int

  PersonRef = ref object      # heap-allocated, reference semantics
    name: string
    age: int

  Color = enum
    red, green, blue

var p = Point(x: 1, y: 2)
var pr = PersonRef(name: "Alice", age: 30)
var c = Color.red
echo ord(c)                  # enum ordinal value
echo $c                       # enum to string
```

## Generics

```nim
proc maxVal[T](a, b: T): T =
  if a > b: a else: b

echo maxVal(3, 7)
echo maxVal("abc", "abd")

type
  Stack[T] = object
    items: seq[T]

proc push[T](s: var Stack[T], item: T) =
  s.items.add(item)

proc pop[T](s: var Stack[T]): T =
  result = s.items[^1]
  s.items.setLen(s.items.len - 1)
```

## Sequences and Collections

```nim
var s = @[1, 2, 3, 4, 5]
s.add(6)                      # append
s.delete(0)                    # remove index 0
echo s.len
echo s[^1]                      # last element
echo s[1..3]                     # slice

import std/sequtils
echo s.map(proc(x: int): int = x * 2)
echo s.filter(proc(x: int): bool = x mod 2 == 0)
echo s.foldl(a + b)               # reduce/fold

var table = {"a": 1, "b": 2}.toTable   # needs std/tables
echo table["a"]
table["c"] = 3
for k, v in table:
  echo k, ": ", v
```

## Exception Handling

```nim
try:
  raise newException(ValueError, "something went wrong")
except ValueError as e:
  echo "Caught: ", e.msg
except:
  echo "Caught something else"
finally:
  echo "Always runs"

proc mightFail(x: int): int =
  if x < 0:
    raise newException(ValueError, "negative not allowed")
  x * 2
```

## Modules and Imports

```nim
import std/strutils
import std/sequtils, std/tables    # multiple imports
from std/os import getEnv          # import specific symbols
import std/math except sqrt        # import all except one symbol

# Custom module (mymodule.nim), imported as:
import mymodule
```

## Pragmas (Compiler Directives)

```nim
proc fastFunc(x: int): int {.inline.} =
  x * 2

{.push checks: off.}    # disable runtime checks for this block
proc unsafeAccess(a: array[3, int], i: int): int =
  a[i]
{.pop.}

type
  MyObj {.packed.} = object   # no padding between fields
    a: int8
    b: int32
```

## Concurrency

```nim
import std/threadpool

proc heavyWork(n: int): int =
  n * n

let results = @[spawn heavyWork(1), spawn heavyWork(2), spawn heavyWork(3)]
for r in results:
  echo ^r                     # ^ dereferences a FlowVar

# Async/await (needs std/asyncdispatch)
import std/asyncdispatch

proc fetchData() {.async.} =
  await sleepAsync(1000)
  echo "Done"

waitFor fetchData()
```

## Compile-Time Execution

```nim
proc factorial(n: int): int =
  if n <= 1: 1 else: n * factorial(n - 1)

const precomputed = factorial(10)   # evaluated at compile time
echo precomputed

static:
  echo "This runs at compile time"
```

## Error / Nil Safety

```nim
proc find(s: seq[int], target: int): Option[int] =    # needs std/options
  for i, v in s:
    if v == target:
      return some(i)
  return none(int)

let r = find(@[1, 2, 3], 2)
if r.isSome:
  echo r.get()
```

## Common Standard Library Modules

| Module | Purpose |
|---|---|
| `std/strutils` | String manipulation |
| `std/sequtils` | Functional seq operations (map, filter, fold) |
| `std/tables` | Hash tables / dictionaries |
| `std/os` | OS interaction, paths, environment |
| `std/math` | Math functions |
| `std/random` | Random number generation |
| `std/times` | Date and time |
| `std/json` | JSON parsing and serialization |
| `std/asyncdispatch` | Async/await concurrency |
| `std/unittest` | Testing framework |

## Testing

```nim
import std/unittest

test "addition works":
  check 1 + 1 == 2

suite "math operations":
  test "multiplication":
    check 2 * 3 == 6
  test "division":
    check 10 div 2 == 5
```

```bash
nim c -r test_file.nim         # compile and run tests
```

## Nimble Project File Example (mypackage.nimble)

```nim
version       = "0.1.0"
author        = "Your Name"
description   = "A sample Nim package"
license       = "MIT"
srcDir        = "src"
bin           = @["mypackage"]

requires "nim >= 2.0.0"
requires "jester >= 0.5.0"
```

## Tips

- `let` is preferred over `var` when a value doesn't need to change.
- Indentation (2 spaces conventionally) defines blocks, similar to Python.
- Procedures return their last expression implicitly, or use `result`.
- Use `-d:release` for production builds; `-d:danger` strips bounds checking
  for maximum speed once code is verified correct.
- Nim compiles to C/C++/JS, making it easy to interop with existing C libraries
  via `{.importc.}` pragmas.
