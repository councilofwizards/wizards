---
name: php-code-quality
description:
  "Use this skill when writing or reviewing PHP code for style, naming, types,
  or documentation. Covers PSR-12/PER-CS formatting, naming conventions, strict
  typing, union/intersection/DNF types, PHPStan (level 0-9) and Psalm
  configuration, baseline management, PHPDoc (when to write vs skip), generics
  via @template, and PHP-CS-Fixer/Pint setup."
---

# PHP Code Quality

Apply these rules to every PHP file you write, review, or refactor. When
generating new code, follow them by default. When reviewing existing code, flag
violations.

## File Structure

Every PHP file must follow this exact structure:

```php
<?php

declare(strict_types=1);

namespace App\Domain\Order;

use App\Contracts\Repository;
use RuntimeException;

class OrderService implements Repository
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly EventDispatcher $events,
    ) {
    }

    public function create(array $data): Order
    {
        // ...
    }
}
```

Rules:

- `<?php` tag only — never `<?` short tags
- `declare(strict_types=1)` on every file, after a blank line
- One class/interface/trait/enum per file
- `use` imports grouped and sorted alphabetically
- Remove unused imports

## Naming Conventions

| Construct                       | Convention            | Example                           |
| ------------------------------- | --------------------- | --------------------------------- |
| Classes/interfaces/traits/enums | `StudlyCaps`          | `OrderProcessor`, `Cacheable`     |
| Methods/functions               | `camelCase`           | `findByEmail()`, `processOrder()` |
| Variables/properties            | `camelCase`           | `$userId`, `$orderItems`          |
| Constants                       | `UPPER_SNAKE_CASE`    | `MAX_RETRY_COUNT`                 |
| Enum cases                      | `StudlyCaps`          | `OrderStatus::Pending`            |
| Namespaces                      | `StudlyCaps` segments | `App\Domain\Order`                |

```php
// ❌ Bad
class order_processor {}
interface IUserRepository {}
class HTTPSHandler {}  // all-caps acronym
public function create_order(): Order {}
$arr_users = [];  // Hungarian notation

// ✅ Good
class OrderProcessor {}
interface UserRepository {}
class HttpsHandler {}
public function createOrder(): Order {}
$users = [];
```

### Boolean Methods

Start boolean-returning methods with `is`, `has`, `can`, `should`, or `was`:

```php
// ❌ Bad
public function active(): bool {}

// ✅ Good
public function isActive(): bool {}
public function hasPermission(string $perm): bool {}
public function canProcessRefunds(): bool {}
```

### Method Naming

First word is a verb. Do not repeat the class name in the method:

```php
// ❌ Bad — redundant class name in method
class OrderService
{
    public function getOrderById(int $id): Order {}
}

// ✅ Good
class OrderService
{
    public function findById(int $id): Order {}
}
```

## Formatting

### Indentation and Line Length

- 4 spaces per level, never tabs
- Soft limit: 120 characters, hard limit: 160 characters
- Break long calls — each argument on its own line with trailing comma

```php
// ❌ Bad — exceeds line limit
$result = $this->orderRepository->findByUserAndStatus($userId, OrderStatus::Pending, true);

// ✅ Good
$result = $this->orderRepository->findByUserAndStatus(
    userId: $userId,
    status: OrderStatus::Pending,
    includeArchived: true,
);
```

### Braces

- Classes and methods: opening brace on **own line**
- Control structures: opening brace on **same line**
- Always use braces, even for single-line bodies

```php
// ❌ Bad
if ($condition)
    doSomething();

if ($condition)
{
    doSomething();
}

// ✅ Good
if ($condition) {
    doSomething();
}
```

### Trailing Commas

Always use trailing commas in multi-line arrays, arguments, and parameters:

```php
// ✅ Good — trailing comma on last element
$config = [
    'driver' => 'mysql',
    'host' => 'localhost',
    'port' => 3306,
];
```

### Modifier Order

`abstract`/`final` then `public`/`protected`/`private` then `static`:

```php
final public static function create(): static {}
abstract protected function validate(array $data): bool;
```

## Type System

### Strict Typing Rules

1. Every file: `declare(strict_types=1)`
2. Every function/method: typed parameters AND return type
3. Every class property: typed
4. Use `?Type` instead of `mixed` when null is the only alternative
5. Use `never` for functions that always throw or exit
6. Use `void` for methods that return no value
7. Use `readonly class` for value objects (PHP 8.2+)

```php
// ❌ Bad — missing types, using mixed unnecessarily
function findUser($id) {
    // ...
}

public function save($entity): mixed {
    // ...
}

// ✅ Good
function findUser(int $id): ?User {
    // ...
}

public function save(Entity $entity): void {
    // ...
}
```

### Value Objects

```php
// ✅ Good — readonly class for immutable value objects
readonly class Money
{
    public function __construct(
        public int $amount,
        public string $currency,
    ) {
    }
}
```

### Union and Intersection Types

```php
// Union type
function parseId(string|int $id): int
{
    return is_string($id) ? (int) $id : $id;
}

// Intersection type (PHP 8.1+)
function persist(Loggable&Serializable $entity): void {}

// DNF type (PHP 8.2+)
function process((Countable&Iterator)|array $items): void {}
```

### Fluent Methods — Use `static` Return Type

