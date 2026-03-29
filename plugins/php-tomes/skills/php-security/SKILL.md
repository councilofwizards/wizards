---
name: php-security
description:
  "Use this skill when validating user input, preventing SQL injection or XSS, implementing CSRF protection, hashing
  passwords (Argon2id/bcrypt), encrypting data with sodium, reviewing PHP code for vulnerabilities, or setting up
  authentication and authorization. Covers OWASP Top 10, prepared statements, Content-Security-Policy, session
  hardening, and JWT/MFA patterns."
---

# PHP Security Best Practices

## Input Validation

Validate at trust boundaries (controller/request layer). Use allowlist validation — define what is acceptable, reject
everything else.

### Validate with `filter_var()`

```php
// ✅ SECURE — allowlist validation with filter_var
$email = filter_var($input['email'] ?? '', FILTER_VALIDATE_EMAIL);
if ($email === false) {
    throw new \InvalidArgumentException('Invalid email');
}

$age = filter_var($input['age'] ?? '', FILTER_VALIDATE_INT, [
    'options' => ['min_range' => 0, 'max_range' => 150],
]);
if ($age === false) {
    throw new \InvalidArgumentException('Invalid age');
}

$url = filter_var($input['url'] ?? '', FILTER_VALIDATE_URL);
if ($url === false || !str_starts_with($url, 'https://example.com/')) {
    throw new \InvalidArgumentException('Invalid URL');
}
```

```php
// ❌ VULNERABLE — blacklist strips known strings but misses variants
$input = str_replace(['<script>', 'javascript:'], '', $_GET['url']);
```

### Use Strict Comparison

```php
// ❌ VULNERABLE — loose comparison enables bypass
if ($_POST['token'] == $expectedToken) { /* hash collision bypass */ }
in_array("0abc", [0, 1, 2]); // true — "0abc" coerces to 0

// ✅ SECURE — strict comparison
if (!hash_equals($expectedToken, $_POST['token'] ?? '')) {
    throw new \RuntimeException('Invalid token');
}
in_array($value, $allowed, strict: true);
```

### Use Enums for Categorical Validation (PHP 8.1+)

```php
enum UserRole: string
{
    case Admin = 'admin';
    case Editor = 'editor';
    case Viewer = 'viewer';
}

// Throws ValueError on invalid input
$role = UserRole::from($input['role']);
// Or returns null
$role = UserRole::tryFrom($input['role']);
```

### File Upload Validation

```php
// ❌ VULNERABLE — client-supplied MIME type is trivially spoofed
if ($_FILES['file']['type'] === 'image/jpeg') { /* ... */ }

// ✅ SECURE — server-side MIME detection + extension allowlist
$finfo = new \finfo(FILEINFO_MIME_TYPE);
$mimeType = $finfo->file($_FILES['file']['tmp_name']);
$allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
$extension = strtolower(pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION));

if (!in_array($mimeType, $allowedMimes, strict: true)) {
    throw new \InvalidArgumentException('Invalid file type');
}
// Always regenerate filename
$safeFilename = bin2hex(random_bytes(16)) . '.' . $extension;
```

### Input Validation Rules

- Validate at trust boundaries, not in domain objects
- Prefer `FILTER_VALIDATE_*` over `FILTER_SANITIZE_*` — validation fails loudly, sanitization silently modifies data
- Store raw validated data; escape at output time (not input time)
- Never strip characters from passwords — validate length and encoding only
- Treat database values, queue payloads, and webhook bodies as external inputs

---

## SQL Injection Prevention

SQL injection occurs when untrusted data is interpolated into SQL. Prevention: always separate query structure from data
using prepared statements.

### PDO Prepared Statements

```php
// ❌ VULNERABLE — string interpolation into SQL
$query = "SELECT * FROM users WHERE username = '$username'";
$result = $pdo->query($query);

// ✅ SECURE — parameterized query
$stmt = $pdo->prepare('SELECT * FROM users WHERE username = :username AND active = :active');
$stmt->execute([':username' => $username, ':active' => 1]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);
```

