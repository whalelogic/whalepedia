# Python Requests (`requests`)

Quick reference for the most-used `requests` APIs.

## Top-level request methods

| Method | Purpose | Common Args |
| --- | --- | --- |
| `requests.get` | Read resource | `url`, `params`, `headers`, `timeout` |
| `requests.post` | Create resource | `url`, `json`/`data`, `headers`, `timeout` |
| `requests.put` | Replace resource | `url`, `json`/`data`, `headers`, `timeout` |
| `requests.patch` | Partial update | `url`, `json`/`data`, `headers`, `timeout` |
| `requests.delete` | Delete resource | `url`, `headers`, `timeout` |
| `requests.head` | Fetch headers only | `url`, `headers`, `timeout` |
| `requests.options` | Read allowed operations | `url`, `headers`, `timeout` |
| `requests.request` | Generic entry point | `method`, `url`, other kwargs |

## Session methods

| Session API | Purpose |
| --- | --- |
| `Session.get/post/put/patch/delete` | Reuse TCP connections and shared headers |
| `Session.request` | Generic request with shared session config |
| `Session.close` | Release adapter resources |
| `Session.mount` | Register custom transport adapter |

## Response methods and properties

| Response API | Purpose |
| --- | --- |
| `response.status_code` | HTTP status |
| `response.headers` | Response header map |
| `response.text` | Decoded body text |
| `response.content` | Raw bytes |
| `response.json()` | Parse JSON payload |
| `response.raise_for_status()` | Raise on 4xx/5xx statuses |
| `response.iter_content()` | Stream response chunks |

## Examples

```python
import requests

resp = requests.get(
    "https://api.github.com/repos/whalelogic/whalepedia",
    timeout=10,
)
resp.raise_for_status()
print(resp.json()["name"])
```

```python
import requests

with requests.Session() as session:
    session.headers.update({"Accept": "application/json"})
    resp = session.post(
        "https://httpbin.org/post",
        json={"topic": "requests"},
        timeout=10,
    )
    resp.raise_for_status()
    print(resp.status_code)
```
