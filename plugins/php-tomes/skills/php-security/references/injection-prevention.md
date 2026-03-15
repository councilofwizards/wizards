# Injection Prevention Reference

## Table of Contents

- [SQL Injection — PDO](#sql-injection--pdo)
- [SQL Injection — MySQLi](#sql-injection--mysqli)
- [SQL Injection — Dynamic Identifiers](#sql-injection--dynamic-identifiers)
- [SQL Injection — ORM (Eloquent)](#sql-injection--orm-eloquent)
- [SQL Injection — Edge Cases](#sql-injection--edge-cases)
- [XSS — Output Encoding](#xss--output-encoding)
- [XSS — Template Engines](#xss--template-engines)
- [XSS — CSP Headers](#xss--csp-headers)
- [CSRF — Token Patterns](#csrf--token-patterns)
- [CSRF — SameSite Cookies](#csrf--samesite-cookies)

---

## SQL Injection — PDO

### Required PDO Configuration

```php
$pdo = new \PDO($dsn, $user, $password, [
    \PDO::ATTR_ERRMODE            => \PDO::ERRMODE_EXCEPTION,
    \PDO::ATTR_EMULATE_PREPARES   => false,  // Real prepared statements
    \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
    \PDO::ATTR_STRINGIFY_FETCHES  => false,
]);
```

> **Critical:** `ATTR_EMULATE_PREPARES => true` (MySQL default) interpolates client-side — vulnerable to
> charset-mismatch attacks.

### Named Placeholders

```php
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email AND active = :active');
$stmt->execute([':email' => $email, ':active' => 1]);
$user = $stmt->fetch();
```

### Positional Placeholders

```php
$stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
$stmt->execute([$id]);
```

### IN Clause

```php
$ids = array_map('intval', $input);
if (empty($ids)) { return []; }

$placeholders = implode(',', array_fill(0, count($ids), '?'));
$stmt = $pdo->prepare("SELECT * FROM items WHERE id IN ({$placeholders})");
$stmt->execute($ids);
```

### INSERT with Prepared Statement

```php
$stmt = $pdo->prepare('INSERT INTO users (name, email) VALUES (:name, :email)');
$stmt->execute([':name' => $name, ':email' => $email]);
$newId = $pdo->lastInsertId();
```

---

## SQL Injection — MySQLi

```php
$stmt = $mysqli->prepare('SELECT id, email FROM users WHERE username = ? AND active = ?');
$stmt->bind_param('si', $username, $active); // s=string, i=integer, d=double, b=blob
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();
$stmt->close();
```

---

## SQL Injection — Dynamic Identifiers

Prepared statements do NOT protect table names, column names, or ORDER BY directions. These must be whitelisted.

```php
// Column whitelist
$allowedColumns = ['created_at', 'title', 'views', 'author'];
$column = in_array($_GET['sort'] ?? '', $allowedColumns, strict: true)
    ? $_GET['sort']
    : 'created_at';

// Direction whitelist
$allowedDirs = ['ASC', 'DESC'];
$dir = in_array(strtoupper($_GET['dir'] ?? ''), $allowedDirs, strict: true)
    ? strtoupper($_GET['dir'])
    : 'DESC';

$stmt = $pdo->query("SELECT * FROM posts ORDER BY {$column} {$dir}");
```

### Table Name Whitelist

```php
$allowedTables = ['users', 'posts', 'comments'];
$table = in_array($tableName, $allowedTables, strict: true)
    ? $tableName
    : throw new \InvalidArgumentException('Invalid table');

$stmt = $pdo->prepare("SELECT * FROM {$table} WHERE id = ?");
$stmt->execute([$id]);
```

---

## SQL Injection — ORM (Eloquent)

### Safe Patterns

```php
// Fluent builder — parameterized internally
User::where('name', $name)->where('active', true)->get();
User::where('email', 'LIKE', '%' . $search . '%')->get();
User::whereIn('id', $ids)->get();
User::findOrFail($id);

// Raw with bindings
User::whereRaw('age > ? AND created_at > ?', [$minAge, $date])->get();
DB::select('SELECT * FROM users WHERE email = ?', [$email]);
DB::statement('UPDATE users SET role = ? WHERE id = ?', [$role, $id]);
```

### Vulnerable Patterns

```php
// ❌ NEVER interpolate into raw methods
User::whereRaw("name = '$name'")->get();
DB::statement("UPDATE users SET role = '$role' WHERE id = $id");
DB::select("SELECT * FROM users WHERE email = '$email'");
```

---

## SQL Injection — Edge Cases

### Second-Order Injection

Data stored safely but retrieved and interpolated unsafely later.

```php
// ❌ VULNERABLE — data from own DB interpolated into query
$username = fetchFromDb($id); // contains "admin'--"
$pdo->query("SELECT * FROM logs WHERE user = '$username'");

// ✅ SECURE — always parameterize, even for DB-sourced data
$stmt = $pdo->prepare('SELECT * FROM logs WHERE user = ?');
$stmt->execute([$username]);
```

### Stored Procedures

```php
// ✅ SECURE — parameterized call
$stmt = $pdo->prepare('CALL get_user_by_email(?)');
$stmt->execute([$email]);
```

> **Gotcha:** If the stored procedure internally concatenates input into dynamic SQL (`EXECUTE`/`EXEC`), injection
> happens inside the database engine.

### Deprecated/Unsafe Functions

| Function                      | Status                  | Alternative             |
|-------------------------------|-------------------------|-------------------------|
| `mysql_real_escape_string()`  | Removed PHP 7.0         | PDO prepared statements |
| `addslashes()`                | Bypassable (multi-byte) | PDO prepared statements |
| `mysqli_real_escape_string()` | Unreliable alone        | `mysqli::prepare()`     |

---

## XSS — Output Encoding

### HTML Content

```php
function e(string $value, string $encoding = 'UTF-8'): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, $encoding);
}

echo '<p>' . e($userInput) . '</p>';
echo '<input type="text" value="' . e($userInput) . '">';
```

> **Gotcha:** `htmlspecialchars()` without `ENT_QUOTES` does not encode `'`. Single-quoted attributes become a bypass
> vector.

### JavaScript Context

```php
$json = json_encode($data, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP);
echo "<script>const config = {$json};</script>";

// Or use a data attribute
echo '<div data-config="' . e(json_encode($config)) . '"></div>';
```

### URL Context

```php
// Validate scheme first
$scheme = strtolower(parse_url($url, PHP_URL_SCHEME) ?? '');
if (!in_array($scheme, ['http', 'https'], strict: true)) {
    $url = '#';
}
echo '<a href="' . e($url) . '">Link</a>';

// URL parameters
echo '<a href="/search?q=' . urlencode($query) . '">Search</a>';
```

---

## XSS — Template Engines

### Blade (Laravel)

```blade
{{-- Auto-escaped (htmlspecialchars) --}}
{{ $variable }}

{{-- Unescaped — ONLY for trusted, sanitized HTML --}}
{!! $trustedHtml !!}
```

### Twig (Symfony)

```twig
{# Auto-escaped by default #}
{{ variable }}

{# Raw — ONLY for trusted content #}
{{ trustedHtml | raw }}
```

---

## XSS — CSP Headers

### Nonce-Based CSP

```php
$nonce = base64_encode(random_bytes(16));
header("Content-Security-Policy: default-src 'self'; script-src 'nonce-{$nonce}' 'strict-dynamic'; object-src 'none'");
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
```

```html
<script nonce="<?= e($nonce) ?>">/* allowed */</script>
```

---

## CSRF — Token Patterns

### Synchronizer Token (Session-Based)

```php
// Generate
$_SESSION['csrf_token'] ??= bin2hex(random_bytes(32));

// Embed in form
echo '<input type="hidden" name="_token" value="' . e($_SESSION['csrf_token']) . '">';

// Verify (timing-safe)
if (!hash_equals($_SESSION['csrf_token'], $_POST['_token'] ?? '')) {
    http_response_code(419);
    throw new \RuntimeException('CSRF token mismatch');
}
```

### Double-Submit Cookie (Stateless APIs)

Set a random value as both a cookie (`httponly: false`, `samesite: Strict`) and require it as an `X-CSRF-Token` header.
Verify with `hash_equals()`.

### Laravel CSRF

```blade
<form method="POST" action="/profile">@csrf</form>
```

Exclude webhook routes: `protected $except = ['/webhooks/stripe'];`

---

## CSRF — SameSite Cookies

| Value  | Cross-site GET | Cross-site POST | Notes                |
|--------|----------------|-----------------|----------------------|
| Strict | Blocked        | Blocked         | Breaks OAuth flows   |
| Lax    | Sent           | Blocked         | Recommended default  |
| None   | Sent           | Sent            | Requires Secure flag |

- JWT in `localStorage` + Bearer header: CSRF does not apply (XSS becomes critical)
- Cookie-based auth with `credentials: 'include'`: CSRF applies — use token header pattern
