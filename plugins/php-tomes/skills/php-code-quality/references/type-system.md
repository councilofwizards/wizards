# Type System Reference

## Table of Contents

- [Scalar Types](#scalar-types)
- [Return Types](#return-types)
- [Nullable Types](#nullable-types)
- [Union Types](#union-types)
- [Intersection Types](#intersection-types)
- [DNF Types](#dnf-types)
- [Special Types](#special-types)
- [Property Types](#property-types)
- [Readonly Classes](#readonly-classes)
- [self, static, parent](#self-static-parent)
- [Type Coercion Behavior](#type-coercion-behavior)
- [PHPStan Levels](#phpstan-levels)
- [PHPStan Configuration](#phpstan-configuration)
- [Psalm Levels](#psalm-levels)
- [Psalm Configuration](#psalm-configuration)
- [PHPStan vs Psalm](#phpstan-vs-psalm)
- [Generics with @template](#generics-with-template)
- [Generic Collections](#generic-collections)
- [Constrained Templates](#constrained-templates)
- [Custom PHPStan Rules](#custom-phpstan-rules)
- [Baseline Management](#baseline-management)
- [Gradual Adoption Strategy](#gradual-adoption-strategy)

## Scalar Types

| Type     | Values                 | Notes                             |
| -------- | ---------------------- | --------------------------------- |
| `int`    | Integer numbers        | 64-bit on 64-bit platforms        |
| `float`  | Floating-point numbers | Accepts `int` without strict mode |
| `string` | Byte strings           | Not Unicode-aware by default      |
| `bool`   | `true` / `false`       |                                   |

## Return Types

Every function/method must declare a return type:

```php
function findUser(int $id): ?User {}        // nullable
function processAll(array $ids): void {}    // no return
function getCount(): int {}
function parse(string $input): string|false {} // union
```

Omitting a return type = implicit `mixed`. PHPStan level 5+ flags this.

## Nullable Types

`?T` is shorthand for `T|null`:

```php
function findByEmail(string $email): ?User
{
    return User::query()->where('email', $email)->first();
}
```

Prefer `?Type` over `mixed` when null is the only alternative.

## Union Types

PHP 8.0+. A value can be one of several types:

```php
function parseId(string|int $id): int
{
    return is_string($id) ? (int) $id : $id;
}
```

Prefer exceptions over `T|false` returns for new code. Reserve `T|false` for wrapping built-in functions.

## Intersection Types

PHP 8.1+. A value must implement all listed types:

```php
function persist(Loggable&Serializable $entity): void {}
```

Only interfaces and classes — no scalars, no `null`.

## DNF Types

PHP 8.2+. Combine unions and intersections:

```php
function process((Countable&Iterator)|array $items): void {}
```

Each intersection group must be wrapped in parentheses.

## Special Types

| Type    | Meaning                                  |
| ------- | ---------------------------------------- |
| `void`  | Returns no value; `return;` is allowed   |
| `never` | Never returns — always throws or exits   |
| `mixed` | Top type — accepts any value             |
| `null`  | Standalone null type (PHP 8.2+)          |
| `true`  | Standalone true literal type (PHP 8.2+)  |
| `false` | Standalone false literal type (PHP 8.0+) |

`never` enables dead-code detection — statements after a `never` call are unreachable.

## Property Types

```php
class User
{
    public int $id;
    public string $email;
    public ?string $name = null;
    public readonly string $uuid;  // PHP 8.1+
}
```

Readonly properties can only be initialized once.

## Readonly Classes

PHP 8.2+. All properties are implicitly readonly and must be typed:

```php
readonly class Money
{
    public function __construct(
        public int $amount,
        public string $currency,
    ) {
    }
}
```

## self, static, parent

| Keyword  | Resolves to                        | Use case                   |
| -------- | ---------------------------------- | -------------------------- |
| `self`   | Class that defines the method      | Factory methods, clone     |
| `static` | Late-static-bound class (subclass) | Fluent builders, Eloquent  |
| `parent` | Parent class                       | Calling overridden methods |

Use `static` for fluent method chains to preserve subtypes.

## Type Coercion Behavior

| Context                     | Result                           |
| --------------------------- | -------------------------------- |
| Non-strict, `"42"` to `int` | Succeeds, value is `42`          |
| Strict, `"42"` to `int`     | `TypeError`                      |
| Strict, `42` to `float`     | Succeeds (only allowed coercion) |
| Non-strict, `null` to `int` | Deprecated in 8.1, error in 9.0  |

## PHPStan Levels

| Level | Checks                                                            |
| ----- | ----------------------------------------------------------------- |
| 0     | Unknown classes, functions, methods; wrong argument counts        |
| 1     | Possibly undefined variables; unknown magic methods               |
| 2     | Unknown methods on all expressions                                |
| 3     | Return type mismatches                                            |
| 4     | Dead code after return/throw                                      |
| 5     | Missing return types reported as mixed                            |
| 6     | Missing return types on all paths                                 |
| 7     | Mixed type passed where it affects behavior                       |
| 8     | Mixed in method calls; call on possibly-null                      |
| 9     | Everything: mixed assignments, impossible checks, strict generics |

Target: level 9.

## PHPStan Configuration

### Minimal

```neon
parameters:
    level: 9
    paths:
        - src
        - app
```

### Full Production (Laravel)

```neon
includes:
    - vendor/phpstan/phpstan/conf/bleedingEdge.neon
    - vendor/nunomaduro/larastan/extension.neon
    - phpstan-baseline.neon

parameters:
    level: 9
    phpVersion: 80200
    paths:
        - app
        - src
        - database/factories
    excludePaths:
        analyse:
            - app/Console/Commands/Legacy/*.php
    checkModelProperties: true
    parallel:
        maximumNumberOfProcesses: 4
```

### CI Caching

```yaml
- uses: actions/cache@v4
  with:
    path: var/cache/phpstan
    key: phpstan-${{ hashFiles('composer.lock', 'phpstan.neon') }}
```

Reduces analysis time by 60-80% on unchanged files.

## Psalm Levels

Psalm levels run opposite to PHPStan — level 1 is strictest:

| Level | Behavior                                              |
| ----- | ----------------------------------------------------- |
| 8     | Only obvious errors (missing classes, undefined vars) |
| 5     | Enforce return types; flag mixed in arithmetic        |
| 3     | Strict generics; flag unsuppressed errors             |
| 1     | Maximum strictness; every mixed must be narrowed      |

## Psalm Configuration

```xml
<psalm errorLevel="3" findUnusedVariablesAndParams="true">
    <projectFiles>
        <directory name="src" />
        <directory name="app" />
        <ignoreFiles>
            <directory name="vendor" />
        </ignoreFiles>
    </projectFiles>
</psalm>
```

### Psalm-Specific Types

```php
/** @psalm-param non-empty-string $email */
/** @psalm-return non-empty-string */
/** @psalm-type UserId = positive-int */
```

Psalm offers `non-empty-string`, `positive-int`, `non-empty-list<T>` for finer granularity.

## PHPStan vs Psalm

| Criterion            | PHPStan              | Psalm                      |
| -------------------- | -------------------- | -------------------------- |
| Speed                | Faster               | Slower on large codebases  |
| Laravel support      | Larastan (excellent) | Plugin (good)              |
| Generics             | Good via @template   | Better: more literal types |
| Community extensions | Very large           | Smaller but growing        |

**Recommendation:** PHPStan level 9 with Larastan for Laravel. Add Psalm for heavy generics.

## Generics with @template

```php
/**
 * @template T
 * @param T $value
 * @return T
 */
function identity(mixed $value): mixed
{
    return $value;
}

$str = identity('hello'); // inferred: string
$num = identity(42);      // inferred: int
```

## Generic Collections

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
    public function add(mixed $item): void { $this->items[] = $item; }

    /** @return TValue|null */
    public function first(): mixed { return $this->items[0] ?? null; }
}

/** @extends TypedCollection<User> */
class UserCollection extends TypedCollection {}
```

## Constrained Templates

```php
/**
 * @template TModel of Model
 */
abstract class Repository
{
    /** @param class-string<TModel> $modelClass */
    public function __construct(private readonly string $modelClass) {}

    /** @return TModel|null */
    public function find(int $id): mixed { return ($this->modelClass)::find($id); }
}

/** @extends Repository<User> */
class UserRepository extends Repository
{
    public function __construct() { parent::__construct(User::class); }
}
```

Use `@template-covariant` when the type parameter only appears in output positions.

## Custom PHPStan Rules

```php
/** @implements Rule<FuncCall> */
class NoDirectEnvAccessRule implements Rule
{
    public function getNodeType(): string { return FuncCall::class; }

    public function processNode(Node $node, Scope $scope): array
    {
        if (!$node->name instanceof Name || $node->name->toString() !== 'getenv') {
            return [];
        }
        return [RuleErrorBuilder::message(
            'Use config() or $_ENV instead of getenv().'
        )->build()];
    }
}
```

Register in `phpstan.neon`:

```neon
services:
    - class: App\PHPStan\Rules\NoDirectEnvAccessRule
      tags: [phpstan.rules.rule]
```

## Baseline Management

- Commit baseline — it is a contract
- Never grow it — CI must fail on new errors
- Shrink over time — schedule as backlog work
- Separate baselines per level when adopting incrementally

```bash
vendor/bin/phpstan analyse --generate-baseline phpstan-baseline.neon
```

## Gradual Adoption Strategy

Start at level 0, increment one level per sprint:

| Sprint | Level | Typical Issues                                  |
| ------ | ----- | ----------------------------------------------- |
| 1      | 0     | Basic syntax, unknown functions                 |
| 2      | 1     | Possibly undefined variables                    |
| 3      | 2-3   | Wrong argument types on built-ins               |
| 4      | 4-5   | Missing return types, dead branches             |
| 5      | 6-7   | Mixed propagation, generic stubs                |
| 6+     | 8-9   | Impossible intersections, contravariance, never |

Always include a reason with inline suppressions:

```php
/** @phpstan-ignore-next-line (Eloquent magic: dynamic relationship) */
```
