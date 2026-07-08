# Dart Field Guide

Dart is a statically typed, client-optimized language from Google, best known
as the language behind Flutter. It supports both JIT (fast development
cycles, hot reload) and AOT (fast startup, native binaries) compilation.

## Setup and Compilation

```bash
dart --version                      # check installed version
dart create myapp                    # scaffold a new console app
dart create -t web myapp               # scaffold a web app
dart run file.dart                      # run a Dart file (JIT)
dart run                                 # run project's main entrypoint
dart compile exe file.dart                 # compile to native executable
dart compile js file.dart                    # compile to JavaScript
dart compile aot-snapshot file.dart            # compile to AOT snapshot
dart pub get                                     # install dependencies
dart pub add package_name                          # add a dependency
dart pub upgrade                                     # upgrade dependencies
dart analyze                                           # static analysis
dart format .                                            # format code
dart test                                                  # run tests
```

## Hello World

```dart
void main() {
  print('Hello, World!');
}
```

## Variables and Types

```dart
var x = 10;                  // type inferred as int
int y = 20;                    // explicit type
final z = 30;                    // runtime constant, cannot be reassigned
const pi = 3.14159;                // compile-time constant
dynamic anything = 'could be anything';
late String name;                    // initialized later, non-nullable

String s = 'hello';
double d = 3.14;
bool flag = true;
List<int> nums = [1, 2, 3];
Map<String, int> ages = {'Alice': 30, 'Bob': 25};
Set<int> unique = {1, 2, 3};
```

## Null Safety

```dart
int? maybeNull;                    // nullable type
int nonNull = maybeNull ?? 0;        // null-coalescing default
maybeNull?.toString();                 // null-aware method call
int forced = maybeNull!;                 // assert non-null (throws if null)

void greet(String? name) {
  if (name != null) {
    print('Hello, $name');           // type promoted to non-null in this scope
  }
}

int? a;
a ??= 5;                             // assign only if currently null
```

## String Operations

```dart
String s = 'Hello, Dart!';
print(s.length);                   // length
print(s.toUpperCase());              // uppercase
print(s.toLowerCase());                // lowercase
print(s + ' More');                      // concatenation
print(s.replaceAll('Dart', 'World'));      // replace all
print(s.split(','));                         // split into List<String>
print(s.trim());                               // trim whitespace
print(s.contains('Dart'));                       // substring check
print(s.substring(0, 5));                          // slice
print('$s has ${s.length} characters');              // string interpolation

String multi = '''
Multi-line
string
''';
```

## Control Flow

```dart
if (x > 10) {
  print('big');
} else if (x > 5) {
  print('medium');
} else {
  print('small');
}

String label = x > 10 ? 'big' : 'small';   // ternary

switch (x) {
  case 1:
    print('one');
    break;
  case 2:
  case 3:
    print('two or three');
    break;
  default:
    print('other');
}

// Modern pattern-matching switch (Dart 3+)
String describe(Object obj) => switch (obj) {
  int n when n > 10 => 'big int',
  int() => 'small int',
  String() => 'a string',
  _ => 'something else',
};
```

## Loops

```dart
for (var i = 0; i < 10; i++) {
  print(i);
}

for (var item in [1, 2, 3]) {
  print(item);
}

[1, 2, 3].forEach((item) => print(item));

var i = 0;
while (i < 5) {
  print(i);
  i++;
}

do {
  print(i);
  i--;
} while (i > 0);

outer:
for (var i = 0; i < 5; i++) {
  for (var j = 0; j < 5; j++) {
    if (j == 3) continue outer;
  }
}
```

## Functions

```dart
int add(int a, int b) {
  return a + b;
}

int add2(int a, int b) => a + b;      // arrow syntax for single expression

String greet(String name, {String greeting = 'Hello'}) {   // named parameter with default
  return '$greeting, $name!';
}
greet('World', greeting: 'Hi');

String greetOpt(String name, [String? title]) {   // optional positional
  return title != null ? '$title $name' : name;
}

int Function(int, int) multiply = (a, b) => a * b;   // function as a value

void applyTwice(int Function(int) f, int val) {
  print(f(f(val)));
}
applyTwice((x) => x * x, 2);

int sum(List<int> nums) => nums.fold(0, (acc, n) => acc + n);
```

## Classes

```dart
class Animal {
  String name;
  int age;

  Animal(this.name, this.age);          // constructor shorthand

  String speak() => '...';
}

class Dog extends Animal {
  String breed;

  Dog(String name, int age, this.breed) : super(name, age);

  @override
  String speak() => '$name says Woof!';
}

var d = Dog('Rex', 3, 'Labrador');
print(d.speak());
```

## Constructors

```dart
class Point {
  final double x, y;

  Point(this.x, this.y);                        // standard constructor
  Point.origin() : x = 0, y = 0;                  // named constructor
  factory Point.fromJson(Map json) {                // factory constructor
    return Point(json['x'], json['y']);
  }

  const Point.constant(this.x, this.y);              // const constructor
}

var p = Point.origin();
```

## Abstract Classes and Interfaces

