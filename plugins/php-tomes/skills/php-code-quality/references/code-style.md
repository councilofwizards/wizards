# Code Style Reference

## Table of Contents

- [PSR Standards Evolution](#psr-standards-evolution)
- [PSR-1 Baseline](#psr-1-baseline)
- [PSR-12 File Structure](#psr-12-file-structure)
- [PER-CS 2.0 Additions](#per-cs-20-additions)
- [Naming Convention Table](#naming-convention-table)
- [Formatting Rules](#formatting-rules)
- [Brace Placement](#brace-placement)
- [Spacing Rules](#spacing-rules)
- [Blank Line Rules](#blank-line-rules)
- [PHP-CS-Fixer Configuration](#php-cs-fixer-configuration)
- [Laravel Pint Configuration](#laravel-pint-configuration)
- [ECS Configuration](#ecs-configuration)
- [EditorConfig](#editorconfig)
- [CI Integration](#ci-integration)

## PSR Standards Evolution

| Standard   | Year | Status                               |
| ---------- | ---- | ------------------------------------ |
| PSR-1      | 2012 | Active — minimal baseline            |
| PSR-2      | 2012 | Deprecated — replaced by PSR-12      |
| PSR-12     | 2019 | Active — extended style for PHP 7+   |
| PER-CS 2.0 | 2023 | Active — living standard for PHP 8.x |

PER-CS 2.0 is the current recommendation. Laravel Pint defaults to PER-CS. Symfony tracks it. Do not mix PSR-12 and
PER-CS rulesets in the same fixer config — some rules conflict.

## PSR-1 Baseline

- Files use only `<?php` or `<?=` tags — never short `<?`
- Files use UTF-8 without BOM
- One class per file, namespace mirrors directory structure (PSR-4)
- Class names: `StudlyCaps`
- Method names: `camelCase`
- Constants: `UPPER_SNAKE_CASE`

## PSR-12 File Structure

```php
<?php

declare(strict_types=1);                     // Line 3, blank line after

namespace App\Domain\Order;                   // Blank line after declare

use App\Domain\User\User;                    // Grouped and sorted
use App\Contracts\Repository;
use RuntimeException;

class OrderService implements Repository     // Opening brace on new line
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

### Modifier Order

`abstract`/`final` -> `public`/`protected`/`private` -> `static`

```php
abstract protected function validate(array $data): bool;
final public static function create(): static
{
    return new static();
}
```

### Constructor Property Promotion

Each promoted property on its own line:

```php
public function __construct(
    private readonly UserRepository $users,
    private readonly Hasher $hasher,
    private readonly EventDispatcher $events,
) {
}
```

## PER-CS 2.0 Additions

### Enums

```php
enum OrderStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Completed = 'completed';

    public function label(): string
    {
        return match($this) {
            self::Pending => 'Pending Review',
            self::Processing => 'In Progress',
            self::Completed => 'Done',
        };
    }
}
```

### Intersection Types and `never`

```php
function processCollection(Countable&Stringable $collection): void {}
function fail(string $message): never
{
    throw new \RuntimeException($message);
}
```

### Named Arguments

```php
$result = array_slice(
    array: $items,
    offset: 0,
    length: 10,
    preserve_keys: true,
);
```

## Naming Convention Table

| Construct                          | Convention         | Example                      |
| ---------------------------------- | ------------------ | ---------------------------- |
| Classes, interfaces, traits, enums | `StudlyCaps`       | `UserRepository`, `HasRoles` |
| Methods and functions              | `camelCase`        | `findByEmail()`              |
| Variables and properties           | `camelCase`        | `$userId`, `$orderItems`     |
| Constants (class and global)       | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`            |
| Enum cases                         | `StudlyCaps`       | `OrderStatus::Pending`       |
| Files containing a class           | `ClassName.php`    | `UserRepository.php`         |
| Non-class files                    | `kebab-case.php`   | `helpers.php`                |
| Namespaces                         | `StudlyCaps`       | `App\Domain\Order`           |

### Interface Naming

No "I" prefix — use descriptive names:

```php
// ❌ Bad
interface IUserRepository {}

// ✅ Good
interface UserRepository {}
interface Cacheable {}
interface HasTimestamps {}
```

### Acronym Handling

Treat acronyms as words:

```php
// ❌ Bad
class HTTPSHandler {}
class JSONParser {}

// ✅ Good
class HttpsHandler {}
class JsonParser {}
```

### Boolean Methods

Prefix with `is`, `has`, `can`, `should`, or `was`:

```php
public function isActive(): bool {}
public function hasPermission(string $perm): bool {}
public function canProcessRefunds(): bool {}
```

## Formatting Rules

### Indentation

4 spaces per level. Never tabs.

### Line Length

- Soft limit: 120 characters
- Hard limit: 160 characters

Break long calls with each argument on its own line:

```php
$result = $this->orderRepository->findByUserAndStatus(
    userId: $userId,
    status: OrderStatus::Pending,
    includeArchived: true,
);
```

Break chained calls:

```php
$orders = Order::query()
    ->where('user_id', $userId)
    ->where('status', OrderStatus::Pending)
    ->orderBy('created_at', 'desc')
    ->limit(10)
    ->get();
```

## Brace Placement

| Construct         | Brace position |
| ----------------- | -------------- |
| Class             | Own line       |
| Method            | Own line       |
| Control structure | Same line      |
| Closure           | Same line      |
| Arrow function    | No braces      |

Always use braces even for single-line bodies.

## Spacing Rules

- Binary operators: one space each side (`$a + $b`)
- Unary operators: no space (`$count++`, `!$flag`)
- After control keywords: one space (`if (`, `foreach (`)
- Function calls: no spaces around parens (`strlen($s)`)
- Multi-line arrays: trailing comma required (PER-CS)

## Blank Line Rules

- One blank line between methods
- No blank line after opening brace of class/method
- No blank line before closing brace
- One blank line between use block and class declaration

## PHP-CS-Fixer Configuration

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

## Laravel Pint Configuration

```json
{
  "preset": "per",
  "rules": {
    "declare_strict_types": true,
    "ordered_imports": { "sort_algorithm": "alpha" }
  }
}
```

## ECS Configuration

```php
// ecs.php
use Symplify\EasyCodingStandard\Config\ECSConfig;

return ECSConfig::configure()
    ->withPaths([__DIR__ . '/src', __DIR__ . '/tests'])
    ->withPreparedSets(psr12: true);
```

## EditorConfig

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

## CI Integration

Run style checks on every PR. Do not auto-fix in CI — fail the build and require local fixes.

```yaml
- name: Check code style
  run: vendor/bin/php-cs-fixer fix --dry-run --diff
```

Auto-fixing on CI can cause divergence between the branch and remote if the fix is committed back.