### Critical PDO Configuration

```php
$pdo = new \PDO($dsn, $user, $password, [
    \PDO::ATTR_ERRMODE            => \PDO::ERRMODE_EXCEPTION,
    \PDO::ATTR_EMULATE_PREPARES   => false, // CRITICAL: real prepared statements
    \PDO::ATTR_DEFAULT_FETCH_MODE => \PDO::FETCH_ASSOC,
]);
```

> **Warning:** With `ATTR_EMULATE_PREPARES => true` (default for MySQL), PDO interpolates parameters client-side, losing
> injection protection when charset mismatches exist.

### Dynamic Identifiers (ORDER BY, column names)

Prepared statements only protect data values, not identifiers. Whitelist identifiers explicitly.

```php
// ❌ VULNERABLE — attacker controls column name
$stmt = $pdo->query("SELECT * FROM posts ORDER BY $_GET[sort]");

// ✅ SECURE — whitelist valid columns
$allowedColumns = ['created_at', 'title', 'views'];
$orderBy = in_array($_GET['sort'] ?? '', $allowedColumns, strict: true)
    ? $_GET['sort']
    : 'created_at';
$stmt = $pdo->query("SELECT * FROM posts ORDER BY {$orderBy}");
```

### IN Clause with Variable Parameters

```php
// ❌ VULNERABLE — implode can contain SQL
$ids = implode(',', $_POST['ids']);
$stmt = $pdo->query("SELECT * FROM items WHERE id IN ($ids)");

// ✅ SECURE — one placeholder per value
$ids = array_map('intval', $_POST['ids'] ?? []);
$placeholders = implode(',', array_fill(0, count($ids), '?'));
$stmt = $pdo->prepare("SELECT * FROM items WHERE id IN ({$placeholders})");
$stmt->execute($ids);
```

### ORM Safety (Eloquent)

```php
// ❌ VULNERABLE — raw interpolation in Eloquent
$users = User::whereRaw("name = '$name'")->get();

// ✅ SECURE — fluent builder (parameterized internally)
$users = User::where('name', $name)->where('active', true)->get();

// ✅ SECURE — whereRaw with bindings
$users = User::whereRaw('name = ? AND age > ?', [$name, $minAge])->get();
```

### Second-Order Injection

Always use parameterized queries even for data from your own database — stored attacker input can be interpolated
unsafely on retrieval.

### SQL Injection Rules

- Never use `addslashes()` or `mysql_real_escape_string()` — bypassed with multi-byte encoding
- Always set `PDO::ATTR_EMULATE_PREPARES => false`
- Always set `PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION`
- Whitelist all dynamic identifiers (table names, column names, sort directions)

---

## XSS Prevention

XSS occurs when untrusted data is rendered in a web page without encoding. Defense: context-aware output encoding at
render time.

### HTML Context

```php
// ❌ VULNERABLE — unescaped output
echo "<p>Hello, $name!</p>";

// ✅ SECURE — htmlspecialchars with correct flags
function e(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
echo '<p>Hello, ' . e($name) . '!</p>';
echo '<input type="text" value="' . e($value) . '">';
```

### JavaScript Context

```php
// ❌ VULNERABLE — breaks out of string context
echo "<script>var name = '$name';</script>";

// ✅ SECURE — json_encode with XSS-safe flags
$json = json_encode($name, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP);
echo "<script>var name = {$json};</script>";
```

### URL Context

```php
// ❌ VULNERABLE — allows javascript: protocol
echo '<a href="' . $url . '">Click</a>';

// ✅ SECURE — validate scheme before output
$parsed = parse_url($url);
$scheme = strtolower($parsed['scheme'] ?? '');
if (!in_array($scheme, ['http', 'https'], strict: true)) {
    $url = '#';
}
echo '<a href="' . e($url) . '">Click</a>';
```