```dart
abstract class Shape {
  double area();                     // abstract method, no body
}

class Circle implements Shape {
  final double radius;
  Circle(this.radius);

  @override
  double area() => 3.14159 * radius * radius;
}

mixin Flyable {
  void fly() => print('Flying!');
}

class Bird extends Animal with Flyable {
  Bird(String name, int age) : super(name, age);
}
```

## Enums

```dart
enum Color { red, green, blue }

var c = Color.red;
print(c.name);
print(c.index);

// Enhanced enums with fields and methods (Dart 2.17+)
enum Planet {
  mercury(3.7),
  earth(9.8);

  final double gravity;
  const Planet(this.gravity);
}
```

## Generics

```dart
class Box<T> {
  T value;
  Box(this.value);

  T get() => value;
}

var intBox = Box<int>(42);
var strBox = Box<String>('hello');

T maxVal<T extends Comparable>(T a, T b) => a.compareTo(b) > 0 ? a : b;
```

## Collections and Functional Methods

```dart
var nums = [1, 2, 3, 4, 5];
print(nums.map((x) => x * 2).toList());
print(nums.where((x) => x.isEven).toList());
print(nums.reduce((a, b) => a + b));
print(nums.fold(0, (acc, x) => acc + x));
print(nums.first);
print(nums.last);
print(nums.reversed.toList());
print(nums.toSet());                        // dedupe via Set
print(nums.any((x) => x > 3));
print(nums.every((x) => x > 0));
print(nums.take(2).toList());
print(nums.skip(2).toList());

// Collection literals with control flow (Dart 2.3+)
var list = [1, 2, if (true) 3, for (var i in [4, 5]) i * 2];
```

## Exception Handling

```dart
try {
  throw Exception('something went wrong');
} on FormatException catch (e) {
  print('Format error: $e');
} catch (e, stackTrace) {
  print('Caught: $e');
} finally {
  print('Always runs');
}

class MyError implements Exception {
  final String message;
  MyError(this.message);
  @override
  String toString() => 'MyError: $message';
}

void mightFail(int x) {
  if (x < 0) throw MyError('negative not allowed');
}
```

## Asynchronous Programming

```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 1));
  return 'data';
}

void main() async {
  var data = await fetchData();
  print(data);

  fetchData().then((data) => print(data)).catchError((e) => print('Error: $e'));
}

Stream<int> countStream() async* {
  for (var i = 0; i < 5; i++) {
    yield i;
    await Future.delayed(Duration(milliseconds: 500));
  }
}

void listen() async {
  await for (var value in countStream()) {
    print(value);
  }
}
```

## Records and Pattern Matching (Dart 3+)

```dart
(int, String) getPair() => (1, 'one');

var (num, word) = getPair();          // destructuring
print('$num: $word');

({int x, int y}) namedRecord = (x: 1, y: 2);
print(namedRecord.x);

// Pattern matching in switch
var point = (3, 4);
switch (point) {
  case (0, 0):
    print('origin');
  case (var x, var y) when x == y:
    print('on diagonal');
  case (var x, var y):
    print('at $x, $y');
}
```

## JSON Serialization

```dart
import 'dart:convert';

var jsonString = '{"name": "Alice", "age": 30}';
Map<String, dynamic> data = jsonDecode(jsonString);
print(data['name']);

var encoded = jsonEncode({'name': 'Bob', 'age': 25});
print(encoded);

class User {
  final String name;
  final int age;
  User(this.name, this.age);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['name'], json['age']);

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}
```

## Testing

```dart
import 'package:test/test.dart';

void main() {
  test('addition works', () {
    expect(1 + 1, equals(2));
  });

  group('math operations', () {
    test('multiplication', () => expect(2 * 3, equals(6)));
    test('division', () => expect(10 ~/ 2, equals(5)));
  });
}
```

```bash
dart test                        # run all tests
dart test test/my_test.dart       # run a specific test file
```

## pubspec.yaml Example

```yaml
name: myapp
description: A sample Dart application
version: 1.0.0
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  http: ^1.1.0

dev_dependencies:
  test: ^1.24.0
  lints: ^3.0.0
```

## Common Standard Library / Package Highlights

| Package / Library | Purpose |
|---|---|
| `dart:core` | Core types, always available |
| `dart:async` | Futures, Streams |
| `dart:convert` | JSON, UTF-8 encoding/decoding |
| `dart:io` | File and network I/O (not available on web) |
| `dart:math` | Math functions and constants |
| `package:http` | HTTP client |
| `package:test` | Testing framework |
| `package:flutter` | UI toolkit built on Dart |

## Tips

- Use `final` for values assigned once at runtime, `const` for values known
  at compile time.
- Null safety is enforced by the compiler; nullable types must be explicitly
  marked with `?`.
- Arrow syntax (`=>`) is idiomatic for single-expression functions and
  getters.
- `dart compile exe` produces fast-starting native binaries good for CLI
  tools; Flutter apps use AOT compilation for release builds.
- Records and pattern matching (Dart 3+) reduce the need for small
  single-use classes when returning multiple values.
