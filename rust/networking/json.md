# 🧾 JSON

Turn Rust values into JSON strings and parse them back using `serde` and `serde_json`. Turning a value into JSON is called **serializing**; parsing JSON back into a value is **deserializing**.

Add both crates to your `Cargo.toml`:

```toml
serde = { version = "1", features = ["derive"] }
serde_json = "1"
```

> 💡 The `derive` feature is what unlocks the magic `#[derive(Serialize, Deserialize)]` line. Without it, you'd have to write the conversion code by hand.

## 🏗️ Deriving the conversions

The `#[derive(Serialize, Deserialize)]` line tells the compiler to write the JSON conversion code for you, so you don't have to. Once a type derives these traits, it can round-trip through JSON:

```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
struct Point {
    x: i32,
    y: i32,
}

let p = Point { x: 1, y: 2 };

// Serialize: struct -> JSON string
let s = serde_json::to_string(&p).unwrap();

// Deserialize: JSON string -> struct
let back: Point = serde_json::from_str(&s).unwrap();
```

### ✨ Pretty printing

Need human-readable output with indentation and line breaks? Reach for `to_string_pretty`:

```rust
let s = serde_json::to_string_pretty(&p).unwrap();
```

## 🎛️ Tweaking fields with attributes

You can change how a single field is read or written by adding a `#[serde(...)]` line above it. These lines are called **attributes**:

```rust
#[derive(Serialize, Deserialize)]
struct Config {
    #[serde(rename = "userName")]
    user_name: String,

    #[serde(default)] // uses Default::default() if the field is absent
    retries: u32,

    #[serde(skip_serializing_if = "Option::is_none")]
    note: Option<String>, // omitted from output when None
}
```

Some attributes you'll reach for often:

| Attribute | What it does |
|-----------|--------------|
| `#[serde(rename = "...")]` | Use a different name in the JSON than in your struct |
| `#[serde(default)]` | Fill in `Default::default()` when the field is missing |
| `#[serde(skip_serializing_if = "...")]` | Leave the field out of the output when a condition holds |
| `#[serde(deny_unknown_fields)]` | Reject input that contains fields you didn't declare |

## 🧰 Typed structs vs. untyped `Value`

When you don't have a matching struct, use `Value` — a catch-all type that can hold any JSON, whether an object, array, number, or string. The `json!` macro lets you write JSON literals right in your Rust code:

```rust
use serde_json::{json, Value};

// Build JSON with the json! macro
let v: Value = json!({ "name": "Ada", "tags": ["a", "b"] });
let name = v["name"].as_str();      // reach into a field
let first = v["tags"][0].as_str();  // index into an array

// Parse arbitrary text into an untyped Value
let parsed: Value = serde_json::from_str(r#"{"n":42}"#).unwrap();
let n = parsed["n"].as_i64();       // read it back out as an i64
```

Which one should you use? It depends on whether you know the shape ahead of time:

| | Typed struct | Untyped `Value` |
|---|---|---|
| **When to use** | You know the shape up front | The shape is dynamic or unknown |
| **Compile-time checks** | ✅ Field names and types are checked | ❌ Everything is checked at runtime |
| **Access** | Plain field access: `config.retries` | Indexing + accessors: `v["n"].as_i64()` |
| **Build with** | Struct literal + `derive` | `json!` macro or `from_str` |

> 💡 You can also cross between the two worlds: `serde_json::to_value(&my_struct)` turns a typed value into a `Value`, and `serde_json::from_value(v)` turns a `Value` back into a typed struct.

## 🧪 Example

Here's the full round trip — derive the traits, serialize to a string, and deserialize back:

```rust
use serde::{Serialize, Deserialize};
use serde_json::{json, Value};

#[derive(Serialize, Deserialize, Debug)]
struct User {
    #[serde(rename = "userName")]
    user_name: String,

    #[serde(default)] // filled in when the field is absent
    retries: u32,

    #[serde(skip_serializing_if = "Option::is_none")]
    note: Option<String>, // dropped from output when None
}

fn main() {
    let user = User {
        user_name: "Ada".to_string(),
        retries: 3,
        note: None,
    };

    // Serialize: User -> compact JSON string
    let compact = serde_json::to_string(&user).unwrap();
    println!("{compact}");

    // Serialize: User -> pretty JSON string
    let pretty = serde_json::to_string_pretty(&user).unwrap();
    println!("{pretty}");

    // Deserialize: JSON string -> User
    // Note the "userName" key, matching the rename attribute above.
    let json_text = r#"{ "userName": "Grace", "retries": 5 }"#;
    let parsed: User = serde_json::from_str(json_text).unwrap();
    println!("{parsed:?}");

    // Cross over to an untyped Value when the shape is dynamic
    let value: Value = json!({ "name": "Ada", "tags": ["a", "b"] });
    let first_tag = value["tags"][0].as_str(); // Option<&str>
    println!("{first_tag:?}");

    // Convert a typed value into a Value and back again
    let as_value = serde_json::to_value(&user).unwrap();
    let back: User = serde_json::from_value(as_value).unwrap();
    println!("{back:?}");
}
```

## Gotchas ⚠️

> ⚠️ `from_str` and `to_string` return a `Result` — handle the error instead of reaching for `unwrap` in real code.

- A missing field makes parsing **fail** unless it has `#[serde(default)]` (or is an `Option`, which defaults to `None`).
- Extra unknown fields in the input are **ignored** by default. Add `#[serde(deny_unknown_fields)]` on the struct to reject them.
- Indexing a `Value` with `[]` never panics on a bad key — it just yields `Value::Null`. That can quietly swallow mistakes, so prefer `.get(...)` plus the `as_*` accessors, which return `Option` and can be chained with `?`:

```rust
use serde_json::Value;

fn name(v: &Value) -> Option<&str> {
    v.get("user")?.get("name")?.as_str()
}
```

## See also

- [`Result` and `Option`](../types/result-and-option.md)
- [HTTP](./http.md)
