---
name: php-performance
description: "Use this skill when tuning OPcache/JIT, fixing N+1 queries, managing memory, configuring Composer, building CI/CD pipelines, writing Dockerfiles for PHP, deploying with zero downtime, or setting up logging, metrics, and tracing. Covers PHP-FPM tuning, preloading, read replicas, Prometheus, OpenTelemetry, health checks, and Kubernetes probes."
---

# PHP Performance, Dependencies, Deployment & Observability

## OPcache Configuration

OPcache stores compiled bytecode in shared memory, eliminating parse/compile per request. Typical 3-10x throughput gain.

```ini
; Production OPcache config
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.interned_strings_buffer=16
opcache.validate_timestamps=0       ; MUST restart FPM on deploy
opcache.save_comments=1             ; Required by Laravel/DI containers
```

```php
// ❌ Bad: No OPcache monitoring — silent degradation when cache is full
// Deploy and hope for the best

// ✅ Good: Monitor OPcache in health checks
$status = opcache_get_status(false);
$freeMemory = $status['memory_usage']['free_memory'];
$totalMemory = $freeMemory + $status['memory_usage']['used_memory'];
assert($freeMemory > 0.10 * $totalMemory, 'OPcache memory >90% full');
```

### Preloading (PHP 7.4+)

Compile framework files once at FPM start. Laravel: run `php artisan optimize` during container builds.

```ini
opcache.preload=/var/www/html/bootstrap/preload.php
opcache.preload_user=www-data
```

### JIT

JIT compiles hot opcodes to native machine code. Helps CPU-bound workloads (+20-50%), negligible for I/O-bound web
apps (+0-5%).

```ini
opcache.jit_buffer_size=64M
opcache.jit=1255                    ; Tracing JIT — recommended default
```

Enable JIT only after benchmarking your specific workload. For typical Laravel HTTP requests, JIT overhead may exceed
its benefit.

## Database Optimization

Database I/O is the dominant bottleneck in most PHP apps.

### N+1 Detection and Fix

```php
// ❌ Bad: N+1 — 1 query for orders + N queries for users
$orders = Order::all();
foreach ($orders as $order) {
    echo $order->user->name;        // SELECT * FROM users WHERE id = ? (x1000)
}

// ✅ Good: Eager loading — 2 queries total
$orders = Order::with('user')->get();
foreach ($orders as $order) {
    echo $order->user->name;        // No query — already loaded
}
```

### Indexing Strategy

Follow the **leftmost prefix rule** for composite indexes: `(a, b, c)` supports `(a)`, `(a, b)`, `(a, b, c)` but not
`(b)` alone.

```sql
-- Correct composite index for filter + sort
CREATE INDEX idx_orders_user_status_date
    ON orders (user_id, status, created_at DESC);
```

Use `EXPLAIN` / `EXPLAIN ANALYZE` to verify index usage. Watch for `type=ALL` (full table scan) and `key=NULL` (no
index).

### Query Caching

```php
// ✅ Good: Cache slow, infrequently-changing queries
$topProducts = Cache::remember('products:top10', 300, function () {
    return Product::orderByDesc('sale_count')->limit(10)->get();
});
```

Never cache user-specific data under shared keys. Always include user/tenant ID in the cache key.

### Read Replicas

```php
// config/database.php — read/write split
'mysql' => [
    'read'  => ['host' => [env('DB_READ_HOST_1'), env('DB_READ_HOST_2')]],
    'write' => ['host' => [env('DB_HOST')]],
    'sticky' => true,               // Use write connection after a write in same request
],
```

## Memory Management

### Generators vs Arrays

```php
// ❌ Bad: Loads all rows into memory at once
$users = User::all();               // 100K users = ~20MB

// ✅ Good: Process one chunk at a time
User::orderBy('id')->chunkById(1000, function ($chunk) {
    foreach ($chunk as $user) { processUser($user); }
});
// Peak memory: ~100KB (1 chunk)
```

Prefer `chunkById()` over `chunk()` for tables over ~100K rows — it uses `WHERE id > last_seen_id` instead of OFFSET.

### WeakMap for Object Caches (PHP 8.0+)

```php
// ❌ Bad: Strong reference keeps objects alive, causes memory leaks
private array $cache = [];

// ✅ Good: WeakMap — entries freed when object goes out of scope elsewhere
private WeakMap $cache;
```

### Garbage Collection

Disable GC only for tight loops proven to create no cycles:

```php
gc_disable();
processMillionFlatRecords();
gc_enable();
```

## Composer Dependency Management

### Lock File Discipline