### Encoding by Context

| Context           | Function                                                                          |
| ----------------- | --------------------------------------------------------------------------------- |
| HTML content      | `htmlspecialchars($v, ENT_QUOTES \| ENT_SUBSTITUTE, 'UTF-8')`                     |
| HTML attribute    | Same, within quoted attributes                                                    |
| JavaScript string | `json_encode($v, JSON_HEX_TAG \| JSON_HEX_APOS \| JSON_HEX_QUOT \| JSON_HEX_AMP)` |
| URL parameter     | `urlencode($v)` or `rawurlencode($v)`                                             |
| CSS value         | Avoid injecting into CSS; use data attributes                                     |

### Template Engine Safety

```blade
{{-- Blade {{ }} auto-escapes --}}
<p>{{ $name }}</p>

{{-- {!! !!} is UNESCAPED — only for trusted, sanitized HTML --}}
{!! $trustedHtml !!}
```

### Content-Security-Policy (CSP)

```php
$nonce = base64_encode(random_bytes(16));
header(sprintf(
    "Content-Security-Policy: default-src 'self'; script-src 'nonce-%s' 'strict-dynamic'; " .
    "style-src 'self' 'nonce-%s'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'",
    $nonce, $nonce
));
```

### XSS Prevention Rules

- Escape at output, not input — store raw validated data
- Never use `strip_tags()` as XSS defense — malformed HTML bypasses it
- Never use `{!! !!}` in Blade with user input
- CSP is defense-in-depth, not a substitute for output encoding
- Avoid `unsafe-inline` and `unsafe-eval` in CSP

---

## CSRF Protection

CSRF tricks authenticated users into submitting requests from attacker-controlled pages. The browser sends cookies
automatically, so requests arrive authenticated.

### Synchronizer Token Pattern

```php
// Generate and verify per-session tokens
final class CsrfTokenManager
{
    public function getToken(): string
    {
        if (!isset($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }

    public function verifyToken(string $submitted): bool
    {
        return hash_equals($_SESSION['csrf_token'] ?? '', $submitted);
    }
}
```

> **Warning:** Always use `hash_equals()` to compare CSRF tokens — `===` creates a timing oracle.

### SameSite Cookies

```php
setcookie('session_id', $sessionId, [
    'secure'   => true,     // HTTPS only
    'httponly'  => true,     // No JS access
    'samesite'  => 'Lax',   // Blocks cross-site POST
]);
```

| SameSite | Cross-site GET | Cross-site POST | Same-site |
| -------- | -------------- | --------------- | --------- |
| Strict   | Blocked        | Blocked         | Sent      |
| Lax      | Sent           | Blocked         | Sent      |
| None     | Sent           | Sent            | Sent      |

### Laravel CSRF

```blade
<form method="POST" action="/profile">
    @csrf  {{-- auto-generates hidden _token field --}}
</form>
```

### CSRF Rules

- Never use GET for state-changing operations
- Explicitly set SameSite on all session cookies — do not rely on browser defaults
- Use `hash_equals()` for token comparison
- Rotate tokens on login/logout
- Never put CSRF tokens in URLs (leaked in logs and browser history)

---

## Authentication

### Password Hashing

```php
// ❌ VULNERABLE — MD5/SHA are GPU-crackable in seconds
$hash = md5($password);
$hash = hash('sha256', $password);

// ✅ SECURE — Argon2id (preferred) or BCrypt
$hash = password_hash($password, PASSWORD_ARGON2ID, [
    'memory_cost' => 65536,  // 64 MB
    'time_cost'   => 4,
    'threads'     => 2,
]);

// Verification
if (!password_verify($password, $storedHash)) {
    throw new \RuntimeException('Invalid credentials');
}

// Rehash on login if algorithm/cost changed
if (password_needs_rehash($storedHash, PASSWORD_ARGON2ID)) {
    $newHash = password_hash($password, PASSWORD_ARGON2ID);
    // Update stored hash
}
```

