# PHP 8.4 Features Reference

## Table of Contents

- [Property Hooks](#property-hooks)
- [Asymmetric Visibility](#asymmetric-visibility)
- [Deprecated Attribute](#deprecated-attribute)
- [Array Functions](#array-functions)
- [Other Additions](#other-additions)

## Property Hooks

RFC: [Property Hooks](https://wiki.php.net/rfc/property-hooks). Embed `get`/`set` logic on property declarations.

### Basic Syntax

```php
class User
{
    public string $name {
        get => ucfirst($this->name);
        set(string $value) {
            if (strlen($value) < 2) {
                throw new \ValueError('Name must be at least 2 characters.');
            }
            $this->name = $value;
        }
    }
}
```

### Get-Only Hook (Virtual/Computed Property)

No backing store. Read-only by nature.

```php
class Circle
{
    public function __construct(public float $radius) {}
    public float $area {
        get => M_PI * $this->radius ** 2;
    }
}
// $c->area = 10.0; // Fatal error: Cannot write to a get-only property
```

### Set-Only Hook (Write Validation)

```php
class Temperature
{
    public float $celsius {
        set(float $value) {
            if ($value < -273.15) {
                throw new \RangeException('Below absolute zero.');
            }
            $this->celsius = $value;
        }
    }
}
```

### Hooks in Interfaces and Abstract Classes

```php
interface HasFullName
{
    public string $fullName { get; }
}

abstract class Entity
{
    abstract public string $label { get; }
}
```

### Property Hooks + Readonly

Readonly properties can have `get` hook but NOT `set` hook.

```php
class Order
{
    public readonly string $reference {
        get => strtoupper($this->reference);
    }
    public function __construct(string $ref) { $this->reference = $ref; }
}
```

### Performance

~5-15ns overhead per access vs plain properties. Cache computed values in hot paths:

```php
class HeavyComputation
{
    private ?float $cachedResult = null;
    public float $expensiveValue {
        get {
            return $this->cachedResult ??= $this->compute();
        }
    }
}
```

### Migration: Getter/Setter to Property Hook

```php
// Before: private $name + getName()/setName()
// After:
class Product
{
    public string $name {
        get => ucfirst($this->name);
        set(string $value) {
            if ($value === '') throw new \ValueError('Name cannot be empty.');
            $this->name = $value;
        }
    }
}
```

## Asymmetric Visibility

RFC: [Asymmetric Visibility v2](https://wiki.php.net/rfc/asymmetric-visibility-v2).

```php
class EventStore
{
    public private(set) int $eventCount = 0;
    public function append(object $event): void { $this->eventCount++; }
}
// $store->eventCount;      // OK
// $store->eventCount = 99; // Fatal error
```

| Declaration              | Read      | Write     |
|--------------------------|-----------|-----------|
| `public private(set)`    | public    | private   |
| `public protected(set)`  | public    | protected |
| `protected private(set)` | protected | private   |

**vs readonly:** readonly = write-once. `private(set)` = internally writable many times.

## Deprecated Attribute

RFC: [Deprecated Attribute](https://wiki.php.net/rfc/deprecated_attribute). Triggers `E_USER_DEPRECATED`.

```php
#[\Deprecated(message: 'Use formatIso8601() instead.', since: '2.4')]
public function formatDate(\DateTime $dt): string { return $dt->format('Y-m-d'); }
```

Applies to: functions, methods, class constants, enum cases. NOT classes or properties.

## Array Functions

RFC: [Array Find](https://wiki.php.net/rfc/array_find).

```php
$first = array_find($users, fn($u) => $u['active']);       // First match or null
$key   = array_find_key($users, fn($u) => $u['name'] === 'Carol'); // Key or null
$any   = array_any($users, fn($u) => $u['active']);         // bool
$all   = array_all($users, fn($u) => $u['active']);         // bool
```

Migration: `current(array_filter($arr, $fn)) ?: null` becomes `array_find($arr, $fn)`.

## Other Additions

### new in Initializers Everywhere

```php
class Service
{
    public function __construct(private Logger $logger = new NullLogger()) {}
}
```

### \Dom\HTMLDocument (HTML5-compliant DOM)

```php
$doc = \Dom\HTMLDocument::createFromString('<p>Hello <b>World</b></p>');
$p = $doc->querySelector('p');
echo $p->textContent; // "Hello World"
```

### exit()/die() as True Functions

```php
register_shutdown_function(exit(...));
```

### JIT Improvements

5-15% improvement on framework benchmarks vs 8.3 JIT. Up to 40% on numerical workloads. Tracing JIT (
`opcache.jit=tracing`) profiles and compiles hot paths. Function JIT (`opcache.jit=function`) compiles whole functions.