```bash
# ✅ Good: Deterministic install from lock file
composer install

# ❌ Bad in CI/CD: Resolves fresh, ignores lock file
composer update
```

Always commit `composer.lock`. Never commit `vendor/`.

### Production Install

```bash
composer install \
  --no-dev \
  --no-interaction \
  --optimize-autoloader \
  --classmap-authoritative \
  --prefer-dist
```

`--classmap-authoritative` eliminates `file_exists` calls during autoloading — 30-40% faster class resolution.

### Version Constraints

```json
// ✅ Good: Caret — allows minor/patch updates, blocks major
"guzzlehttp/guzzle": "^7.0"

// ❌ Bad: Wildcard — accepts breaking changes
"vendor/package": "*"

// ❌ Bad: Exact pin — blocks security patches
"vendor/package": "1.2.3"
```

The lock file provides reproducibility. Caret constraints in `composer.json` allow safe updates.

### Platform Requirements

```json
{
    "require": { "php": "^8.2", "ext-pdo": "*", "ext-redis": "*" },
    "config": { "platform": { "php": "8.2.0" } }
}
```

### Security Auditing

```bash
composer audit --no-dev             # Check for known CVEs
composer outdated --direct          # Show outdated direct dependencies
```

Automate with Dependabot or Renovate Bot.

## CI/CD Pipelines

### Stage Order

```
lint → static-analysis → test → build → deploy
```

Fail fast: a style error in 10 seconds is cheaper than one caught after a 3-minute test suite.

### GitHub Actions PHP Pipeline

```yaml
jobs:
  lint:
    steps:
      - uses: shivammathur/setup-php@v2
        with: { php-version: "8.4", tools: php-cs-fixer }
      - run: composer install --no-interaction --prefer-dist
      - run: php-cs-fixer fix --dry-run --diff

  analyze:
    needs: lint
    steps:
      - run: vendor/bin/phpstan analyse --no-progress

  test:
    needs: lint
    strategy:
      matrix:
        php: ["8.3", "8.4"]
    services:
      mysql: { image: "mysql:8.0" }
    steps:
      - run: vendor/bin/phpunit --coverage-clover coverage.xml
```

### Caching

Cache `~/.composer/cache` keyed on `composer.lock` hash. Avoid caching `vendor/` directly — state depends on PHP
version.

### Pipeline Security

- Pin action versions to full SHA, not tags
- Use GitHub Environments with required reviewers for production
- Never echo secrets in logs

## Docker Containerization

### Multi-Stage Build

```dockerfile
# Stage 1: Composer deps
FROM composer:2.8 AS composer-deps
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --optimize-autoloader --classmap-authoritative

# Stage 2: Production runtime
FROM php:8.4-fpm-alpine AS production
# Install extensions, copy vendor from stage 1
COPY --from=composer-deps /app/vendor ./vendor
USER appuser                        # Never run as root
```

### PHP-FPM Tuning

```ini
pm = dynamic
pm.max_children = 10                ; floor(available_memory / avg_worker_memory)
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 5
pm.max_requests = 500               ; Recycle workers to prevent memory leaks
```

A typical Laravel worker uses 30-60 MB. For a 512 MB container: `floor(512 / 40) = 12`, leave headroom.

### Image Best Practices

- Start with Alpine, switch to Debian only if extensions fail to compile
- Tag images with Git SHA for immutable deploys — never deploy `latest`
- Set `opcache.validate_timestamps=0` — container images are immutable
- Run `composer audit` and Trivy scan in CI

## Zero-Downtime Deploys

### Strategies

| Strategy   | Rollback Speed | Complexity |
|------------|----------------|------------|
| Blue-green | Seconds        | Medium     |
| Rolling    | Minutes        | Low        |
| Canary     | Seconds        | High       |

### Database Migration Pattern (Expand-Contract)

Never rename/drop columns in a single deploy when old code is still running.

```php
// ❌ Bad: Breaks old code still running during rollout
Schema::table('users', fn ($t) => $t->renameColumn('status', 'order_status'));

// ✅ Good: Phase 1 — Add nullable column (backwards-compatible)
Schema::table('users', fn ($t) => $t->string('display_name')->nullable());
// Phase 2 — Deploy new code that writes to both columns
// Phase 3 — Backfill data
// Phase 4 — Drop old column after all old code is gone
```

Run migrations **before** deploying new application code. Never run `migrate:fresh` in production.

### Deployer (Atomic Symlink)

```bash
php vendor/bin/dep deploy production      # Deploy with atomic symlink switch
php vendor/bin/dep rollback production    # Instant rollback
```

## Structured Logging

### PSR-3 + JSON Output

