# Go Standard Library - Context API


The `context` package defines the `Context` type, which carries deadlines, cancellation signals, and other request-scoped values across API boundaries and between processes.

## 1. Import Path

```go
import "context"
```

---

## 2. Types and Interfaces

### Type `Context` (Interface)
`Context` is the core interface. It is safe for concurrent use by multiple goroutines simultaneously.

| Method | Signature | Description |
| :--- | :--- | :--- |
| `Deadline` | `Deadline() (deadline time.Time, ok bool)` | Returns the time when work on behalf of this context should be aborted. `ok` is `false` if no deadline is set." |
| `Done` | `Done() <-chan struct{}` | Returns a channel that's closed when work on behalf of this context should be aborted. Returns `nil` if the context can never be canceled. |
| `Err` | `Err() error` | If `Done` is not closed, returns `nil`. If `Done` is closed, returns a non-nil error explaining why. |
| `Value` | `Value(key any) any` | Returns the value associated with this context for `key`, or `nil` if no value is associated. |

## Type `CancelFunc`

### `type CancelFunc func()`
A function that tells an operation to abandon its work. It does not wait for the work to stop. A `CancelFunc` is idempotent; subsequent calls do nothing.

### type `CancelCauseFunc`
`type CancelCauseFunc func(cause error)`
Introduced in Go 1.20. Similar to `CancelFunc`, but allows providing an error that will be returned by `context.Cause(ctx)`.

### type `AfterFuncStopFunc`
`type AfterFuncStopFunc func() bool`
The return type of `AfterFunc`. Calling it prevents the associated function from running. Returns `true` if it stopped the function, `false` if the funct
ion already ran or was already stopped.

---

## 3. Root Context Construction

Root contexts are never canceled, have no values, and have no deadline. They serve as the top-level parent for all derived contexts.

| Function | Signature | Use Case |
| :--- | :--- | :--- |
| `Background` | `Background() Context` | The default root context. Used in `main`, `init`, and tests. |
| `TODO` | `TODO() Context` | Used when it is unclear which Context to use or when the surrounding function has not yet been updated to accept a Context.
 |

---

## 4. Context Derivation Matrix

All derivation functions take a `parent Context` and return a `child Context`. If the parent is canceled, the child is automatically canceled.

| Derivation Type | Function | Returns | Mechanism |
| :--- | :--- | :--- | :--- |
| **Cancellation** | `WithCancel` | `(Context, CancelFunc)` | Manual trigger via `CancelFunc`. |
| **Cancel w/ Cause** | `WithCancelCause` | `(Context, CancelCauseFunc)` | Manual trigger providing a specific `error`. |
| **Deadline** | `WithDeadline` | `(Context, CancelFunc)` | Automatic trigger at specific `time.Time`. |
| **Deadline w/ Cause**| `WithDeadlineCause`| `(Context, CancelFunc)` | Automatic trigger at `time.Time` with specific `error`. |
| **Timeout** | `WithTimeout` | `(Context, CancelFunc)` | Automatic trigger after `time.Duration`. |
| **Timeout w/ Cause** | `WithTimeoutCause` | `(Context, CancelFunc)` | Automatic trigger after `Duration` with specific `error`. |
| **Values** | `WithValue` | `Context` | Carries key/value pairs. No cancellation logic. |
| **Detached** | `WithoutCancel` | `Context` | Retains values but ignores parent cancellation/deadline. |

---

## 5. Function Reference

### `WithCancel(parent Context) (ctx Context, cancel CancelFunc)`
Returns a copy of `parent` with a new `Done` channel. The returned context's `Done` channel is closed when the returned `cancel` function is called or wh
en the parent context's `Done` channel is closed, whichever happens first.

- **Panic:** Panics if `parent` is `nil`.
- **Cleanup:** The caller must call `cancel` as soon as operations performed in this Context complete to release resources.

### `WithCancelCause(parent Context) (ctx Context, cancel CancelCauseFunc)`
Returns a copy of `parent` that can be canceled with an error (the "cause").
- **Behavior:** If canceled via `cancel(err)`, `context.Cause(ctx)` returns `err`.
- **Logic:** If canceled without a cause (via parent cancellation), `Cause(ctx)` returns the same as `ctx.Err()`.

### `WithDeadline(parent Context, d time.Time) (Context, CancelFunc)`
Returns a copy of `parent` with the deadline adjusted to be no later than `d`. 
- **Behavior:** If the parent's deadline is already earlier than `d`, `WithDeadline` is semantically equivalent to the parent.
- **Trigger:** Canceled when `d` elapses, `cancel` is called, or parent is canceled.

### `WithTimeout(parent Context, timeout time.Duration) (Context, CancelFunc)`
A wrapper for `WithDeadline(parent, time.Now().Add(timeout))`.

