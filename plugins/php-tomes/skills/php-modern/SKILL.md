---
name: php-modern
description: "Use this skill when adopting PHP 8.3/8.4 features (property hooks, asymmetric visibility, typed constants, #[Override], json_validate), working with enums, readonly classes, or Fibers, or choosing between application servers (FrankenPHP, Swoole, ReactPHP, RoadRunner). Covers long-running PHP patterns, memory isolation, connection pooling, concurrency models, and migration checklists."
---

# PHP Modern Features & Application Servers

This skill covers PHP 8.3/8.4 language features, enums and readonly patterns, fibers and async primitives, application
server selection, long-running PHP patterns, and concurrency strategies.

## PHP 8.4 Headline Features

### Property Hooks

Property hooks embed `get`/`set` logic directly on property declarations, eliminating getter/setter boilerplate.
Inspired by C# properties. RFC: [Property Hooks](https://wiki.php.net/rfc/property-hooks).

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

**Get-only hooks** create virtual (computed) properties with no backing store:

```php
class Circle
{
    public function __construct(public float $radius) {}

    public float $area {
        get => M_PI * $this->radius ** 2;
    }
}
```

**Key rules:**

- Interfaces can declare `public string $fullName { get; }` requiring implementations to provide a get hook
- Abstract classes can declare `abstract public string $label { get; }`
- Readonly properties can have a `get` hook but NOT a `set` hook
- ~5-15ns overhead per access vs plain properties; negligible for web requests, cache in hot paths
- Migration: replace private field + getter/setter with a single hooked public property

### Asymmetric Visibility

Different visibility for reads vs writes. Most common: `public private(set)`.

```php
class EventStore
{
    public private(set) int $eventCount = 0;

    public function append(object $event): void
    {
        $this->eventCount++; // Internal write OK
    }
}
// $store->eventCount;    // OK — public read
// $store->eventCount = 99; // Fatal error — private(set)
```

| Declaration              | Read      | Write        |
|--------------------------|-----------|--------------|
| `public private(set)`    | public    | private only |
| `public protected(set)`  | public    | protected    |
| `protected private(set)` | protected | private only |

**vs readonly:** `readonly` = write-once. `public private(set)` = writable internally any number of times.

### #[\Deprecated] Attribute

Triggers `E_USER_DEPRECATED` via PHP's native mechanism. Applies to functions, methods, class constants, enum cases. NOT
classes or properties.

```php
#[\Deprecated(message: 'Use formatIso8601() instead.', since: '2.4')]
public function formatDate(\DateTime $dt): string { /* ... */ }
```

### New Array Functions

