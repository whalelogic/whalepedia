# Go `io.Reader`, `io.Writer` & `bufio.Scanner` Reference

A complete reference for Go's core I/O interfaces and the buffered scanning utilities built on top of them.

---

## `io.Reader`

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

| Aspect | Detail |
|--------|--------|
| Purpose | Reads up to `len(p)` bytes into `p` |
| Return `n` | Number of bytes actually read (`0 <= n <= len(p)`) |
| Return `err` | `nil` on success, `io.EOF` when the stream is exhausted, or another error |
| Contract | May return `n > 0` **and** a non-nil `err` (including `io.EOF`) in the same call — always process the `n` bytes returned before checking `err` |
| Contract | A call that returns `n == 0` and `err == nil` is legal but discouraged; callers should treat it as "try again" |
| Reuse | Implementations should not retain `p` after `Read` returns |

### Common implementations

| Type | Package | Notes |
|------|---------|-------|
| `strings.Reader` | `strings` | Reads from an in-memory string |
| `bytes.Reader` | `bytes` | Reads from an in-memory `[]byte`, supports seeking |
| `bytes.Buffer` | `bytes` | Read/write in-memory buffer |
| `os.File` | `os` | Reads from a file or stdin |
| `bufio.Reader` | `bufio` | Wraps a reader with buffering |
| `net.Conn` | `net` | Reads from a network connection |
| `http.Response.Body` | `net/http` | Reads an HTTP response body (must be closed) |
| `gzip.Reader` | `compress/gzip` | Decompresses on the fly |

### Related reader interfaces

| Interface | Extra method(s) | Purpose |
|-----------|------------------|---------|
| `io.ReadCloser` | `Close() error` | Readable stream that must be closed (e.g. files, HTTP bodies) |
| `io.ReadSeeker` | `Seek(offset int64, whence int) (int64, error)` | Reader that supports random access |
| `io.ReaderAt` | `ReadAt(p []byte, off int64) (n int, err error)` | Stateless, concurrency-safe reads at an offset |
| `io.ReadWriter` | `Read` + `Write` | Both readable and writable |
| `io.ByteReader` | `ReadByte() (byte, error)` | Reads a single byte |
| `io.RuneReader` | `ReadRune() (r rune, size int, err error)` | Reads a single UTF-8 rune |

---

## `io.Writer`

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}
```

| Aspect | Detail |
|--------|--------|
| Purpose | Writes `len(p)` bytes from `p` to the underlying stream |
| Return `n` | Number of bytes actually written |
| Return `err` | Non-nil if `n < len(p)`; must not modify slice data |
| Contract | Implementations must not retain `p` after `Write` returns |
| Contract | A short write (`n < len(p)`) must be accompanied by a non-nil error |

### Common implementations

| Type | Package | Notes |
|------|---------|-------|
| `os.Stdout` / `os.Stderr` | `os` | Standard output/error streams |
| `strings.Builder` | `strings` | Efficient in-memory string building |
| `bytes.Buffer` | `bytes` | Read/write in-memory buffer |
| `os.File` | `os` | Writes to a file |
| `bufio.Writer` | `bufio` | Wraps a writer with buffering (must `Flush()`) |
| `net.Conn` | `net` | Writes to a network connection |
| `gzip.Writer` | `compress/gzip` | Compresses on the fly |
| `io.Discard` | `io` | Writer that discards all data (like `/dev/null`) |

### Related writer interfaces

| Interface | Extra method(s) | Purpose |
|-----------|------------------|---------|
| `io.WriteCloser` | `Close() error` | Writable stream that must be closed |
| `io.WriteSeeker` | `Seek` | Writer that supports random access |
| `io.WriterAt` | `WriteAt(p []byte, off int64) (n int, err error)` | Stateless writes at an offset |
| `io.ByteWriter` | `WriteByte(c byte) error` | Writes a single byte |
| `io.StringWriter` | `WriteString(s string) (n int, err error)` | Writes a string without a `[]byte` conversion |

---

## `io` Package Helper Functions

| Function | Signature (simplified) | Purpose |
|----------|-------------------------|---------|
| `io.Copy` | `Copy(dst Writer, src Reader) (int64, error)` | Streams all data from `src` to `dst` |
| `io.CopyN` | `CopyN(dst Writer, src Reader, n int64) (int64, error)` | Copies exactly `n` bytes |
| `io.CopyBuffer` | `CopyBuffer(dst, src, buf []byte) (int64, error)` | Like `Copy` but with a caller-supplied buffer |
| `io.ReadAll` | `ReadAll(r Reader) ([]byte, error)` | Reads until EOF, returns everything |
| `io.ReadFull` | `ReadFull(r Reader, buf []byte) (int, error)` | Reads exactly `len(buf)` bytes or errors |
| `io.WriteString` | `WriteString(w Writer, s string) (int, error)` | Writes a string, using `WriteString` if available |
| `io.MultiReader` | `MultiReader(readers ...Reader) Reader` | Concatenates readers into one logical stream |
| `io.MultiWriter` | `MultiWriter(writers ...Writer) Writer` | Duplicates writes to multiple writers |
| `io.TeeReader` | `TeeReader(r Reader, w Writer) Reader` | Reads from `r`, mirroring bytes to `w` as they're read |
| `io.LimitReader` | `LimitReader(r Reader, n int64) Reader` | Caps reading to `n` bytes, then `io.EOF` |
| `io.Pipe` | `Pipe() (*PipeReader, *PipeWriter)` | In-memory synchronous pipe connecting a writer and reader goroutine |
| `io.NopCloser` | `NopCloser(r Reader) ReadCloser` | Wraps a `Reader` with a no-op `Close` |

---

## `bufio.Scanner`

```go
type Scanner struct { /* unexported fields */ }

