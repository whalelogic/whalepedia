Here is a comprehensive, well-grounded guide to idiomatic Go error handling, covering both the foundational philosophy and the latest best practices 

For Go 1.20+/1.22+.

---

# Idiomatic Error Handling in Go (Go 1.22+)

## 1. The Core Philosophy

Go's approach to error handling is based on several key principles:

- **Errors are values** — they behave like regular return values.
- **Explicit handling** — you must check and act on them.
- **No hidden control flow** — no try/catch blocks changing execution unexpectedly.
- **Fail fast** — surface problems early instead of letting them propagate silently.

This explicit style forces developers to think about error cases right where they occur.

In Go, errors are treated as values, specifically of the `error` interface type. Instead of throwing exceptions, functions that can fail return an error as on
e of their return values. The caller is responsible for checking and handling this error explicitly.

---

## 2. The `error` Interface

The entire system is built on one simple interface:

```go
type error interface {
    Error() string
}
```

Functions that can fail return an error as their last return value. The caller checks if the error is `nil` and handles it accordingly.

```go
func readFile(filename string) ([]byte, error) {
    data, err := os.ReadFile(filename)
    if err != nil {
        return nil, err
    }
    return data, nil
}
```

---

## 3. Creating Errors: `errors.New` vs `fmt.Errorf`

The two core functions are `errors.New` and `fmt.Errorf`. Both return values of type `error`. `errors.New` is the simplest option — each call creates a distin
ct error value, even if the message text is identical. By contrast, `fmt.Errorf` allows you to build error values using formatted strings. Since Go 1.13, `fmt
.Errorf` has also supported the `%w` verb, which lets developers wrap an existing error with added context.

Lean towards `fmt.Errorf` in most cases, especially when errors propagate through multiple layers of your application. The ability to add context and wrap und
erlying errors is a powerful debugging aid. Reserve `errors.New` primarily for defining `var` sentinel errors that are checked explicitly within your applicat
ion logic.

**Error message style conventions:**
Be concise but informative: provide enough information to understand what went wrong without being overly verbose. Avoid redundancy: if wrapping an error, the
 outer error message should add new context, not just repeat the inner error. Error strings should also be lowercase and not end with punctuation.

---

## 4. Error Wrapping with `%w` (Go 1.13+)

Go 1.13 introduced error wrapping with the `%w` verb, allowing you to add context to errors while preserving the original error for inspection. This creates e
rror chains that make debugging much easier.

```go
func loadConfig(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("loadConfig(%s): %w", path, err)
    }
    return data, nil
}

func initApp() error {
    _, err := loadConfig("/etc/app/config.yaml")
    if err != nil {
        return fmt.Errorf("initApp failed: %w", err)
    }
    return nil
}
```

The resulting error string reads like a breadcrumb trail:

> `initApp failed: loadConfig(/etc/app/config.yaml): open ...: no such file or directory`

**When NOT to wrap:** Don't wrap when the caller shouldn't know about internal errors. Log internally and return a sanitized error instead.

```go
func (s *Service) DoSomething() error {
    err := s.internalOperation()
    if err != nil {
        log.Printf("internal error: %v", err)
        return ErrServiceUnavailable // Don't expose internals
    }
    return nil
}
```

Also, to avoid exposing internal details to the caller, repackage it as a new error using `%v` (not `%w`) — `%w` would permit the caller to unwrap the origina
l error.

---

## 5. Sentinel Errors

If we wish a function to return an identifiable error condition, such as "item not found," we might return an error wrapping a sentinel:

```go
var ErrNotFound = errors.New("not found")

func FetchItem(name string) (*Item, error) {
    if itemNotFound(name) {
        return nil, fmt.Errorf("%q: %w", name, ErrNotFound)
    }
    // ...
}
```

The Go standard library is a good guide to what works in practice: `io.EOF` is a sentinel (no additional data, caller just knows reading is done); `sql.ErrNoR
ows` lets the caller distinguish "no result" from "connection error"; `context.Canceled` / `context.DeadlineExceeded` are two distinct sentinels the caller ca
n react to differently.

The rule is simple: pick the simplest pattern that meets the caller's actual needs. If the caller doesn't need to distinguish cases, `fmt.Errorf` is enough. I
f the caller needs to make different decisions, a sentinel error is the right tool. If the error needs to carry structured data, an error struct is the answer
.

---

## 6. Inspecting Errors: `errors.Is` and `errors.As`

In the simplest case, the `errors.Is` function behaves like a comparison to a sentinel error, and the `errors.As` function behaves like a type assertion. When
 operating on wrapped errors, however, these functions consider all the errors in a chain.

### `errors.Is` — check for a specific error value

Use `errors.Is()` when you want to check if an error (or any error in its chain) matches a specific sentinel error.