`array_find()`, `array_find_key()`, `array_any()`, `array_all()` — fill gaps that previously required `array_filter()` +
boilerplate. RFC: [Array Find](https://wiki.php.net/rfc/array_find).

```php
$first = array_find($users, fn($u) => $u['active']); // First match or null
$key   = array_find_key($users, fn($u) => $u['name'] === 'Carol');
$any   = array_any($users, fn($u) => $u['active']);   // bool
$all   = array_all($users, fn($u) => $u['active']);   // bool
```

### Other 8.4 Additions

- **`new` in initializers everywhere**: `private Logger $logger = new NullLogger()`
- **`\Dom\HTMLDocument`**: HTML5-compliant DOM API replacing `DOMDocument`
- **`exit()`/`die()` as true functions**: `register_shutdown_function(exit(...))`
- **JIT improvements**: 5-15% on framework benchmarks vs 8.3 JIT, up to 40% on numerical workloads

## PHP 8.3 Features

### Typed Class Constants

Type declarations on constants, enforced across inheritance. Child can narrow but not widen.

```php
interface HasVersion
{
    const string VERSION = '1.0.0';
}
```

Supports all types except `void`, `never`, `callable`, intersection types.

### json_validate()

Validates JSON without parsing — 2-5x faster than `json_decode()` + error check for large strings.

```php
if (json_validate($payload)) {
    $data = json_decode($payload, true);
}
```

### #[Override] Attribute

Compile-time check that a method intentionally overrides a parent method. If parent method is renamed, PHP throws a
compile-time error.

```php
#[Override]
public function findAll(): array { /* ... */ }
```

**Best practice:** Apply `#[Override]` to all intentional overrides.

### Other 8.3 Features

- **Dynamic class constant fetch**: `Color::{$name}` — works with enum cases too
- **Randomizer additions**: `getFloat()`, `nextFloat()`, `pickArrayKeys()`
- **Readonly clone (partial)**: `clone` allowed on readonly classes for wither patterns

## Enums (PHP 8.1+)

Two flavors: **pure** (no backing value) and **backed** (string or int).

```php
enum Status: string
{
    case Active   = 'active';
    case Inactive = 'inactive';
    case Pending  = 'pending';
}

$s = Status::from('active');     // Status::Active (throws on invalid)
$s = Status::tryFrom('unknown'); // null
```

**Enum capabilities:**

- Methods, static methods, constants (typed in PHP 8.3+)
- Implement interfaces (cannot extend classes)
- PHPStan/Psalm enforce match exhaustiveness
- `cases()` returns all cases

**When to use:**

- **Pure enum**: fixed named states, no serialization need
- **Backed string**: states crossing API/DB boundaries
- **Backed int**: flags, bitmasks (prefer string for clarity)

## Readonly (PHP 8.1+/8.2+)

**Readonly properties** (8.1): assigned exactly once, re-assignment is fatal error.
**Readonly classes** (8.2): all declared properties implicitly readonly. The canonical value object pattern.

```php
readonly class Money
{
    public function __construct(
        public int    $amount,
        public string $currency,
    ) {}

    public function withAmount(int $amount): static
    {
        return new static($amount, $this->currency);
    }
}
```

Rules: cannot extend non-readonly class, cannot have untyped properties, static properties not affected.

## Fibers (PHP 8.1+)

Stackful coroutines for cooperative multitasking. Single-threaded — interleave I/O, not CPU work.

```php
$fiber = new Fiber(function (): void {
    $value = Fiber::suspend('paused');
    echo "Resumed with: {$value}\n";
});
$result = $fiber->start();     // Returns 'paused'
$fiber->resume('hello');       // Fiber prints "Resumed with: hello"
```

**Limitations:** No parallelism, no preemption, cannot suspend from `__destruct` or signal handlers.

**Practical use:** Fibers are the building block; ReactPHP, Amp, and Swoole are the batteries-included solutions. Use
`Fiber::getCurrent() !== null` to detect fiber context.

## Application Servers

### Server Comparison

| Server     | Extension? | Model                    | RPS (approx)  | Best For                     |
|------------|------------|--------------------------|---------------|------------------------------|
| PHP-FPM    | No         | Process per request      | ~800          | Baseline, simple deployments |
| FrankenPHP | No         | Worker pool (Go/Caddy)   | ~4,200-6,800  | Simplest long-running path   |
| Swoole     | Yes        | Coroutine workers        | ~5,000-12,000 | Max throughput, WebSocket    |
| ReactPHP   | No         | Event loop (single proc) | ~2,000        | Workers, CLI async, no ext   |
| RoadRunner | No         | Worker pool (Go binary)  | ~3,500-5,000  | Go ecosystem, gRPC support   |

> Benchmarks are approximate for typical Laravel JSON endpoint (4 cores, 8GB RAM).

### FrankenPHP

Embeds PHP in Caddy (Go). Worker mode = 3-10x throughput over PHP-FPM. Automatic TLS, HTTP/2, HTTP/3, Early Hints (103).

```caddyfile
{
    frankenphp {
        worker {
            file /app/public/index.php
            num 8
        }
    }
}
example.com {
    root * /app/public
    php_server
}
```

Laravel Octane integration: `php artisan octane:install --server=frankenphp`

### Swoole

C extension with coroutine-based runtime. Multi-process model with master/manager/workers. Coroutines transparently
suspend at I/O (MySQL, Redis, cURL) via `Runtime::enableCoroutine(SWOOLE_HOOK_ALL)`.

Key features: connection pooling (`PDOPool`), Swoole Table (shared memory), Task Workers (blocking work offload), native
WebSocket server.

```php
$server->set([
    'worker_num'      => swoole_cpu_num() * 2,
    'task_worker_num'  => 4,
    'enable_coroutine' => true,
    'max_request'      => 10000,
]);
```

### ReactPHP

Pure PHP, event-driven, non-blocking I/O. No extensions required. Single-threaded — one blocking call blocks everything.
Uses Promises or Fiber-based `await()`.

Choose ReactPHP when: no extensions allowed, building background workers/CLI tools, team knows JS-style async.

## Long-Running PHP: Critical Patterns

These patterns apply to ALL long-running servers (FrankenPHP worker mode, Swoole, ReactPHP, RoadRunner).

### Memory Leak Prevention

- **Static caches grow unbounded** — use instance caches with `reset()` methods
- **Closures capture large objects** — use `WeakReference::create()` for long-lived listeners
- **WeakMap** for request-scoped metadata — auto-freed when key object is GC'd
- Call `gc_collect_cycles()` every ~500 requests (not every request — expensive)
- Monitor: compare `memory_get_usage(true)` before/after requests; alert on >1MB growth

### State Isolation Between Requests

Cardinal rule: **no state survives between requests unless explicitly shared.**

- Reset singletons holding request-specific data (auth context, locale, etc.)
- Laravel Octane clones the container per request automatically
- Without Octane: implement `RequestScopeResetter` with registered reset callbacks
- Never write to `$_SERVER`, `$_GET`, `$_POST` — use the request object

### Database Connection Management

- Pool connections — don't create/destroy per request
- Implement reconnect-on-failure (MySQL `wait_timeout` kills idle connections)
- Always commit/rollback transactions in `finally` blocks
- Pool size formula: `max_db_connections / worker_count * 0.8`

### Graceful Restart

- Handle SIGTERM to drain in-flight requests before stopping
- Set `max_request` limits (Swoole) or equivalent as a memory leak safety valve
- Wrap request handlers in `try/catch(\Throwable)` — uncaught exceptions can kill workers

### Migration Checklist

- [ ] Identify all singletons/static properties — add `reset()` methods
- [ ] Audit static caches for unbounded growth
- [ ] Implement connection pooling with reconnect
- [ ] Verify transactions commit/rollback in finally blocks
- [ ] Add try/catch around request handlers
- [ ] Register SIGTERM handler for graceful drain
- [ ] Set max_request limits
- [ ] Monitor memory_get_usage per request in staging
- [ ] Remove direct writes to superglobals
- [ ] Load test with 10,000 requests — confirm flat memory growth

## Concurrency Patterns

### Swoole Coroutines

```php
Runtime::enableCoroutine(SWOOLE_HOOK_ALL);

// WaitGroup: coordinate parallel operations
$wg = new WaitGroup();
foreach ($urls as $url) {
    $wg->add();
    go(function () use ($wg, $url, &$results) {
        // async HTTP...
        $wg->done();
    });
}
$wg->wait();

// Channel: producer/consumer (Go-style)
$channel = new Channel(capacity: 10);
go(fn() => $channel->push($data));
go(fn() => $item = $channel->pop());
```

### ReactPHP + Fibers

```php
// Promise.all for parallel
$responses = Async\await(React\Promise\all([
    $browser->get($url1),
    $browser->get($url2),
]));
```

### pcntl_fork for CPU Parallelism

Fork-based parallel processing for CPU-intensive work. NOT safe inside Swoole coroutines. Use `Swoole\Process` or Task
Workers instead.

### Shared-Nothing vs Shared-State

- **Default: shared-nothing** — workers communicate via Redis/DB/queue. No race conditions, easy horizontal scaling.
- **Shared state (Swoole Table)** — only for read-heavy, rarely-changing data where Redis latency is too high (rate
  limiting, feature flags).

## References

- [php84-features.md](references/php84-features.md) — PHP 8.4 property hooks, asymmetric visibility, array
  functions, #[\Deprecated]
- [php83-features.md](references/php83-features.md) — PHP 8.3 typed constants, json_validate, #[Override], randomizer
- [type-system-oop.md](references/type-system-oop.md) — Type system reference, OOP patterns, SPL, generators
- [servers.md](references/servers.md) — FrankenPHP, Swoole, ReactPHP architecture and configuration
- [concurrency.md](references/concurrency.md) — Concurrency patterns, long-running PHP, connection pooling
