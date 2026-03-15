# PHP 8.4 + Laravel Integration Reference

## Table of Contents

- [Property Hooks as Eloquent Accessors](#property-hooks-as-eloquent-accessors)
- [Caching Computed Properties](#caching-computed-properties)
- [Asymmetric Visibility in DTOs](#asymmetric-visibility-in-dtos)
- [Value Objects with Asymmetric Visibility](#value-objects-with-asymmetric-visibility)
- [#[\Deprecated] Attribute](#deprecated-attribute)
- [New Array Functions](#new-array-functions)
- [Migration Guide](#migration-guide)
- [Version Compatibility](#version-compatibility)

---

## Property Hooks as Eloquent Accessors

### Before: `Attribute::make()` (Laravel 9+, still supported in 11)

```php
use Illuminate\Database\Eloquent\Casts\Attribute;

class User extends Model
{
    protected function fullName(): Attribute
    {
        return Attribute::make(
            get: fn () => "{$this->first_name} {$this->last_name}",
        );
    }

    protected function email(): Attribute
    {
        return Attribute::make(
            get: fn (string $value) => strtolower($value),
            set: fn (string $value) => strtolower($value),
        );
    }
}
```

### After (PHP 8.4 Property Hooks)

```php
class User extends Model
{
    // Virtual (computed) — no backing DB column
    public string $fullName {
        get => "{$this->first_name} {$this->last_name}";
    }

    // Read/write hook matching a DB column
    public string $email {
        get => strtolower($this->getRawOriginal('email') ?? '');
        set(string $value) {
            $this->attributes['email'] = strtolower($value);
        }
    }
}
```

> **Warning:** Inside `get` hooks, use `$this->getRawOriginal('column')` or `$this->attributes['column']` to access raw
> values. Accessing `$this->email` inside the `email` get hook causes infinite recursion.

---

## Caching Computed Properties

For expensive computations, use a private backing field:

```php
class Order extends Model
{
    private ?float $cachedTotal = null;

    public float $total {
        get {
            if ($this->cachedTotal === null) {
                $this->cachedTotal = $this->items->sum(
                    fn ($item) => $item->price * $item->quantity
                );
            }
            return $this->cachedTotal;
        }
    }
}
```

---

## Asymmetric Visibility in DTOs

```php
final class CreateUserData
{
    public function __construct(
        public private(set) string $name,
        public private(set) string $email,
        public private(set) string $password,
        public private(set) ?string $role = null,
    ) {}

    public static function fromRequest(array $validated): self
    {
        return new self(
            name:     $validated['name'],
            email:    $validated['email'],
            password: $validated['password'],
            role:     $validated['role'] ?? null,
        );
    }
}
```

Usage:

```php
$data = CreateUserData::fromRequest($request->validated());

// Readable anywhere
echo $data->name;

// Cannot write outside the class
$data->name = 'other'; // Fatal error: private(set)
```

---

## Value Objects with Asymmetric Visibility

```php
final class Money
{
    public private(set) int $amount;
    public private(set) string $currency;

    public function __construct(int $amount, string $currency = 'USD')
    {
        if ($amount < 0) {
            throw new \ValueError('Amount cannot be negative.');
        }
        $this->amount = $amount;
        $this->currency = strtoupper($currency);
    }

    public function add(self $other): self
    {
        if ($this->currency !== $other->currency) {
            throw new \LogicException('Cannot add different currencies.');
        }
        return new self($this->amount + $other->amount, $this->currency);
    }

    public function format(): string
    {
        return number_format($this->amount / 100, 2) . ' ' . $this->currency;
    }
}
```

---

## #[\Deprecated] Attribute

### Methods

```php
class InvoiceFormatter
{
    #[\Deprecated(message: 'Use formatWithLocale() instead.', since: '3.2')]
    public function format(\DateTimeInterface $date): string
    {
        return $date->format('Y-m-d');
    }

    public function formatWithLocale(\DateTimeInterface $date, string $locale = 'en_US'): string
    {
        $fmt = new \IntlDateFormatter($locale, \IntlDateFormatter::SHORT, \IntlDateFormatter::NONE);
        return $fmt->format($date);
    }
}
```

Runtime output when called:

```
Deprecated: InvoiceFormatter::format() is deprecated since 3.2, use formatWithLocale() instead.
```

### Enum Cases

```php
enum UserRole: string
{
    case Admin = 'admin';
    case Editor = 'editor';

    #[\Deprecated(message: 'Use Editor instead.', since: '2.0')]
    case Author = 'author';
}
```

### Catching in Tests

```xml
<!-- phpunit.xml (PHPUnit 10+/11+) -->
<phpunit failOnDeprecation="true">
```

**Applies to:** functions, methods, class constants, enum cases.
**Does not apply to:** class declarations, properties (use `@deprecated` PHPDoc for those).

---

## New Array Functions

### `array_find()` — Replace `current(array_filter(...))`

```php
// Before (PHP < 8.4)
$active = current(array_filter($users, fn($u) => $u->active)) ?: null;

// After (PHP 8.4+)
$active = array_find($users, fn($u) => $u->active);
```

For Eloquent collections, `->first(fn($u) => $u->active)` remains idiomatic.

### `new` in Initializers (PHP 8.1+)

```php
class ApiClient
{
    public function __construct(
        private readonly \DateTimeImmutable $createdAt = new \DateTimeImmutable(),
        private Logger $logger = new NullLogger(),
    ) {}
}
```

> **Note:** `new` in initializers is a PHP 8.1 feature, not 8.4. It is included here because it pairs well with 8.4
> patterns in Laravel.

---

## Migration Guide

| Old Pattern                            | PHP 8.4 Replacement              | Notes               |
|----------------------------------------|----------------------------------|---------------------|
| `protected function prop(): Attribute` | `public T $prop { get => ... }`  | PHP 8.4+ only       |
| Private field + public getter          | `public private(set) T $prop`    | Reduces boilerplate |
| `@deprecated` PHPDoc                   | `#[\Deprecated(message, since)]` | Runtime warning     |
| `current(array_filter(...)) ?: null`   | `array_find(...)`                | Cleaner intent      |

---

## Version Compatibility

| Requirement                            | Minimum PHP      |
|----------------------------------------|------------------|
| Property hooks                         | 8.4              |
| Asymmetric visibility (`private(set)`) | 8.4              |
| `#[\Deprecated]` attribute             | 8.4              |
| `array_find()` / `array_find_key()`    | 8.4              |
| `new` in initializers                  | 8.1              |
| `Attribute::make()` accessors          | 8.1 (Laravel 9+) |

Laravel 11.x requires PHP 8.2+. Pin `"php": "^8.4"` in `composer.json` before using 8.4-only features.

For packages targeting PHP 8.2+, use `Attribute::make()` and traditional getters for broad compatibility. Feature-detect
only if necessary:

```php
if (PHP_VERSION_ID >= 80400) {
    // Use property hooks
}
```