### `WithTimeoutCause(parent Context, timeout time.Duration, cause error) (Context, CancelFunc)`
Introduced in Go 1.21. When the timeout expires, the context is canceled and `Cause(ctx)` returns `cause`. If the context is canceled via the `CancelFunc
`, `Cause(ctx)` returns `context.Canceled`.

### `WithValue(parent Context, key, val any) Context`
Returns a copy of `parent` in which the value associated with `key` is `val`.
- **Lookup:** `Value` searches the chain of parents upward. It returns the first match found.
- **Constraints:** `key` must be comparable. To avoid collisions between packages, keys should be unexported custom types.
- **Safety:** `val` must be safe for concurrent access if it is a pointer or mutable structure.

### `AfterFunc(ctx Context, f func()) (stop func() bool)`
Introduced in Go 1.21. Arranges to call `f` in its own goroutine when `ctx` is done (canceled or expired).
- **Return:** A `stop` function. If `stop` returns `true`, `f` will not run.
- **Behavior:** If `ctx` is already done, `f` is called immediately in its own goroutine.
- **Multiple calls:** Multiple `AfterFunc` calls on the same context operate independently.

### `WithoutCancel(parent Context) Context`
Introduced in Go 1.21. Returns a copy of `parent` that is not canceled when `parent` is canceled.
- **Values:** The returned context contains all values of the parent.
- **Deadline:** The returned context has no deadline.
- **Use Case:** Background tasks that must finish (e.g., logging, rollbacks) even if the primary request context is timed out.

---

## 6. Utility Functions

### `Cause(c Context) error`
Returns a non-nil error explaining why `c` was canceled. The first error passed to a `CancelCauseFunc` in the context chain is returned.
- If the context was canceled but no cause was provided, it returns `ctx.Err()`.
- If the context is not yet canceled, returns `nil`.

---

## 7. Sentinels and Errors

| Variable | Type | Description |
| :--- | :--- | :--- |
| `Canceled` | `error` | Returned by `Context.Err` when the context is canceled using a `CancelFunc`. |
| `DeadlineExceeded` | `error` | Returned by `Context.Err` when the context's deadline passes. Implements `net.Error` (Timeout=true, Temporary=true). |

---

## 8. Behavioral Contracts

### Propagation
- **Downward:** Cancellation and deadlines propagate from parent to child.
- **Upward:** Value lookup propagates from child to parent.
- **Isolation:** A child's `CancelFunc` only affects the child and its descendants, never the parent or siblings.

### Memory and Goroutines
- **Leaking:** If a derived context is created (`WithCancel`, `WithDeadline`, etc.), and the `cancel` function is not called, the context remains in the 
parent's internal "children" map until the parent is canceled or the child times out. This can cause a memory leak.
- **Rule:** Always `defer cancel()` immediately after derivation unless the `CancelFunc` is passed elsewhere.

### Concurrency
- `Context` is immutable from the perspective of a consumer. 
- All `Context` methods are thread-safe.
- Multiple goroutines can hold the same `Context`.

---

## 9. Examples

### Cancellation with Cause
```go
package main

import (
        "context"
        "errors"
        "fmt"
)

func main() {
        var MyErr = errors.New("custom failure")
        ctx, cancel := context.WithCancelCause(context.Background())

        cancel(MyErr)

        fmt.Println(ctx.Err())           // Output: context canceled
        fmt.Println(context.Cause(ctx)) // Output: custom failure
}
```

### Detaching from Lifecycle (WithoutCancel)
```go
package main

import (
        "context"
        "time"
)

func handleRequest(ctx context.Context) {
        // Values from request are preserved
        detached := context.WithoutCancel(ctx)

        go func() {
                // This continues even if ctx times out
                saveToDatabase(detached)
        }()
}

func saveToDatabase(ctx context.Context) {}
```

### Context Value Keys
```go
type key int

const (
        userKey key = iota
        tokenKey
)

func WithUser(ctx context.Context, user string) context.Context {
        return context.WithValue(ctx, userKey, user)
}

func GetUser(ctx context.Context) (string, bool) {
        u, ok := ctx.Value(userKey).(string)
        return u, ok
}
```

---

## 10. Performance Characteristics

1.  **Allocation:** Every call to a "With" function (except `WithoutCancel` if the parent is already detached) allocates a new struct.
2.  **Value Lookup:** `Value()` is an $O(n)$ operation where $n$ is the depth of the context tree. It performs a linear search up the tree.
3.  **Cancellation:** Cancellation is $O(m)$ where $m$ is the number of immediate children derived from the canceled context. The internal implementation
 uses a `map[canceler]struct{}` to track children.
4.  **Done Channel:** The channel returned by `Done()` is created lazily on the first call to `Done()`.


