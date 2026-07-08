# Wget & Curl Cheatsheet

Both tools fetch content over HTTP/HTTPS/FTP. `wget` excels at recursive
downloads and mirroring; `curl` excels at flexible request crafting and
scripting against APIs.

## Wget Basics

```bash
wget https://example.com/file.zip           # download a file
wget -O newname.zip https://example.com/f   # save with a specific name
wget -c https://example.com/file.zip        # continue/resume partial download
wget -q https://example.com/file.zip        # quiet mode
wget -b https://example.com/file.zip        # download in background
wget -P /downloads https://example.com/f    # save to a specific directory
```

## Wget Recursive Downloads / Mirroring

```bash
wget -r https://example.com/                     # recursive download
wget -r -l 2 https://example.com/                 # limit recursion depth to 2
wget -m https://example.com/                       # mirror (recursive + timestamps + infinite depth)
wget --mirror --convert-links --page-requisites --no-parent https://example.com/
wget -np -nH -r https://example.com/dir/           # no parent, no host dir
```

### Mirroring Flags

| Flag | Meaning |
|---|---|
| `-m` / `--mirror` | Shortcut for recursive mirroring with sensible defaults |
| `--convert-links` | Rewrite links for local viewing |
| `--page-requisites` | Download images/CSS/JS needed to render pages |
| `--no-parent` | Don't ascend to parent directory |
| `-l N` | Max recursion depth |
| `-A` | Accept file extensions, e.g. `-A jpg,png` |
| `-R` | Reject file extensions |

## Wget Authentication and Headers

```bash
wget --user=name --password=pass https://example.com/f
wget --header="Authorization: Bearer TOKEN" https://api.example.com/data
wget --header="User-Agent: Mozilla/5.0" https://example.com
```

## Wget Rate Limiting and Retries

```bash
wget --limit-rate=200k https://example.com/f      # limit bandwidth
wget --tries=5 https://example.com/f               # retry on failure
wget --timeout=30 https://example.com/f            # connection timeout
wget --wait=2 -r https://example.com/               # delay between requests
```

## Wget from a List of URLs

```bash
wget -i urls.txt          # download every URL listed in urls.txt
```

## Curl Basics

```bash
curl https://example.com                      # print response to stdout
curl -O https://example.com/file.zip          # save with remote filename
curl -o out.zip https://example.com/file.zip  # save with custom filename
curl -L https://example.com                    # follow redirects
curl -s https://example.com                     # silent mode (no progress bar)
curl -sS https://example.com                     # silent but show errors
curl -v https://example.com                       # verbose (debugging)
curl -I https://example.com                        # headers only (HEAD request)
```

## Curl HTTP Methods

```bash
curl -X GET https://api.example.com/users
curl -X POST https://api.example.com/users -d '{"name":"Alice"}'
curl -X PUT https://api.example.com/users/1 -d '{"name":"Bob"}'
curl -X DELETE https://api.example.com/users/1
curl -X PATCH https://api.example.com/users/1 -d '{"active":false}'
```

## Curl Headers and Content Type

```bash
curl -H "Content-Type: application/json" -d '{"key":"value"}' https://api.example.com
curl -H "Authorization: Bearer TOKEN" https://api.example.com/data
curl -H "Accept: application/json" https://api.example.com
```

## Curl Sending Data

```bash
curl -d "name=Alice&age=30" https://example.com/form            # form-urlencoded
curl -d @data.json -H "Content-Type: application/json" https://api.example.com
curl -F "file=@photo.jpg" https://example.com/upload             # multipart form upload
curl -F "field=value" -F "file=@doc.pdf" https://example.com/upload
curl -G -d "q=search+term" https://example.com/search             # GET with query string
```

## Curl Authentication

```bash
curl -u username:password https://example.com          # basic auth
curl -u username https://example.com                     # prompts for password
curl --cert client.pem --key client.key https://example.com   # client cert
curl -H "Authorization: Bearer $TOKEN" https://api.example.com
```

## Curl Cookies

```bash
curl -c cookies.txt https://example.com/login       # save cookies
curl -b cookies.txt https://example.com/dashboard   # send saved cookies
curl -b "session=abc123" https://example.com          # send inline cookie
```

## Curl Output Control

```bash
curl -o /dev/null -s -w "%{http_code}\n" https://example.com   # just print status code
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://example.com
curl -s https://api.example.com | jq '.'                          # pretty-print JSON
curl -sw '\n' https://example.com                                   # add trailing newline
```

### Useful -w (write-out) Variables

| Variable | Meaning |
|---|---|
| `%{http_code}` | HTTP status code |
| `%{time_total}` | Total request time |
| `%{size_download}` | Bytes downloaded |
| `%{url_effective}` | Final URL after redirects |
| `%{remote_ip}` | Server IP address |

## Curl Retries, Timeouts, Rate Limits

```bash
curl --retry 5 https://example.com
curl --retry 5 --retry-delay 2 https://example.com
curl --max-time 30 https://example.com          # total timeout
curl --connect-timeout 10 https://example.com   # connection timeout only
curl --limit-rate 200k https://example.com/file.zip
```

## Curl Resume Downloads

```bash
curl -C - -O https://example.com/largefile.zip
```

## Curl and SSL

```bash
curl -k https://self-signed.example.com          # skip certificate verification (insecure)
curl --cacert ca.pem https://example.com           # use a specific CA bundle
curl -v https://example.com 2>&1 | grep -i ssl      # inspect TLS handshake
```

## Curl Proxies

```bash
curl -x http://proxy:8080 https://example.com
curl -x socks5://127.0.0.1:1080 https://example.com
curl --noproxy example.com -x http://proxy:8080 https://other.com
```

## Testing APIs Quickly

```bash
curl -s https://api.example.com/health | jq .status
curl -s -X POST https://api.example.com/login \
  -H "Content-Type: application/json" \
  -d '{"username":"me","password":"secret"}' | jq -r .token
```

## Comparing Wget and Curl

| Feature | Wget | Curl |
|---|---|---|
| Recursive download | Yes | No |
| Multiple protocol support | Limited | Extensive (HTTP, FTP, SMTP, IMAP, etc.) |
| Send arbitrary HTTP methods | Limited | Yes |
| Resume downloads | Yes (`-c`) | Yes (`-C -`) |
| Progress bar by default | Yes | No (use `-#`) |
| Scripting APIs / uploads | Limited | Excellent |
| Available by default | Not always | Almost always |

## Quick Reference: Common Tasks

```bash
# Download a file, resuming if interrupted
wget -c https://example.com/large.iso

# Mirror an entire static site for offline browsing
wget --mirror --convert-links --page-requisites --no-parent https://example.com/

# Check if a URL is reachable and get the status code
curl -o /dev/null -s -w "%{http_code}\n" https://example.com

# POST JSON and extract a field from the response
curl -s -X POST https://api.example.com/token -d '{"key":"val"}' \
  -H "Content-Type: application/json" | jq -r '.access_token'

# Download multiple files listed in a text file
wget -i urls.txt

# Upload a file via multipart form
curl -F "file=@report.pdf" https://example.com/upload
```
