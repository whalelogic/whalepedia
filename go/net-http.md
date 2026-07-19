# Go `net/http` Reference

Reference for core server/client APIs in the standard library package `net/http`.

## Core types and interfaces

| Symbol | Kind | Purpose |
| --- | --- | --- |
| `http.Client` | type | Sends HTTP requests |
| `http.Request` | type | Incoming or outgoing HTTP request |
| `http.Response` | type | HTTP response returned from transport/server |
| `http.Server` | type | Configurable HTTP server |
| `http.Handler` | interface | Handles HTTP requests (`ServeHTTP`) |
| `http.HandlerFunc` | type | Function adapter for `Handler` |
| `http.RoundTripper` | interface | Low-level transport implementation |
| `http.Cookie` | type | HTTP cookie value |

## Common package-level functions

| Function | Purpose |
| --- | --- |
| `http.Get` | Send a `GET` request |
| `http.Post` | Send a `POST` request |
| `http.PostForm` | Submit URL-encoded form data |
| `http.Head` | Send a `HEAD` request |
| `http.NewRequest` / `http.NewRequestWithContext` | Build a request object |
| `http.ListenAndServe` | Start HTTP server on address |
| `http.ListenAndServeTLS` | Start HTTPS server |
| `http.Handle` / `http.HandleFunc` | Register handlers on default mux |
| `http.FileServer` | Serve files from a filesystem |
| `http.Redirect` | Redirect request to another URL |
| `http.Error` | Write error response helper |

## `http.Client` methods

| Method | Purpose |
| --- | --- |
| `Do` | Execute prepared request |
| `Get` | Convenience GET |
| `Post` | Convenience POST |
| `PostForm` | Convenience form POST |
| `Head` | Convenience HEAD |
| `CloseIdleConnections` | Close keep-alive idle connections |

## `http.ResponseWriter` + `http.Request` usage map

| API | Purpose |
| --- | --- |
| `w.Header().Set` | Set response headers |
| `w.WriteHeader` | Set status code |
| `w.Write` | Write response body |
| `r.Context()` | Access request context |
| `r.URL.Query()` | Read query string values |
| `r.FormValue` | Read form values |
| `r.Cookie` | Read cookie by name |

## `http.Server` fields to know

| Field | Why it matters |
| --- | --- |
| `Addr` | Bind address |
| `Handler` | Router/mux implementation |
| `ReadTimeout` | Prevent slow-read abuse |
| `WriteTimeout` | Bound write duration |
| `IdleTimeout` | Control keep-alive idle windows |
| `MaxHeaderBytes` | Protect header parsing limits |

## Example: JSON API endpoint

```go
package main

import (
	"encoding/json"
	"net/http"
	"time"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})

	srv := &http.Server{
		Addr:         ":8080",
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  30 * time.Second,
	}

	_ = srv.ListenAndServe()
}
```

## Example: outbound request with context

```go
package main

import (
	"context"
	"net/http"
	"time"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	req, _ := http.NewRequestWithContext(ctx, http.MethodGet, "https://example.com", nil)
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return
	}
	defer resp.Body.Close()
}
```
