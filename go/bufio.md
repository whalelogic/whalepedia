The `bufio` package implements buffered I/O. It wraps an `io.Reader` or `io.Writer` object, creating another object (a `Reader` or `Writer`) that also im
plements the interface but provides buffering and help for textual input/output.

## 1. Import Path

```go
import "bufio"
```

---

## 2. Constants and Variables

| Name | Type | Value / Purpose |
| :--- | :--- | :--- |
| `MaxScanTokenSize` | `int` | `64 * 1024`. This sets the maximum size of a single token (like a line) the `Scanner` can process unless a custom buffer i
s provided. |
| `ErrInvalidUnreadByte` | `error` | This error is returned if `UnreadByte` is called but the last operation was not a read. |
| `ErrInvalidUnreadRune` | `error` | This error is returned if `UnreadRune` is called but the last operation was not a read. |
| `ErrBufferFull` | `error` | This error is returned when an operation cannot be completed because the internal buffer is full. |
| `ErrNegativeCount` | `error` | This error is returned if a negative number is passed to a method requiring a positive count. |
| `ErrTooLong` | `error` | This error is returned by `Scanner` when a token is too large for the buffer. |
| `ErrBadReadCount` | `error` | This error is returned when a reader reports it read more data than the buffer could hold. |
| `ErrFinalToken` | `error` | This is a special signal for `Split` functions to stop scanning but return no error. |

---

## 3. The Reader Type

A `Reader` implements buffering for an `io.Reader` object.

### Construction
| Function | Signature | This does this: |
| :--- | :--- | :--- |
| `NewReader` | `NewReader(rd io.Reader) *Reader` | This creates a new reader with a default buffer size (4096 bytes). |
| `NewReaderSize` | `NewReaderSize(rd io.Reader, size int) *Reader` | This creates a new reader with a custom buffer size. If the size is too small, it d
efaults to 16. |

### Methods
| Method | Signature | This does this: |
| :--- | :--- | :--- |
| `Buffered` | `Buffered() int` | This returns the number of bytes currently sitting in the buffer available to be read. |
| `Discard` | `Discard(n int) (discarded int, err error)` | This skips the next `n` bytes. It returns how many were actually skipped. |
| `Peek` | `Peek(n int) ([]byte, error)` | This shows you the next `n` bytes without moving the "read pointer." If `n` is larger than the buffer, it retu
rns an error. |
| `Read` | `Read(p []byte) (n int, err error)` | This reads data into the slice `p`. This fills `p` from the buffer first. |
| `ReadByte` | `ReadByte() (byte, error)` | This reads and returns exactly one byte. |
| `ReadBytes` | `ReadBytes(delim byte) ([]byte, error)` | This reads until it hits the `delim` byte. This returns a slice containing the data up to and i
ncluding the delimiter. |
| `ReadLine` | `ReadLine() (line []byte, isPrefix bool, err error)` | This tries to read a single line. If the line is too long for the buffer, `isPrefix
` is true. Use `ReadString` instead for most cases. |
| `ReadRune` | `ReadRune() (r rune, size int, err error)` | This reads a single UTF-8 character and returns the rune and its size in bytes. |
| `ReadSlice` | `ReadSlice(delim byte) (line []byte, err error)` | This reads until `delim`. The returned slice points directly into the buffer memory. T
he next read operation will overwrite this data. |
| `ReadString` | `ReadString(delim byte) (string, error)` | This does the same as `ReadBytes` but returns a string. |
| `Reset` | `Reset(r io.Reader)` | This clears the buffer and makes the Reader start reading from a new source `r`. |
| `Size` | `Size() int` | This returns the total size of the internal buffer. |
| `UnreadByte` | `UnreadByte() error` | This "undoes" the last byte read, moving the pointer back by one. |
| `UnreadRune` | `UnreadRune() error` | This "undoes" the last rune read. |
| `WriteTo` | `WriteTo(w io.Writer) (int64, error)` | This takes all data from the buffer/source and writes it into `w`. |

---

## 4. The Writer Type

A `Writer` implements buffering for an `io.Writer` object. If an error occurs during writing, the `Writer` stops accepting data and returns that error.

### Construction
| Function | Signature | This does this: |
| :--- | :--- | :--- |
| `NewWriter` | `NewWriter(w io.Writer) *Writer` | This creates a writer with a default buffer size (4096 bytes). |
| `NewWriterSize` | `NewWriterSize(w io.Writer, size int) *Writer` | This creates a writer with a custom buffer size. |

