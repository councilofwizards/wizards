# Input Validation Reference

## Table of Contents

- [filter_var Validators](#filter_var-validators)
- [Type Coercion Traps](#type-coercion-traps)
- [Enum Validation](#enum-validation)
- [File Upload Validation](#file-upload-validation)
- [Validation Libraries](#validation-libraries)
- [Common Patterns](#common-patterns)

---

## filter_var Validators

### FILTER_VALIDATE_EMAIL

```php
$email = filter_var($input, FILTER_VALIDATE_EMAIL);
// Returns validated string or false
// Follows RFC 5321/5322 — accepts IDN addresses
```

> **Gotcha:** Accepts internationalized addresses (e.g., `user@xn--nxasmq6b.com`). Add an ASCII check if your mailer
> doesn't support IDN.

### FILTER_VALIDATE_INT

```php
$page = filter_var($input, FILTER_VALIDATE_INT, [
    'options' => ['min_range' => 1, 'max_range' => 10_000],
]);
// Returns integer or false
```

### FILTER_VALIDATE_FLOAT

```php
$price = filter_var($input, FILTER_VALIDATE_FLOAT, [
    'options' => ['decimal' => '.'],
]);
```

### FILTER_VALIDATE_URL

```php
$url = filter_var($input, FILTER_VALIDATE_URL, FILTER_FLAG_PATH_REQUIRED);
// Validates structure only — does NOT check reachability or scheme safety
```

> **Gotcha:** Accepts `javascript:` and `data:` URLs. Always validate the scheme separately for href attributes.

### FILTER_VALIDATE_IP

```php
// IPv4 only, no private ranges
$ip = filter_var($input, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4 | FILTER_FLAG_NO_PRIV_RANGE);

// IPv6 only
$ip = filter_var($input, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6);
```

### FILTER_VALIDATE_BOOLEAN

```php
$flag = filter_var($input, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
// Accepts: "true"/"false"/"1"/"0"/"yes"/"no"/"on"/"off"
// Returns true, false, or null (use FILTER_NULL_ON_FAILURE to distinguish false from invalid)
```

### FILTER_VALIDATE_DOMAIN

```php
$domain = filter_var($input, FILTER_VALIDATE_DOMAIN, FILTER_FLAG_HOSTNAME);
```

---

## Type Coercion Traps

### Loose Comparison Bypasses

```php
// ❌ VULNERABLE
"0e123" == "0e456"          // true — scientific notation
0 == "admin"                 // true in PHP 7, false in PHP 8.0+
in_array("0abc", [0, 1, 2]) // true without strict flag
switch ($_GET['v']) { case 0: } // loose comparison

// ✅ SECURE
hash_equals($expected, $provided)       // timing-safe
in_array($value, $allowed, strict: true) // strict comparison
match($value) { 'admin' => ... }         // strict comparison
```

### PHP 8.0 Change

`0 == "foo"` changed from `true` (PHP 7) to `false` (PHP 8.0+). Audit all loose comparisons when migrating from PHP 7.

---

## Enum Validation

PHP 8.1+ backed enums provide compile-time-safe allowlist validation.

```php
enum Status: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case Pending = 'pending';
}

// Throws ValueError on invalid input
$status = Status::from($input);

// Returns null on invalid input
$status = Status::tryFrom($input);
if ($status === null) {
    throw new \InvalidArgumentException('Invalid status');
}
```

---

## File Upload Validation

### Full Validation Pattern

```php
$file = $_FILES['upload'];

// 1. Check for upload errors
if ($file['error'] !== UPLOAD_ERR_OK) {
    throw new \RuntimeException('Upload failed: ' . $file['error']);
}

// 2. Verify it was actually uploaded (prevents path traversal)
if (!is_uploaded_file($file['tmp_name'])) {
    throw new \RuntimeException('Invalid upload');
}

// 3. Server-side MIME detection (not client-supplied type)
$finfo = new \finfo(FILEINFO_MIME_TYPE);
$mimeType = $finfo->file($file['tmp_name']);

$allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
if (!in_array($mimeType, $allowedMimes, strict: true)) {
    throw new \InvalidArgumentException('Invalid MIME type');
}

// 4. Extension allowlist
$allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
$extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (!in_array($extension, $allowedExtensions, strict: true)) {
    throw new \InvalidArgumentException('Invalid extension');
}

// 5. Size limit
$maxSize = 5 * 1024 * 1024; // 5 MB
if ($file['size'] > $maxSize) {
    throw new \InvalidArgumentException('File too large');
}

// 6. Regenerate filename — never use client-supplied name
$safeFilename = bin2hex(random_bytes(16)) . '.' . $extension;
move_uploaded_file($file['tmp_name'], $uploadDir . '/' . $safeFilename);
```

### Image-Specific Validation

```php
// Verify the file is actually an image (not just renamed)
$imageInfo = getimagesize($file['tmp_name']);
if ($imageInfo === false) {
    throw new \InvalidArgumentException('Not a valid image');
}

// Dimension limits
[$width, $height] = $imageInfo;
if ($width > 4096 || $height > 4096) {
    throw new \InvalidArgumentException('Image dimensions too large');
}
```

---

## Validation Libraries

### symfony/validator

```php
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\Validation;

$validator = Validation::createValidator();
$violations = $validator->validate($email, [
    new Assert\NotBlank(),
    new Assert\Email(['mode' => 'html5']),
    new Assert\Length(['max' => 255]),
]);
if (count($violations) > 0) {
    throw new \InvalidArgumentException((string) $violations);
}
```

### Laravel Validator

```php
$validated = $request->validate([
    'email' => ['required', 'email:rfc,dns', 'max:255'],
    'name'  => ['required', 'string', 'max:100'],
    'age'   => ['required', 'integer', 'min:0', 'max:150'],
    'role'  => ['required', Rule::enum(UserRole::class)],
]);
```

### respect/validation

```php
use Respect\Validation\Validator as v;

v::email()->length(null, 255)->assert($email);
v::intVal()->between(0, 150)->assert($age);
```

---

## Common Patterns

### Request DTO with Validation

```php
final class CreateUserRequest
{
    public function __construct(
        public readonly string $email,
        public readonly string $name,
        public readonly int $age,
    ) {}

    public static function fromArray(array $input): self
    {
        $email = filter_var($input['email'] ?? '', FILTER_VALIDATE_EMAIL);
        if ($email === false) {
            throw new \InvalidArgumentException('Invalid email');
        }

        $name = trim($input['name'] ?? '');
        if ($name === '' || mb_strlen($name) > 100) {
            throw new \InvalidArgumentException('Name must be 1-100 characters');
        }

        $age = filter_var($input['age'] ?? '', FILTER_VALIDATE_INT, [
            'options' => ['min_range' => 0, 'max_range' => 150],
        ]);
        if ($age === false) {
            throw new \InvalidArgumentException('Invalid age');
        }

        return new self($email, $name, $age);
    }
}
```

### URL Validation for Redirects

```php
function validateRedirectUrl(string $url, string $allowedHost): string
{
    $parsed = parse_url($url);
    $scheme = strtolower($parsed['scheme'] ?? '');
    $host = strtolower($parsed['host'] ?? '');

    if (!in_array($scheme, ['http', 'https'], strict: true)) {
        throw new \InvalidArgumentException('Invalid URL scheme');
    }
    if ($host !== $allowedHost) {
        throw new \InvalidArgumentException('Invalid redirect host');
    }

    return $url;
}
```

### Anti-Patterns

| Anti-Pattern                  | Why It's Dangerous                                       |
| ----------------------------- | -------------------------------------------------------- |
| `strip_tags()` on input       | Irreversibly changes data; doesn't prevent all XSS       |
| `FILTER_SANITIZE_*`           | Silently modifies data — use `FILTER_VALIDATE_*` instead |
| Validation in models          | Too late — errors become deep exceptions                 |
| Stripping password characters | Weakens passwords — validate length/encoding only        |
| Trusting `$_FILES['type']`    | Client-supplied, trivially spoofed                       |