func NewScanner(r io.Reader) *Scanner
```

Wraps an `io.Reader` and splits its input into tokens (lines, words, runes, or custom units), one token per `Scan()` call.

### Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `Scan` | `(s *Scanner) Scan() bool` | Advances to the next token; returns `false` at EOF or on error |
| `Text` | `(s *Scanner) Text() string` | Returns the current token as a `string` |
| `Bytes` | `(s *Scanner) Bytes() []byte` | Returns the current token as `[]byte` (valid only until next `Scan`) |
| `Err` | `(s *Scanner) Err() error` | Returns the first non-EOF error encountered (nil if input ended cleanly) |
| `Split` | `(s *Scanner) Split(split SplitFunc)` | Sets the tokenizing function; call before first `Scan` |
| `Buffer` | `(s *Scanner) Buffer(buf []byte, max int)` | Sets the initial buffer and max token size (default max ~64KB) |

### Built-in split functions

| Function | Splits on |
|----------|-----------|
| `bufio.ScanLines` | Newlines (default); strips trailing `\r` |
| `bufio.ScanWords` | Whitespace-separated words |
| `bufio.ScanRunes` | Individual UTF-8 runes |
| `bufio.ScanBytes` | Individual bytes |

### Key gotchas

| Situation | Behavior |
|-----------|----------|
| Token longer than buffer max | `Scan` returns `false`; `Err()` returns `bufio.ErrTooLong` |
| Need larger tokens (e.g. long lines) | Call `scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024)` before scanning |
| Checking for real errors | Always call `Err()` after the `Scan` loop ends — `false` alone doesn't distinguish EOF from error |
| `Scanner` vs `bufio.Reader.ReadString` | `Scanner` is simpler for line/word iteration; `ReadString`/`ReadBytes` give more control (e.g. keeping delimiters) |

---

## `bufio.Reader` & `bufio.Writer` (quick complement)

| Type | Key methods | Notes |
|------|--------------|-------|
| `bufio.Reader` | `ReadString(delim byte)`, `ReadBytes(delim byte)`, `ReadLine()`, `ReadByte()`, `ReadRune()`, `Peek(n int)` | Buffers reads from a wrapped `io.Reader`; `Peek` looks ahead without consuming |
| `bufio.Writer` | `Write(p []byte)`, `WriteString(s string)`, `WriteByte(c byte)`, `WriteRune(r rune)`, `Flush() error` | Buffers writes; **must call `Flush`** or buffered data may never reach the underlying writer |

---

## Interface Composition Cheat Sheet

| Interface | Composed of |
|-----------|-------------|
| `io.ReadWriter` | `Reader` + `Writer` |
| `io.ReadWriteCloser` | `Reader` + `Writer` + `Closer` |
| `io.ReadCloser` | `Reader` + `Closer` |
| `io.WriteCloser` | `Writer` + `Closer` |
| `io.ReadWriteSeeker` | `Reader` + `Writer` + `Seeker` |

---

## Patterns

### 1. Read an entire file into memory
```go
data, err := os.ReadFile("input.txt") // shortcut; internally uses io.ReadAll
if err != nil {
    log.Fatal(err)
}
fmt.Println(string(data))
```

### 2. Read all bytes from any `io.Reader`
```go
resp, err := http.Get("https://example.com")
if err != nil {
    log.Fatal(err)
}
defer resp.Body.Close()

body, err := io.ReadAll(resp.Body)
if err != nil {
    log.Fatal(err)
}
fmt.Println(len(body))
```

### 3. Line-by-line scanning with `bufio.Scanner`
```go
file, err := os.Open("input.txt")
if err != nil {
    log.Fatal(err)
}
defer file.Close()