```php
// ❌ Bad: Interpolated strings — unsearchable
$logger->info("User $userId placed order $orderId");

// ✅ Good: Structured context — machine-parseable
$logger->info('order.placed', [
    'order_id'   => $order->id,
    'user_id'    => $order->userId,
    'total_cents' => $order->totalCents,
]);
```

Use dot-namespaced event names. Include IDs, not full objects. Never log passwords/tokens/PII.

### Correlation IDs

Generate a UUID at the request boundary. Propagate it through every log line, queue job, and outbound HTTP call.

```php
// Middleware: extract or generate correlation ID
$id = $request->header('X-Correlation-Id') ?? Uuid::uuid4()->toString();
CorrelationIdProcessor::set($id);
$response->headers->set('X-Correlation-Id', $id);
```

### Log Levels

- `debug` — suppressed in production
- `info` — normal events (order placed, user login)
- `warning` — recoverable errors
- `error` — operation failed, needs attention
- `critical`/`alert`/`emergency` — system impaired, page someone

### Container Logging

Always write to `stdout`/`stderr` in containers. Let Fluent Bit/Fluentd/Promtail collect logs. Never write to files in
containers — unbounded disk usage.

## Metrics Collection

### RED Method (Request-Driven Services)

| Signal   | Metric                            | Type      |
|----------|-----------------------------------|-----------|
| Rate     | `http_requests_total`             | Counter   |
| Errors   | `http_requests_total{status=5xx}` | Counter   |
| Duration | `http_request_duration_seconds`   | Histogram |

### Prometheus PHP Client

```php
// Middleware: record request metrics
$start = hrtime(true);
$response = $next($request);
$duration = (hrtime(true) - $start) / 1e9;

$metrics->recordRequest($request->method(), $route, $response->getStatusCode(), $duration);
```

Protect the `/metrics` endpoint — never expose it publicly. Use IP allowlist or auth.

### Label Design

```php
// ❌ Bad: Unbounded cardinality — creates millions of time series
->inc([$method, $route, $userId]);

// ✅ Good: Bounded cardinality
->inc([$method, $route, (string) $statusCode]);
```

Never use `user_id`, `order_id`, or `ip_address` as Prometheus labels.

## Distributed Tracing (OpenTelemetry)

### Creating Spans

```php
$span = $tracer->spanBuilder('order.place')
    ->setAttribute('order.id', $order->id)
    ->startSpan();
$scope = $span->activate();

try {
    $this->chargePayment($order);
    $span->setStatus(StatusCode::STATUS_OK);
} catch (\Throwable $e) {
    $span->recordException($e);
    $span->setStatus(StatusCode::STATUS_ERROR, $e->getMessage());
    throw $e;
} finally {
    $scope->detach();
    $span->end();
}
```

Name spans after the operation (`order.place`), not the implementation (`OrderService::place`). Use W3C TraceContext (
`traceparent` header) for cross-service propagation.

### Sampling

`AlwaysOnSampler` for low-traffic. `TraceIdRatioBasedSampler(0.1)` for 10% sampling on high-traffic services.

## Health Checks

### Liveness vs Readiness

```php
// ❌ Bad: DB check in liveness probe — cascading restarts when DB is down
Route::get('/health', fn () => DB::select('SELECT 1') ? 'ok' : 'fail');

// ✅ Good: Separate probes
Route::get('/health/live', fn () => response()->json(['status' => 'ok']));
Route::get('/health/ready', fn (HealthCheckService $h) =>
    response()->json($h->check()->toArray(), $h->check()->isHealthy() ? 200 : 503)
);
```

- **Liveness**: Is the process alive? Failure restarts the container. Check only internal state.
- **Readiness**: Can it serve traffic? Failure removes from load balancer. Check DB, Redis, etc.

Never put external dependency checks in liveness probes.

### Kubernetes Probes

```yaml
livenessProbe:
  httpGet: { path: /health/live, port: 8080 }
  initialDelaySeconds: 10
  periodSeconds: 15
readinessProbe:
  httpGet: { path: /health/ready, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 10
```

## Deploy Checklist

1. `composer install --no-dev --optimize-autoloader --classmap-authoritative`
2. `php artisan config:cache && php artisan route:cache && php artisan view:cache`
3. `php artisan migrate --force`
4. Build and push Docker image tagged with Git SHA
5. Roll out new containers (blue-green, rolling, or canary)
6. Verify health checks pass before routing traffic
7. Monitor OPcache hit rate, error rate, and p95 latency in first minutes
8. Keep rollback path ready (symlink flip, `kubectl rollout undo`, LB switch)