```go
err := processFile("missing.txt")
if errors.Is(err, os.ErrNotExist) {
    fmt.Println("File does not exist - create it first")
}
```

> ⚠️ Always use `errors.Is` instead of `==` for sentinel checks on potentially wrapped errors. A direct comparison wouldn't succeed with a wrapped error, but 
> `errors.Is` can inspect the error on a deeper level to see what sentinel value is hidden inside the wrapping.

### `errors.As` — extract a specific error type

Use `errors.As()` when you need to extract a specific error type to access its fields. The key difference: `errors.Is()` answers "is this error or any wrapped
 error equal to X?" while `errors.As()` answers "does this error chain contain an error of type T, and if so, give me that error."

```go
var netErr *net.OpError
if errors.As(err, &netErr) {
    fmt.Printf("Network op failed: %s\n", netErr.Op)
}
```

Never use direct type assertion (`err.(*ValidationError)`) — it doesn't traverse `%w` wrapping. Always use `errors.As` instead.

---

## 7. Custom Error Types

Use a struct when callers need structured information from the error:

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}
```

To support error chaining, custom error types should implement the `Unwrap()` method. This method should return the underlying error that the custom error wra
ps.

```go
func (e *ValidationError) Unwrap() error {
    return e.Cause
}
```

---

## 8. Joining Multiple Errors with `errors.Join` (Go 1.20+)

Go 1.20 added `errors.Join` for grouping multiple errors. This is especially useful for validation or batch operations:

```go
func validateRequest(name, email string, age int) error {
    var errs []error
    if name == "" {
        errs = append(errs, fmt.Errorf("name is required"))
    }
    if email == "" {
        errs = append(errs, fmt.Errorf("email is required"))
    }
    if age < 0 || age > 150 {
        errs = append(errs, fmt.Errorf("age must be between 0 and 150"))
    }
    return errors.Join(errs...) // returns nil if slice is empty
}
```

`errors.Join` concatenates errors from the list with newline characters. `errors.Is` and `errors.As` were updated in Go 1.20 to work on both lists and trees o
f errors.

Beware: `errors.Unwrap` always returns `nil` for errors created with `errors.Join` — use `errors.Is`/`errors.As` instead for inspection.

Also in Go 1.20+, `fmt.Errorf` now accepts multiple `%w` format verbs, letting you wrap more than one error in a single call.

---

## 9. Handle Errors Once, Not at Every Layer

A common mistake is handling errors at every level — logging, then returning, then logging again. Handle errors once, at the level where you have enough conte
xt to make a decision. Wrap with context lower down, and handle (log/respond) only at the top.

```go
// ❌ Bad: logs at every level
func badFetchData() error {
    err := queryDatabase()
    if err != nil {
        log.Println("database query failed:", err) // logs here
        return err
    }
    return nil
}

// ✅ Good: wrap with context, handle once at the top
func fetchData() error {
    err := queryDatabase()
    if err != nil {
        return fmt.Errorf("fetching data: %w", err) // just wrap
    }
    return nil
}
```

---

## 10. `panic` / `recover` — Use Sparingly

Don't use `panic` for ordinary error handling. This is the golden rule. `panic` is not Go's equivalent of try-catch. Overusing panic makes code harder to unde
rstand, debug, and reason about, as it bypasses the explicit error-checking flow.

Use `panic` for unrecoverable programmer errors or truly exceptional conditions that indicate a bug or a state where the program cannot reasonably continue. I
f an external user input or environmental factor leads to a problem, it's probably an error. If the problem is due to faulty logic within your code that shoul
d have been prevented, it's often a case for a panic.

If you must use `recover`, be cautious: blindly recovering from all panics might mask critical issues. It's often better to let the program crash (and thus al
ert you to the problem) than to continue in an undefined state. Also remember that recovering only affects the current goroutine.

---

## Quick Reference: Decision Guide

| Situation                           | Tool                                     |
| ----------------------------------- | ---------------------------------------- |
| Simple static error constant        | `errors.New` → stored as `var ErrFoo`    |
| Error with dynamic context          | `fmt.Errorf("context: %w", err)`         |
| Check error identity (sentinel)     | `errors.Is(err, ErrFoo)`                 |
| Extract structured error type       | `errors.As(err, &target)`                |
| Multiple errors (validation, batch) | `errors.Join(err1, err2, ...)`           |
| Truly unrecoverable programmer bug  | `panic` + `recover` in deferred function |
| Hide internal error from caller     | `fmt.Errorf("msg: %v", err)` (no `%w`)   |

---

## On Future Syntax Changes

The complaints about the verbosity of error handling persist (see Go Developer Survey 2024 H1 Results). However, many Go developers report that as one becomes
 more fluent and writes more idiomatic Go code, the issue becomes much less important — and there is no overwhelming support for a language change at this tim
e. The `if err != nil` pattern remains the standard for the foreseeable future.