scanner := bufio.NewScanner(file)
for scanner.Scan() {
    line := scanner.Text()
    fmt.Println(line)
}
if err := scanner.Err(); err != nil {
    log.Fatal(err)
}
```

### 4. Word-by-word scanning
```go
scanner := bufio.NewScanner(strings.NewReader("the quick brown fox"))
scanner.Split(bufio.ScanWords)
for scanner.Scan() {
    fmt.Println(scanner.Text())
}
```

### 5. Reading stdin interactively
```go
scanner := bufio.NewScanner(os.Stdin)
fmt.Print("Enter your name: ")
if scanner.Scan() {
    name := scanner.Text()
    fmt.Printf("Hello, %s!\n", name)
}
```

### 6. Handling long lines that exceed the default buffer
```go
scanner := bufio.NewScanner(file)
buf := make([]byte, 0, 64*1024)
scanner.Buffer(buf, 1024*1024) // allow tokens up to 1MB
for scanner.Scan() {
    process(scanner.Bytes())
}
```

### 7. Buffered writing (remember to `Flush`)
```go
file, err := os.Create("output.txt")
if err != nil {
    log.Fatal(err)
}
defer file.Close()

w := bufio.NewWriter(file)
defer w.Flush() // deferred flushes run LIFO, after file.Close() is deferred — see note below

for _, line := range lines {
    fmt.Fprintln(w, line)
}
```
> **Note:** `defer` runs in LIFO order. In the snippet above `w.Flush()` (deferred second) runs *before* `file.Close()` (deferred first), so the flush correctly happens before the file closes — but it's often clearer to flush explicitly rather than rely on defer ordering:
```go
w := bufio.NewWriter(file)
for _, line := range lines {
    fmt.Fprintln(w, line)
}
if err := w.Flush(); err != nil {
    log.Fatal(err)
}
```

### 8. Streaming copy without loading everything into memory
```go
src, _ := os.Open("large-input.bin")
defer src.Close()
dst, _ := os.Create("large-output.bin")
defer dst.Close()

written, err := io.Copy(dst, src)
if err != nil {
    log.Fatal(err)
}
fmt.Println("bytes copied:", written)
```

### 9. Tee-ing a stream (read + capture simultaneously)
```go
var buf bytes.Buffer
tee := io.TeeReader(resp.Body, &buf) // reading from tee also writes into buf

scanner := bufio.NewScanner(tee)
for scanner.Scan() {
    process(scanner.Text())
}
// buf now holds a full copy of everything read
fmt.Println("raw bytes captured:", buf.Len())
```

### 10. Fan-out writes with `io.MultiWriter`
```go
logFile, _ := os.Create("app.log")
defer logFile.Close()

// Write simultaneously to stdout and a log file
mw := io.MultiWriter(os.Stdout, logFile)
fmt.Fprintln(mw, "server started")
```

### 11. Concatenating multiple readers with `io.MultiReader`
```go
r1 := strings.NewReader("part one. ")
r2 := strings.NewReader("part two.")
combined := io.MultiReader(r1, r2)

data, _ := io.ReadAll(combined)
fmt.Println(string(data)) // "part one. part two."
```

### 12. Custom `io.Writer` (e.g. capturing log output)
```go
type stringWriter struct {
    lines []string
}

func (w *stringWriter) Write(p []byte) (int, error) {
    w.lines = append(w.lines, string(p))
    return len(p), nil
}

sw := &stringWriter{}
logger := log.New(sw, "", 0)
logger.Println("captured message")
fmt.Println(sw.lines)
```

### 13. Custom `io.Reader` (generate data on the fly)
```go
type zeroReader struct{}

func (zeroReader) Read(p []byte) (int, error) {
    for i := range p {
        p[i] = 0
    }
    return len(p), nil
}

buf := make([]byte, 10)
io.ReadFull(zeroReader{}, buf) // buf is now 10 zero bytes
```

### 14. Limiting how much is read from an untrusted source
```go
// Protect against unbounded request bodies
limited := io.LimitReader(r.Body, 1<<20) // cap at 1MB
data, err := io.ReadAll(limited)
if err != nil {
    log.Fatal(err)
}
```

### 15. Piping a writer to a reader across goroutines
```go
pr, pw := io.Pipe()

go func() {
    defer pw.Close()
    fmt.Fprintln(pw, "streamed from a goroutine")
}()

scanner := bufio.NewScanner(pr)
for scanner.Scan() {
    fmt.Println("received:", scanner.Text())
}
```

### 16. Combining `bufio.Scanner` + custom `SplitFunc`
```go
// Split on commas instead of lines/words
onComma := func(data []byte, atEOF bool) (advance int, token []byte, err error) {
    if atEOF && len(data) == 0 {
        return 0, nil, nil
    }
    if i := bytes.IndexByte(data, ','); i >= 0 {
        return i + 1, data[:i], nil
    }
    if atEOF {
        return len(data), data, nil
    }
    return 0, nil, nil // request more data
}

scanner := bufio.NewScanner(strings.NewReader("a,b,c"))
scanner.Split(onComma)
for scanner.Scan() {
    fmt.Println(scanner.Text()) // a, b, c
}
```

### 17. Wrapping a reader so `Close` is a no-op (satisfy `ReadCloser`)
```go
func stringToReadCloser(s string) io.ReadCloser {
    return io.NopCloser(strings.NewReader(s))
}
```

---

### Sources
Based on the Go standard library documentation for `io`, `bufio`, `os`, and related packages (`pkg.go.dev/io`, `pkg.go.dev/bufio`).