> **Note:** BCrypt truncates at 72 bytes. For longer passwords, use Argon2id or pre-hash:
> `hash('sha256', $password, true)`.

### Session Hardening

```php
ini_set('session.cookie_httponly', '1');
ini_set('session.cookie_secure', '1');
ini_set('session.cookie_samesite', 'Lax');
ini_set('session.use_strict_mode', '1');

session_start();

// Regenerate ID on privilege escalation — prevents session fixation
session_regenerate_id(delete_old_session: true);
```

### API Token Generation

```php
// Generate with CSPRNG
$token = bin2hex(random_bytes(32));

// Store hashed — SHA-256 is fine for tokens (not passwords)
$hash = hash('sha256', $token);
// INSERT INTO api_tokens (token_hash) VALUES (?)
```

### Authorization (RBAC)

```php
enum Permission: string
{
    case EditPost    = 'post:edit';
    case DeletePost  = 'post:delete';
    case ManageUsers = 'user:manage';
}

enum Role: string
{
    case Viewer = 'viewer';
    case Editor = 'editor';
    case Admin  = 'admin';
}
```

Centralize authorization in policy/gate classes — never scatter inline `$_SESSION['role']` checks.

---

## Cryptography

Use `ext-sodium` (ships with PHP 7.2+) for all encryption. Never use `mcrypt`, `openssl_encrypt` without authentication,
or `rand()`/`mt_rand()` for security values.

### Symmetric Encryption (Secret-Key)

```php
$key = sodium_crypto_secretbox_keygen();

// ✅ SECURE — authenticated encryption
function encrypt(string $plaintext, string $key): string
{
    $nonce = random_bytes(SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $ciphertext = sodium_crypto_secretbox($plaintext, $nonce, $key);
    return base64_encode($nonce . $ciphertext);
}

function decrypt(string $encoded, string $key): string
{
    $decoded = base64_decode($encoded, strict: true);
    $nonce = substr($decoded, 0, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $ciphertext = substr($decoded, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $plaintext = sodium_crypto_secretbox_open($ciphertext, $nonce, $key);
    if ($plaintext === false) {
        throw new \RuntimeException('Decryption failed');
    }
    return $plaintext;
}
```

### Timing-Safe Comparison

```php
// ✅ SECURE — constant-time comparison
hash_equals($expectedToken, $providedToken);

// ❌ VULNERABLE — exits at first mismatch byte (timing oracle)
$expectedToken === $providedToken;
```

### Key Management Rules

- Never hardcode keys in source code — use environment variables or a secrets manager
- Separate keys by environment (prod/staging/dev)
- Use `sodium_memzero($key)` to clear keys from memory when done
- Use `random_bytes()` for all security-sensitive random values — never `rand()` or `mt_rand()`
- Use envelope encryption for key rotation: encrypt data with per-record DEK, encrypt DEK with KEK
- Base64 is encoding, not encryption

---

## Security Review Checklist

When reviewing PHP code for security:

1. **Input**: Is all external input validated at trust boundaries using allowlist rules?
2. **SQL**: Are all queries parameterized? Are dynamic identifiers whitelisted?
3. **XSS**: Is output escaped with context-appropriate encoding? Are Blade `{!! !!}` uses justified?
4. **CSRF**: Do state-changing endpoints verify CSRF tokens? Are cookies SameSite?
5. **Auth**: Are passwords hashed with Argon2id/BCrypt? Are sessions regenerated on login?
6. **Crypto**: Is `ext-sodium` used for encryption? Are keys loaded from environment, not hardcoded?
7. **Comparison**: Are all security-sensitive comparisons using `hash_equals()`?
8. **Randomness**: Are all tokens generated with `random_bytes()` / `random_int()`?
