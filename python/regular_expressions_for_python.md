## 📌 Introduction

Regular expressions (regex) are a **🔥 powerful tool** for **pattern matching** and **text manipulation**. They allow you to **🔍 search, 📝 extract, and 🔄 replace** specific patterns within strings, making them invaluable for tasks like:
- **✅ Data validation**
- **📊 Parsing**
- **🔎 Text mining**
- **📂 Log analysis**
- **🔄 Search-and-replace operations**

This guide will introduce you to the **fundamental concepts, syntax, and real-world applications** of regular expressions.

---

## 📋 Table of Contents
1. [Basic Syntax](#basic-syntax)
2. [Special Characters](#special-characters)
3. [Grouping and Capturing](#grouping-and-capturing)
4. [Lookaheads and Lookbehinds](#lookaheads-and-lookbehinds)
5. [Common Use Cases](#common-use-cases)
6. [Regex in Python](#regex-in-python)
7. [Performance Considerations](#performance-considerations)
8. [Practical Examples](#practical-examples)
9. [Debugging and Testing](#debugging-and-testing)
10. [Conclusion](#conclusion)

---

## 📖 Basic Syntax 

### 🔤 Literal Characters
Match **exact characters**. For example, the regex `hello` will match the string `"hello"`.

### 🅰️ Character Classes
Match **sets of characters**:
   Syntax       | Description                                      | Example                     | 
 |--------------|--------------------------------------------------|-----------------------------| 
 | `[a-z]`      | Matches any lowercase letter.                    | `a`, `b`, `z`               | 
 | `[A-Z]`      | Matches any uppercase letter.                    | `A`, `B`, `Z`               | 
 | `[0-9]`      | Matches any digit.                               | `0`, `1`, `9`               | 
 | `[a-zA-Z0-9]`| Matches any alphanumeric character.              | `a`, `B`, `1`               | 
 | `[^a-z]`     | Matches any character **except** lowercase letters. | `A`, `1`, `@`           | 

---

### 🏷️ Anchors
Match the **beginning or end** of a string:
 | Syntax | Description                                      | Example                     | 
 |--------|--------------------------------------------------|-----------------------------| 
 | `^`    | Matches the **beginning** of the string.         | `^hello` matches `"hello world"` | 
 | `$`    | Matches the **end** of the string.               | `world$` matches `"hello world"` | 

---

### 🔢 Quantifiers
Specify **how many times** a character or group should be repeated:
 | Syntax  | Description                                      | Example                     | 
 |---------|--------------------------------------------------|-----------------------------| 
 | `*`     | Matches **zero or more** occurrences.             | `a*` matches `""`, `"a"`, `"aa"` | 
 | `+`     | Matches **one or more** occurrences.              | `a+` matches `"a"`, `"aa"`  | 
 | `?`     | Matches **zero or one** occurrence.               | `a?` matches `""`, `"a"`    | 
 | `{n}`   | Matches **exactly n** occurrences.                | `a{3}` matches `"aaa"`      | 
 | `{n,}`  | Matches **n or more** occurrences.                | `a{2,}` matches `"aa"`, `"aaa"` | 
 | `{n,m}` | Matches **between n and m** occurrences.          | `a{2,4}` matches `"aa"`, `"aaa"`, `"aaaa"` | 

---

## ⚡ Special Characters 
 | Syntax | Description                                      | Example                     | 
 |--------|--------------------------------------------------|-----------------------------| 
 | `.`    | Matches **any character** (except newline).      | `a.c` matches `"abc"`, `"a1c"` | 
 | `\d`   | Matches a **digit**.                             | `\d` matches `1`, `2`       | 
 | `\w`   | Matches a **word character**.                    | `\w` matches `a`, `_`, `1`  | 
 | `\s`   | Matches **whitespace**.                          | `\s` matches `" "`, `\t`    | 
 | `\D`   | Matches a **non-digit** character.               | `\D` matches `a`, `@`       | 
 | `\W`   | Matches a **non-word** character.                | `\W` matches `@`, `#`       | 
 | `\S`   | Matches a **non-whitespace** character.          | `\S` matches `a`, `1`       | 

---

## 🤝 Grouping and Capturing 

Parentheses `()` are used to **group** parts of a regex and **capture** matched text for extraction or backreferencing.
 | Syntax       | Description                                      | Example                     | 
 |--------------|--------------------------------------------------|-----------------------------| 
 | `(pattern)`  | Groups the pattern.                              | `(abc)`                     | 
 | `\1`, `\2`   | Refer to captured groups (**backreferences**).   | `(a).\1` matches `"aba"`    | 

**Example:**
To extract the **area code** and **phone number** from a string like `"(123) 456-7890"`:

```regex
$(\d{3})$ (\d{3}-\d{4})
Python Example:
import re

text = "(123) 456-7890"
pattern = r"$(\d{3})$ (\d{3}-\d{4})"
match = re.search(pattern, text)

if match:
    area_code = match.group(1)  # "123"
    phone_number = match.group(2)  # "456-7890"
    print(f"📞 Area Code: {area_code}, Phone: {phone_number}")
```

## 💡 Common Use Cases 
| Type | Syntax |
|------|--------|
|✉️ Email Validation | ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ | 
| 🌐 Extracting URLs | https?://[^\s]+ | 
| 📅 Finding Dates | \d{2}-\d{2}-\d{4} | 
| 🔒 Password Strength Check | ^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@\$!%*?&])[A-Za-z\d@$!%*?&]{8,}$ | 
---
* Validates email addresses (e.g., "user@example.com").
* Matches HTTP/HTTPS URLs in text.
* Matches dates in DD-MM-YYYY format.
* Ensures passwords have at least one uppercase letter, one lowercase letter, one digit, one special character, and are at least 8 characters long.


## 🐍 **Regex in Python** 
Python’s **re** module provides full support for regular expressions:
```python
import re

## 🔍 Search for a pattern
```python
text = "The quick brown fox jumps over the lazy dog."
match = re.search(r"brown \w+", text)
print(match.group())  # "brown fox"
```
## 📋 Find all occurrences
```python
matches = re.findall(r"\b\w{3}\b", text)
print(matches)  # ['The', 'fox', 'the', 'dog']
```
### 🔄 Replace Text
```python
new_text = re.sub(r"fox", "cat", text)
print(new_text)  # "The quick brown cat jumps over the lazy dog."
```

---

## ⚡ Performance Considerations

- ⚠️ Avoid greedy quantifiers (e.g., `.*`) when possible. Use non-greedy quantifiers (e.g., `.*?`) for efficiency.
- 🚀 Pre-compile regex patterns for repeated use:
  ```python
  pattern = re.compile(r"\d{3}-\d{4}")
  ```
- Use specific patterns instead of generic ones (e.g., `\d` instead of `.`).

---

## 📂 Practical Examples {#Practical Examples} 

### 1. 🏷️ Extracting Hashtags
```python
text = "Love #regex! It's #awesome for #text processing."
hashtags = re.findall(r"#\w+", text)
print(hashtags)  # ['#regex', '#awesome', '#text']
```

### 2. 📜 Parsing Log Files
```python
log_entry = '127.0.0.1 - james [01/Jan/2025:12:34:56 +0000] "GET /index.html" 200 1234'
pattern = r'(\S+) - (\S+)$
(.*?) 
$ "(\S+ \S+)" (\d+) (\d+)'
match = re.search(pattern, log_entry)
if match:
    ip, user, date, request, status, size = match.groups()
    print(f"🖥️ IP: {ip}, 👤 User: {user}, 📄 Request: {request}")
```

### 3. 📞 Validating Phone Numbers
```python
phone_pattern = r'^(\+\d{1,3}[- ]?)?\d{10}$'
print(re.match(phone_pattern, "+1-1234567890"))  # ✅ Valid
print(re.match(phone_pattern, "12345"))  # ❌ Invalid
```

---

## 🛠️ Debugging and Testing 
- Use online tools like [Regex101](https://regex101.com/) to test and debug regex patterns.
- Break complex patterns into smaller, manageable parts.

---

## 📊 Regex Cheat Sheet
![Regex Cheat Sheet](https://i.imgur.com/OQStwMn.png)
Credit: *https://i.imgur.com/OQStwMn.png*

---


## 🎯 Conclusion 

Regular expressions are a versatile and powerful tool for text processing. By mastering the syntax and applying best practices, you can efficiently solve a wide range of string manipulation tasks. Start with simple patterns, gradually build complexity, and always test your regex against real-world data.

**Next Steps:**
- Practice with real-world datasets.
- Explore regex in other programming languages (e.g., JavaScript, Perl).
- Learn advanced techniques like recursive patterns and conditional matching.
- Learn advanced techniques like recursive patterns and conditional matching.
