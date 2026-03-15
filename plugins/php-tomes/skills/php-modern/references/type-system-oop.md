# Type System, OOP & SPL Reference

## Table of Contents

- [Scalar Types](#scalar-types)
- [Compound Types](#compound-types)
- [Special Types](#special-types)
- [Union Types](#union-types)
- [Intersection Types](#intersection-types)
- [DNF Types](#dnf-types)
- [Type Covariance/Contravariance](#type-covariancecontravariance)
- [Type Juggling Gotchas](#type-juggling-gotchas)
- [Enums](#enums)
- [Readonly](#readonly)
- [OOP Patterns](#oop-patterns)
- [Generators](#generators)
- [SPL Data Structures](#spl-data-structures)

## Scalar Types

| Type     | Values                                          |
|----------|-------------------------------------------------|
| `int`    | Integers; 64-bit range                          |
| `float`  | IEEE 754 doubles; includes `INF`, `-INF`, `NAN` |
| `string` | Byte string; no encoding enforcement            |
| `bool`   | `true` or `false`                               |

**Best practice:** Use `declare(strict_types=1)` in all new files. `strict_types` only affects userland calls in the
declaring file; built-in functions always use coercive mode.

## Compound Types

- **`array`**: Both list and associative forms
- **`callable`**: String, array, Closure. NOT valid as property type — use `\Closure` instead
- **`object`**: Any object
- **`iterable`**: `array|Traversable`

## Special Types

| Type     | Meaning                                 |
|----------|-----------------------------------------|
| `null`   | `?Type` is shorthand for `Type\|null`   |
| `void`   | Must not return a value                 |
| `never`  | Never returns (always throws/exits)     |
| `mixed`  | Top type — any value. Avoid in new code |
| `true`   | Literal true (PHP 8.2+)                 |
| `false`  | Literal false (PHP 8.2+)                |
| `self`   | Declaring class (not runtime)           |
| `static` | Runtime class (late static binding)     |
| `parent` | Parent class                            |

## Union Types

PHP 8.0+. `int|string`, `int|null` (equivalent to `?int`).

## Intersection Types

PHP 8.1+. `Countable&Serializable` — value must satisfy ALL types. Objects/interfaces only.

## DNF Types

PHP 8.2+. Disjunctive Normal Form: `(A&B)|C`. Each intersection group must be parenthesized.

```php
function output((Stringable&JsonSerializable)|null $data): string { /* ... */ }
```

## Type Covariance/Contravariance

PHP enforces LSP: return types can narrow (covariant), parameter types can widen (contravariant).

```php
interface Factory { public function create(): Animal; }
class DogFactory implements Factory {
    public function create(): Dog { return new Dog(); } // OK — narrowed return
}
```

## Type Juggling Gotchas

```php
var_dump(0 == null);     // true — null coerces to 0
var_dump('' == null);    // true
var_dump('1' == '01');   // true — numeric string comparison
var_dump(100 == '1e2');  // true — scientific notation
```

Always use `===`. Use `is_nan()` to check NAN (NAN !== NAN). Integer overflow silently becomes float.

## Enums

### Pure Enums

```php
enum Direction { case North; case South; case East; case West; }
```

### Backed Enums

```php
enum Status: string
{
    case Active   = 'active';
    case Inactive = 'inactive';
}
$s = Status::from('active');     // Status::Active (throws ValueError)
$s = Status::tryFrom('unknown'); // null
echo $s->value;                  // 'active'
echo $s->name;                   // 'Active'
$all = Status::cases();          // array of all cases
```

### Enum Features

- Methods, static methods, constants (typed in 8.3+)
- Implement interfaces (cannot extend classes)
- Match exhaustiveness enforced by PHPStan/Psalm
- Dynamic fetch: `Suit::{'Hearts'}->value`

## Readonly

### Readonly Properties (8.1+)

```php
class Point
{
    public function __construct(
        public readonly float $x,
        public readonly float $y,
    ) {}
}
// $p->x = 5.0; // Fatal error
```

### Readonly Classes (8.2+)

All declared properties implicitly readonly. Cannot extend non-readonly class. Cannot have untyped properties. Static
properties not affected.

```php
readonly class Money
{
    public function __construct(public int $amount, public string $currency) {}
    public function withAmount(int $amount): static { return new static($amount, $this->currency); }
}
```

## OOP Patterns

### Constructor Promotion (8.0+)

```php
class Product
{
    public function __construct(
        public string $name,
        public float  $price,
        private int   $stock,
    ) {}
}
```

### Traits

Horizontal code reuse. Conflict resolution with `insteadof`/`as`. Can declare abstract methods.

```php
trait Sluggable
{
    abstract protected function getSlugSource(): string;
    public function getSlug(): string { return strtolower(str_replace(' ', '-', $this->getSlugSource())); }
}
```

> Prefer composition over traits for complex behaviors.

### Anonymous Classes

One-off implementations for test doubles, callbacks:

```php
$mock = new class implements CacheInterface {
    private array $data = [];
    public function get(string $key, mixed $default = null): mixed { return $this->data[$key] ?? $default; }
    public function set(string $key, mixed $value, null|int|\DateInterval $ttl = null): bool { $this->data[$key] = $value; return true; }
};
```

### First-Class Callables (8.1+)

```php
$strlen = strlen(...);
$upper  = $helper->uppercase(...);
$trimFn = StringHelper::trim(...);
$trimmed = array_map(StringHelper::trim(...), $words);
```

### Magic Methods

| Method            | Triggered When                |
|-------------------|-------------------------------|
| `__get/$name`     | Reading inaccessible property |
| `__set/$name,$v`  | Writing inaccessible property |
| `__call/$name,$a` | Calling inaccessible method   |
| `__toString()`    | String context                |
| `__invoke()`      | `$obj()`                      |
| `__clone()`       | After `clone $obj`            |
| `__serialize()`   | `serialize($obj)`             |

## Generators

Lazy iteration without materializing full sequence. Implement `Generator` (extends `Iterator`).

```php
function fibonacci(): Generator
{
    [$a, $b] = [0, 1];
    while (true) {
        yield $a;
        [$a, $b] = [$b, $a + $b];
    }
}
```

### yield from (Delegation)

```php
function outerGen(): Generator
{
    yield 0;
    $result = yield from innerGen(); // Delegates; gets return value
    yield 3;
}
```

### Sending Values

```php
function accumulator(): Generator
{
    $total = 0;
    while (true) {
        $value = yield $total;
        if ($value === null) break;
        $total += $value;
    }
}
```

Memory: generator processing 1M integers uses ~1KB vs ~32MB for array.

## SPL Data Structures

| Need                     | Structure                          |
|--------------------------|------------------------------------|
| Stack (LIFO)             | `SplStack`                         |
| Queue (FIFO)             | `SplQueue`                         |
| Priority processing      | `SplPriorityQueue`                 |
| Fixed-size numeric array | `SplFixedArray` (~30% less memory) |
| Lazy sequence            | `Generator`                        |
| Filterable iteration     | `FilterIterator`                   |
| Tree/directory traversal | `RecursiveIteratorIterator`        |

> `SplPriorityQueue` is destructive — iteration removes elements. Clone before iterating to preserve.
