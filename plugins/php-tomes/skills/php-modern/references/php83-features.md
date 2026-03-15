# PHP 8.3 Features Reference

## Table of Contents

- [Typed Class Constants](#typed-class-constants)
- [json_validate](#json_validate)
- [Override Attribute](#override-attribute)
- [Readonly Amendments](#readonly-amendments)
- [Dynamic Class Constant Fetch](#dynamic-class-constant-fetch)
- [Randomizer Additions](#randomizer-additions)

## Typed Class Constants

RFC: [Typed Class Constants](https://wiki.php.net/rfc/typed_class_constants). Type declarations enforced at compile time
and across inheritance.

```php
interface HasVersion
{
    const string VERSION = '1.0.0';
}

class Api implements HasVersion
{
    const string VERSION = '2.0.0'; // OK
    // const int VERSION = 2;       // Fatal error — type mismatch
}
```

### Inheritance Rules

Child can narrow but not widen:

```php
class Base { const int|float LIMIT = 100; }
class Child extends Base { const int LIMIT = 50; } // OK — int narrows int|float
```

### Supported Types

All types except `void`, `never`, `callable`, and intersection types.

```php
class Config
{
    const string  APP_NAME   = 'MyApp';
    const int     MAX_RETRY  = 3;
    const float   TIMEOUT    = 30.5;
    const bool    DEBUG      = false;
    const array   DRIVERS    = ['mysql', 'pgsql'];
    const ?string OPTIONAL   = null;
}
```

## json_validate()

RFC: [json_validate](https://wiki.php.net/rfc/json_validate). Validates JSON without parsing — 2-5x faster than
`json_decode()` for large strings.

```php
json_validate('{"name": "Alice"}');   // true
json_validate('{"bad": json}');       // false
json_validate('null');                // true (null is valid JSON)
json_validate('');                    // false
```

### Depth Parameter

```php
$deep = str_repeat('{"a":', 600) . '"v"' . str_repeat('}', 600);
json_validate($deep);          // false (exceeds default depth 512)
json_validate($deep, 1024);   // true
```

### Migration

```php
// Before
$data = json_decode($input, true);
if (json_last_error() !== JSON_ERROR_NONE) { throw new \InvalidArgumentException('Invalid JSON'); }

// After (validation only)
if (!json_validate($input)) { throw new \InvalidArgumentException('Invalid JSON'); }
$data = json_decode($input, true);
```

## Override Attribute

RFC: [Marking Overridden Methods](https://wiki.php.net/rfc/marking_overriden_methods). Compile-time check that a method
override is intentional.

```php
class UserRepository extends BaseRepository
{
    #[Override]
    public function findAll(): array { return User::all(); }
}
```

If `BaseRepository::findAll()` is renamed, PHP throws a compile-time error. Apply to ALL intentional overrides.

### Catching Refactoring Bugs

```php
class TaggedCache extends Cache
{
    #[Override]
    public function remove(string $key): void // Fatal error: remove() does not override
    { parent::delete($key); }
}
```

## Readonly Amendments

PHP 8.3 allows `clone` on readonly classes. Supports value-object wither patterns.

```php
readonly class Money
{
    public function __construct(public int $amount, public string $currency) {}

    public function withAmount(int $amount): static
    {
        $clone = clone $this;
        return $clone;
    }
}
```

> Full mutable clone support via `__clone` hook arrived in PHP 8.4.

## Dynamic Class Constant Fetch

```php
class Color
{
    const string RED   = '#FF0000';
    const string GREEN = '#00FF00';
}
$name = 'RED';
echo Color::{$name}; // '#FF0000'

// Works with enum cases
enum Suit: string { case Hearts = 'H'; case Diamonds = 'D'; }
$case = 'Hearts';
echo Suit::{$case}->value; // 'H'
```

Undefined constant throws `Error` (not warning).

## Randomizer Additions

```php
$rng = new \Random\Randomizer();

$float = $rng->getFloat(0.0, 1.0);     // Random float in [min, max)
$next  = $rng->nextFloat();             // Random float in [0.0, 1.0)
$keys  = $rng->pickArrayKeys($items, 3); // Pick N unique keys

// Cryptographically secure
$secure = new \Random\Randomizer(new \Random\Engine\Secure());
$token  = $secure->getBytes(32);

// Reproducible (for testing)
$seeded = new \Random\Randomizer(new \Random\Engine\Mt19937(42));
```

## Quick Reference

| Feature                      | What It Solves                                   |
|------------------------------|--------------------------------------------------|
| Typed class constants        | Enforces constant types across inheritance       |
| `json_validate()`            | Fast JSON validation without allocation overhead |
| `#[Override]`                | Compile-time check that override is intentional  |
| Dynamic class constant fetch | `ClassName::{$expr}` syntax                      |
| Randomizer additions         | `getFloat()`, `nextFloat()`, `pickArrayKeys()`   |
| Readonly clone (partial)     | Enables wither patterns on value objects         |
