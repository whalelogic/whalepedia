# Crystal Cheatsheet

Crystal is a statically typed, compiled language with Ruby-like syntax, type
inference, and compile-time null safety, aimed at combining Ruby's
expressiveness with C-like performance.

## Table of Contents
1. [Setup and Compilation](#setup-and-compilation)
2. [Hello World](#hello-world)
3. [Variables and Types](#variables-and-types)
4. [Nil Safety](#nil-safety)
5. [String Operations](#string-operations)
6. [Control Flow](#control-flow)
7. [Loops](#loops)
8. [Methods](#methods)
9. [Classes](#classes)
10. [Structs (Value Types)](#structs-value-types)
11. [Modules and Mixins](#modules-and-mixins)
12. [Enums](#enums)
13. [Generics](#generics)
14. [Collections and Functional Methods](#collections-and-functional-methods)
15. [Exception Handling](#exception-handling)
16. [Concurrency: Fibers and Channels](#concurrency-fibers-and-channels)
17. [Macros (Compile-Time Metaprogramming)](#macros-compile-time-metaprogramming)
18. [Annotations and Records](#annotations-and-records)
19. [JSON Serialization](#json-serialization)
20. [Testing with Spec](#testing-with-spec)
21. [shard.yml Example](#shardyml-example)
22. [Common Standard Library Modules](#common-standard-library-modules)
23. [Tips](#tips)


## Setup and Compilation

```bash
crystal build file.cr                 # compile to binary (./file)
crystal build --release file.cr       # optimized release build
crystal run file.cr                    # compile and run in one step
crystal run file.cr -- arg1 arg2        # pass arguments to the program
crystal spec                             # run test suite
crystal eval 'puts 1 + 1'                 # evaluate a one-liner
crystal init app myapp                     # scaffold a new application
crystal init lib mylib                       # scaffold a new library
shards install                                # install dependencies from shard.yml
shards build                                    # build project via Shards
```

## Hello World

```crystal
puts "Hello, World!"
```

## Variables and Types

```crystal
x = 10                    # type inferred as Int32
y : Int64 = 20              # explicit type annotation
name = "Crystal"              # String
pi = 3.14                       # Float64
flag = true                      # Bool
arr = [1, 2, 3]                    # Array(Int32)
hash = {"a" => 1, "b" => 2}          # Hash(String, Int32)
tup = {1, "two", 3.0}                  # Tuple(Int32, String, Float64)
nums : Array(Int32) = [] of Int32        # empty array, explicit type
```

## Nil Safety

```crystal
x : Int32? = nil            # nilable type (union with Nil)
if x
  puts x + 1                  # compiler knows x is Int32 here (flow typing)
end

y = x || 0                     # provide default with ||
z = x.not_nil!                   # assert non-nil (raises if actually nil)

value = maybe_nil?
puts value if value                # guard clause pattern
```

## String Operations

```crystal
s = "Hello, Crystal!"
puts s.size                     # length
puts s.upcase                    # uppercase
puts s.downcase                   # lowercase
puts s + " More"                    # concatenation
puts s.sub("Crystal", "World")        # replace first
puts s.gsub("l", "L")                   # replace all
puts s.split(",")                         # split into Array(String)
puts s.strip                                # trim whitespace
puts s.includes?("Crystal")                   # substring check
puts s[0..4]                                    # slice
puts "#{s} has #{s.size} characters"              # string interpolation
```

## Control Flow

```crystal
if x > 10
  puts "big"
elsif x > 5
  puts "medium"
else
  puts "small"
end

# Modifier form
puts "big" if x > 10

# Ternary-like
label = x > 10 ? "big" : "small"

case x
when 1
  puts "one"
when 2, 3
  puts "two or three"
when 4..10
  puts "four to ten"
else
  puts "other"
end

unless x > 10
  puts "not big"
end
```

## Loops

```crystal
(0..9).each do |i|
  puts i
end

10.times do |i|
  puts i
end

i = 0
while i < 5
  puts i
  i += 1
end

until i == 0
  i -= 1
end

[1, 2, 3].each do |item|
  puts item
end

[1, 2, 3].each_with_index do |item, idx|
  puts "#{idx}: #{item}"
end

loop do
  break if some_condition
end
```

## Methods

```crystal
def add(a, b)
  a + b                        # implicit return of last expression
end

def add_typed(a : Int32, b : Int32) : Int32
  a + b
end

def greet(name = "World")
  "Hello, #{name}!"             # default parameter
end

def sum(*nums : Int32) : Int32     # splat / varargs
  nums.sum
end

puts sum(1, 2, 3, 4)

def modify(arr : Array(Int32))       # arrays are reference types
  arr << 4
end

def apply(val, &block : Int32 -> Int32)   # block parameter
  block.call(val)
end

puts apply(5) { |x| x * x }
```

## Classes

```crystal
class Animal
  getter name : String
  @age : Int32

  def initialize(@name : String, @age : Int32)
  end

  def speak
    "..."
  end
end

class Dog < Animal
  def initialize(name : String, age : Int32, @breed : String)
    super(name, age)
  end

  def speak
    "#{name} says Woof!"
  end
end

d = Dog.new("Rex", 3, "Labrador")
puts d.speak
puts d.name
```

## Structs (Value Types)

```crystal
struct Point
  getter x : Int32
  getter y : Int32

  def initialize(@x : Int32, @y : Int32)
  end
end

p1 = Point.new(1, 2)
puts p1.x
```

## Modules and Mixins

```crystal
module Greetable
  def greet
    "Hello, I'm #{name}"
  end
end

class Person
  include Greetable
  getter name : String

  def initialize(@name : String)
  end
end

puts Person.new("Alice").greet
```

## Enums

```crystal
enum Color
  Red
  Green
  Blue
end

c = Color::Red
puts c
puts c.to_s
puts Color::Red.value           # underlying integer value

case c
when Color::Red
  puts "it's red"
else
  puts "other"
end
```

## Generics

```crystal
class Stack(T)
  def initialize
    @items = [] of T
  end

  def push(item : T)
    @items.push(item)
  end

  def pop : T
    @items.pop
  end
end

s = Stack(Int32).new
s.push(1)
s.push(2)
puts s.pop
```

## Collections and Functional Methods

```crystal
arr = [1, 2, 3, 4, 5]
puts arr.map { |x| x * 2 }
puts arr.select { |x| x.even? }
puts arr.reject { |x| x.even? }
puts arr.reduce(0) { |acc, x| acc + x }
puts arr.sum
puts arr.sort
puts arr.sort_by { |x| -x }
puts arr.first
puts arr.last
puts arr.reverse
puts arr.uniq
puts arr.each_slice(2).to_a
puts arr.compact                  # remove nils from array
```

## Exception Handling

```crystal
begin
  raise "something went wrong"
rescue ex : Exception
  puts "Caught: #{ex.message}"
ensure
  puts "Always runs"
end

def might_fail(x : Int32) : Int32
  raise ArgumentError.new("negative not allowed") if x < 0
  x * 2
end

class MyError < Exception
end

begin
  raise MyError.new("custom error")
rescue e : MyError
  puts e.message
end
```

## Concurrency: Fibers and Channels

```crystal
channel = Channel(Int32).new

spawn do
  channel.send(42)
end

value = channel.receive
puts value

# Multiple fibers producing work
results = Channel(Int32).new
3.times do |i|
  spawn do
    results.send(i * i)
  end
end

3.times { puts results.receive }
```

## Macros (Compile-Time Metaprogramming)

```crystal
macro define_getter(name)
  def {{name.id}}
    @{{name.id}}
  end
end

class Example
  def initialize(@value : Int32)
  end
  define_getter(value)
end
```

## Annotations and Records

```crystal
record Point3D, x : Int32, y : Int32, z : Int32

p = Point3D.new(1, 2, 3)
puts p.x

# record with computed method
record Rectangle, width : Int32, height : Int32 do
  def area
    width * height
  end
end
```

## JSON Serialization

```crystal
require "json"

class User
  include JSON::Serializable
  property name : String
  property age : Int32
end

user = User.from_json(%({"name": "Alice", "age": 30}))
puts user.name
puts user.to_json
```

## Testing with Spec

```crystal
require "spec"

describe "Math" do
  it "adds numbers" do
    (1 + 1).should eq(2)
  end

  it "multiplies numbers" do
    (2 * 3).should eq(6)
  end
end
```

```bash
crystal spec                     # run all specs in spec/ directory
crystal spec spec/my_spec.cr      # run a specific spec file
```

## shard.yml Example (Dependency Manifest)

```yaml
name: myapp
version: 0.1.0

authors:
  - Your Name <you@example.com>

dependencies:
  kemal:
    github: kemalcr/kemal

targets:
  myapp:
    main: src/myapp.cr

crystal: ">= 1.10.0"
license: MIT
```

## Common Standard Library Modules

| Module | Purpose |
|---|---|
| `JSON` | JSON parsing and serialization |
| `HTTP::Client` / `HTTP::Server` | HTTP client and server |
| `File` | File I/O |
| `Dir` | Directory operations |
| `Time` | Date and time handling |
| `Regex` | Regular expressions |
| `Spec` | Testing framework |
| `Log` | Structured logging |
| `YAML` | YAML parsing and serialization |

## Tips

- Crystal infers types aggressively; explicit annotations are mostly needed
  for method signatures and instance variables without an initial value.
- The compiler's flow-sensitive typing narrows nilable types inside `if x`
  checks, eliminating a large class of null-pointer errors at compile time.
- Fibers (green threads) plus `Channel` provide CSP-style concurrency
  without needing OS threads for I/O-bound work.
- Use `--release` builds for production; development builds compile faster
  but run slower.
- Crystal's syntax closely mirrors Ruby, but every expression is statically
  typed and checked at compile time — there is no dynamic `method_missing`
  dispatch at runtime by default.
