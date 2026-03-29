# Cryptography Reference

## Table of Contents

- [Password Hashing](#password-hashing)
- [Symmetric Encryption (Secret-Key)](#symmetric-encryption-secret-key)
- [AEAD Encryption](#aead-encryption)
- [Public-Key Encryption](#public-key-encryption)
- [Key Derivation](#key-derivation)
- [Envelope Encryption](#envelope-encryption)
- [Timing-Safe Comparison](#timing-safe-comparison)
- [Random Number Generation](#random-number-generation)
- [Key Management](#key-management)
- [Anti-Patterns](#anti-patterns)

---

## Password Hashing

### Argon2id (Preferred, PHP 7.3+)

```php
$hash = password_hash($password, PASSWORD_ARGON2ID, [
    'memory_cost' => 65536,  // 64 MB
    'time_cost'   => 4,      // 4 iterations
    'threads'     => 2,
]);
```

### BCrypt (Acceptable)

```php
$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
```

> **Gotcha:** BCrypt truncates at 72 bytes. For longer passwords, pre-hash: `hash('sha256', $password, true)`.

### Verification

```php
if (!password_verify($password, $storedHash)) {
    throw new \RuntimeException('Invalid credentials');
}
```

### Rehashing on Login

```php
if (password_needs_rehash($storedHash, PASSWORD_ARGON2ID, [
    'memory_cost' => 65536, 'time_cost' => 4, 'threads' => 2,
])) {
    $newHash = password_hash($password, PASSWORD_ARGON2ID);
    updateUserHash($userId, $newHash);
}
```

### Tuning Parameters

| Algorithm | Parameter   | Recommended   | Notes                       |
| --------- | ----------- | ------------- | --------------------------- |
| Argon2id  | memory_cost | 65536 (64 MB) | Tune to server RAM          |
| Argon2id  | time_cost   | 4             | Tune to acceptable latency  |
| Argon2id  | threads     | 2             | Match available cores       |
| BCrypt    | cost        | 12            | Each increment doubles time |

---

## Symmetric Encryption (Secret-Key)

Uses XSalsa20-Poly1305 via `sodium_crypto_secretbox`. Provides authenticated encryption (confidentiality + integrity).

### Key Generation

```php
$key = sodium_crypto_secretbox_keygen(); // 32 bytes (256 bits)
```

### Encrypt

```php
function encrypt(string $plaintext, string $key): string
{
    $nonce = random_bytes(SODIUM_CRYPTO_SECRETBOX_NONCEBYTES); // 24 bytes
    $ciphertext = sodium_crypto_secretbox($plaintext, $nonce, $key);
    return base64_encode($nonce . $ciphertext);
}
```

### Decrypt

```php
function decrypt(string $encoded, string $key): string
{
    $decoded = base64_decode($encoded, strict: true);
    if ($decoded === false) {
        throw new \RuntimeException('Invalid encoding');
    }

    $nonce = substr($decoded, 0, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
    $ciphertext = substr($decoded, SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);

    $plaintext = sodium_crypto_secretbox_open($ciphertext, $nonce, $key);
    if ($plaintext === false) {
        throw new \RuntimeException('Decryption failed — invalid key or tampered ciphertext');
    }
    return $plaintext;
}
```

> **Critical:** Generate a new random nonce for each encryption. Nonce reuse with the same key breaks confidentiality.

---

## AEAD Encryption

Authenticated Encryption with Associated Data — authenticates (but doesn't encrypt) additional context data.

### Key Generation

```php
$key = sodium_crypto_aead_xchacha20poly1305_ietf_keygen(); // 32 bytes
```

### Encrypt with Context

```php
function encryptWithContext(string $plaintext, string $context, string $key): string
{
    $nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES); // 24 bytes
    $ciphertext = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $plaintext,
        $context,  // Authenticated but not encrypted (e.g., record ID)
        $nonce,
        $key
    );
    return base64_encode($nonce . $ciphertext);
}
```

### Decrypt with Context

```php
function decryptWithContext(string $encoded, string $context, string $key): string
{
    $decoded = base64_decode($encoded, strict: true);
    $nonce = substr($decoded, 0, SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);
    $ciphertext = substr($decoded, SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);

    $plaintext = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
        $ciphertext, $context, $nonce, $key
    );
    if ($plaintext === false) {
        throw new \RuntimeException('Decryption failed');
    }
    return $plaintext;
}
```

---

## Public-Key Encryption

### Key Pair Generation

```php
$keypair = sodium_crypto_box_keypair();
$publicKey = sodium_crypto_box_publickey($keypair);
$secretKey = sodium_crypto_box_secretkey($keypair);
```

### Encrypt for Recipient

```php
function encryptForRecipient(
    string $plaintext,
    string $recipientPublicKey,
    string $senderSecretKey,
): string {
    $nonce = random_bytes(SODIUM_CRYPTO_BOX_NONCEBYTES);
    $keypair = sodium_crypto_box_keypair_from_secretkey_and_publickey(
        $senderSecretKey, $recipientPublicKey
    );
    $ciphertext = sodium_crypto_box($plaintext, $nonce, $keypair);
    return base64_encode($nonce . $ciphertext);
}
```

---

## Key Derivation

Derive encryption keys from passwords using Argon2.

```php
$salt = random_bytes(SODIUM_CRYPTO_PWHASH_SALTBYTES); // 16 bytes — store with data

$key = sodium_crypto_pwhash(
    SODIUM_CRYPTO_SECRETBOX_KEYBYTES,
    $password,
    $salt,
    SODIUM_CRYPTO_PWHASH_OPSLIMIT_INTERACTIVE,  // 2 ops (login) / MODERATE: 3 / SENSITIVE: 4
    SODIUM_CRYPTO_PWHASH_MEMLIMIT_INTERACTIVE,  // 64 MB (login) / MODERATE: 256 MB / SENSITIVE: 1 GB
    SODIUM_CRYPTO_PWHASH_ALG_ARGON2ID13
);
```

---

## Envelope Encryption

Encrypt data with a per-record DEK (Data Encryption Key), then encrypt the DEK with a KEK (Key Encryption Key). Makes
key rotation cheap — re-encrypt only the DEK.

Pattern: generate DEK with `sodium_crypto_secretbox_keygen()`, encrypt data with DEK, encrypt DEK with KEK using
`sodium_crypto_secretbox()`, store both ciphertexts. On decrypt, reverse the process. Always `sodium_memzero($dek)`
after use.

---

## Timing-Safe Comparison

```php
// ✅ SECURE — constant-time, compares all bytes
hash_equals($expected, $provided);
sodium_memcmp($expected, $provided);

// ❌ VULNERABLE — exits at first mismatch (timing oracle)
$expected === $provided;
$expected == $provided;
```

> **Gotcha:** `hash_equals()` returns false immediately if lengths differ. Ensure tokens are always the same length (
> e.g., `bin2hex(random_bytes(32))` always produces 64 chars).

---

## Random Number Generation

```php
// ✅ SECURE — CSPRNG
$bytes = random_bytes(32);              // Raw binary
$hex = bin2hex(random_bytes(32));       // Hex string (64 chars)
$int = random_int(100000, 999999);      // Integer range (e.g., OTP)

// ❌ VULNERABLE — not cryptographically secure
rand(0, 999999);
mt_rand(0, 999999);
array_rand($array);
shuffle($array);    // Uses mt_rand internally
```

---

## Key Management

### Loading Keys from Environment

```php
$key = sodium_hex2bin(
    getenv('APP_ENCRYPTION_KEY')
        ?: throw new \RuntimeException('Missing encryption key')
);

// ... use key ...

sodium_memzero($key); // Clear from memory
```

### Key Management Rules

| Rule                          | Reason                                                 |
| ----------------------------- | ------------------------------------------------------ |
| Never hardcode keys           | Source code is in version control                      |
| Separate keys per environment | Compromised staging key doesn't affect production      |
| Rotate periodically           | Limits blast radius of key compromise                  |
| Use KMS/Vault for KEK storage | KEK next to encrypted data defeats envelope encryption |
| `sodium_memzero()` after use  | Prevents memory dump exposure                          |

---

## Anti-Patterns

| Anti-Pattern                               | Risk                              | Correct Approach                            |
| ------------------------------------------ | --------------------------------- | ------------------------------------------- |
| `openssl_encrypt()` without auth (AES-CBC) | Padding oracle attacks            | Use sodium or AES-GCM with tag verification |
| ECB mode                                   | Leaks plaintext structure         | Use authenticated modes (XSalsa20-Poly1305) |
| `rand()` / `mt_rand()` for tokens          | Predictable output                | `random_bytes()` / `random_int()`           |
| `base64_encode()` as "encryption"          | Zero security, trivially reversed | Actual encryption with sodium               |
| `md5()` / `sha1()` for passwords           | GPU-crackable in seconds          | `password_hash()` with Argon2id             |
| Storing KEK alongside encrypted data       | Defeats envelope encryption       | Separate system (KMS/HSM)                   |
| Nonce reuse                                | Breaks confidentiality            | Fresh `random_bytes()` nonce per encryption |