```php
// ✅ Good — preserves subtype in fluent chains
public function where(string $column, mixed $value): static
{
    $this->wheres[] = [$column, $value];
    return $this;
}
```

## Static Analysis

### PHPStan Configuration

Target level 9. Use Larastan for Laravel projects.

```neon
# phpstan.neon
includes:
    - vendor/phpstan/phpstan/conf/bleedingEdge.neon
    - vendor/nunomaduro/larastan/extension.neon  # Laravel only
    - phpstan-baseline.neon

parameters:
    level: 9
    paths:
        - app
        - src
    checkModelProperties: true  # Laravel only
```

### Baseline Management

- Commit `phpstan-baseline.neon` — it is a contract, not a todo list
- Never grow the baseline — CI must fail if new errors are added
- Shrink it over time — schedule baseline reduction as backlog work

```bash
# Generate baseline
vendor/bin/phpstan analyse --generate-baseline phpstan-baseline.neon
```

### Suppression Rules

Always include a reason when suppressing:

```php
// ❌ Bad — no explanation
/** @phpstan-ignore-next-line */
$roles = $this->roles->pluck('name');

// ✅ Good
/** @phpstan-ignore-next-line (Eloquent magic: $this->roles is a Collection) */
$roles = $this->roles->pluck('name');
```

### Gradual Adoption

Start at level 0, increment one level per sprint. At each level:

1. Run analysis at the new level
2. If errors < 50, fix inline
3. If errors > 50, generate a baseline and add backlog tickets
4. Merge the level bump as a single commit

## PHPDoc Discipline

### When to Write PHPDoc

Only write PHPDoc when it adds information beyond native type declarations:

```
Does the method have native type declarations for all params and return?
├── Yes → Does it also need @template, @throws, or array shapes?
│         ├── Yes → Add PHPDoc for those tags only
│         └── No  → Skip PHPDoc entirely
└── No  → Add native types first, then apply the above
```

### PHPDoc That Adds Value

```php
// ✅ Generics — no native PHP syntax for this
/**
 * @template T of Model
 * @param class-string<T> $modelClass
 * @return T
 */
public function find(string $modelClass, int $id): Model {}

// ✅ Array shapes — native `array` loses structure
/**
 * @param array<string, int|float> $metrics
 * @return array{min: float, max: float, avg: float}
 */
public function summarize(array $metrics): array {}

// ✅ Throws — PHP has no checked exceptions
/**
 * @throws DatabaseException if the connection fails
 * @throws ValidationException if constraints are violated
 */
public function save(Entity $entity): void {}

// ✅ Callable shapes
/**
 * @param callable(User, int): bool $callback
 * @return list<User>
 */
public function filterUsers(callable $callback): array {}
```

### PHPDoc to Avoid

```php
// ❌ Bad — duplicates native types
/**
 * @param string $name
 * @param int $age
 * @return User
 */
public function create(string $name, int $age): User {}

// ✅ Good — native types are sufficient
public function create(string $name, int $age): User {}
```

### Generic Classes

```php
/**
 * @template TValue
 * @implements IteratorAggregate<int, TValue>
 */
class TypedCollection implements IteratorAggregate
{
    /** @var list<TValue> */
    private array $items = [];

    /** @param TValue $item */
    public function add(mixed $item): void
    {
        $this->items[] = $item;
    }

    /** @return TValue|null */
    public function first(): mixed
    {
        return $this->items[0] ?? null;
    }
}

/** @extends TypedCollection<User> */
class UserCollection extends TypedCollection {}
```

## Tool Configuration

### PHP-CS-Fixer (PER-CS 2.0)

```php
// .php-cs-fixer.dist.php
$finder = PhpCsFixer\Finder::create()
    ->in([__DIR__ . '/src', __DIR__ . '/tests'])
    ->exclude('vendor');

return (new PhpCsFixer\Config())
    ->setRules([
        '@PER-CS2.0' => true,
        'declare_strict_types' => true,
        'trailing_comma_in_multiline' => [
            'elements' => ['arrays', 'arguments', 'parameters'],
        ],
        'ordered_imports' => ['sort_algorithm' => 'alpha'],
        'no_unused_imports' => true,
        'single_quote' => true,
    ])
    ->setFinder($finder);
```

### Laravel Pint

```json
{
  "preset": "per",
  "rules": {
    "declare_strict_types": true,
    "ordered_imports": { "sort_algorithm": "alpha" }
  }
}
```

### EditorConfig

```ini
root = true

[*.php]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

## CI Quality Gates

Run these checks on every PR:

1. **Code style**: `vendor/bin/php-cs-fixer fix --dry-run --diff` (or
   `vendor/bin/pint --test`)
2. **Static analysis**: `vendor/bin/phpstan analyse --memory-limit=512M`
3. **Baseline enforcement**: Fail if baseline grows

Do not auto-fix in CI — fail the build and require local fixes. Auto-fixing on
CI can cause divergence between the branch and remote.

## Quick Reference

See the reference files for deeper details:

- [code-style.md](references/code-style.md) — PSR-12/PER-CS rules, formatting
  details, tool configs
- [type-system.md](references/type-system.md) — All PHP types, PHPStan/Psalm
  levels, generics, custom rules
- [documentation.md](references/documentation.md) — PHPDoc tags, API docs, ADRs