### Methods
| Method | Signature | This does this: |
| :--- | :--- | :--- |
| `Available` | `Available() int` | This returns how many bytes of space are left in the buffer. |
| `AvailableBuffer`| `AvailableBuffer() []byte` | This returns an empty slice with a capacity equal to the remaining buffer space. |
| `Buffered` | `Buffered() int` | This returns the number of bytes that have been written to the buffer but not yet sent to the source. |
| `Flush` | `Flush() error` | This forces the writer to send all buffered data to the underlying `io.Writer`. **This must be called to ensure all data is
 saved.** |
| `ReadFrom` | `ReadFrom(r io.Reader) (int64, error)` | This reads everything from `r` and writes it into the buffer/source. |
| `Reset` | `Reset(w io.Writer)` | This clears any buffered data and switches the destination to `w`. |
| `Size` | `Size() int` | This returns the total size of the internal buffer. |
| `Write` | `Write(p []byte) (nn int, err error)` | This writes the contents of `p` into the buffer. |
| `WriteByte` | `WriteByte(c byte) error` | This writes a single byte. |
| `WriteRune` | `WriteRune(r rune) (size int, err error)` | This writes a single UTF-8 character. |
| `WriteString` | `WriteString(s string) (int, error)` | This writes a string into the buffer. |

---

## 5. The Scanner Type

A `Scanner` provides a convenient way to read data like lines or space-separated words.

### Construction
| Function | Signature | This does this: |
| :--- | :--- | :--- |
| `NewScanner` | `NewScanner(r io.Reader) *Scanner` | This creates a new scanner reading from `r`. The default split function is `ScanLines`. |

### Methods
| Method | Signature | This does this: |
| :--- | :--- | :--- |
| `Buffer` | `Buffer(buf []byte, max int)` | This tells the scanner to use a specific slice as its buffer and sets a new maximum token size. |
| `Bytes` | `Bytes() []byte` | This returns the most recent token found by a call to `Scan`. The slice points to internal memory and will change on the n
ext `Scan`. |
| `Err` | `Err() error` | This returns the first non-EOF error that the scanner encountered. |
| `Scan` | `Scan() bool` | This tries to find the next token (like the next line). It returns `true` if it found one and `false` if it hit the end or an 
error. |
| `Split` | `Split(split SplitFunc)` | This changes how the scanner identifies tokens (e.g., change from lines to words). |
| `Text` | `Text() string` | This returns the most recent token as a string. |

### Predefined Split Functions
These are used with `Scanner.Split`:
- `ScanBytes`: This splits the input into individual bytes.
- `ScanLines`: This splits the input into lines (dropping the `\n` or `\r\n`).
- `ScanRunes`: This splits the input into UTF-8 characters.
- `ScanWords`: This splits the input into space-separated words.

---

## 6. The ReadWriter Type

This is a struct that holds a pointer to a `Reader` and a `Writer`. It implements both `io.Reader` and `io.Writer`.

```go
type ReadWriter struct {
        *Reader
        *Writer
}
```

- **Construction:** `NewReadWriter(r *Reader, w *Writer) *ReadWriter`

---

## 7. Behavioral Contracts and Edge Cases

### Concurrency
- `bufio.Reader` and `bufio.Writer` are **not** safe for use by multiple goroutines at the same time. You must use a lock (like `sync.Mutex`) if multiple
 routines need to access one.

### Memory Safety
- `Reader.Peek`, `Reader.ReadSlice`, and `Scanner.Bytes` return slices that point to **internal buffers**. These slices are only valid until the next rea
d or scan operation. If you need the data to last longer, you must copy it.

### Writer Flushing
- If you do not call `Flush()` on a `bufio.Writer`, data may remain in the buffer and never be written to the file or network connection.

### Scanner Limits
- The default `Scanner` will fail if a single line is longer than 64KB. To handle longer lines, use `Scanner.Buffer` to provide a larger slice and a larg
er max size.

---

## 8. Examples

### Basic Reading (This reads a file line by line)
```go
package main

import (
        "bufio"
        "fmt"
        "os"
)

func main() {
        file, _ := os.Open("test.txt")
        defer file.Close()

        scanner := bufio.NewScanner(file)
        for scanner.Scan() {
                fmt.Println(scanner.Text()) // This prints each line
        }

        if err := scanner.Err(); err != nil {
                fmt.Fprintln(os.Stderr, "error:", err)
        }
}
```

### Basic Writing (This uses a buffer to save a string)
```go
package main

import (
        "bufio"
        "os"
)

func main() {
        f, _ := os.Create("output.txt")
        defer f.Close()

        w := bufio.NewWriter(f)
        w.WriteString("This is buffered string.")

        // This ensures the string actually goes into the file
        w.Flush() 
}
```
