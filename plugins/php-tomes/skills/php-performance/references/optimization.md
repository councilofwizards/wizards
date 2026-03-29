# Performance Optimization Reference

## Table of Contents

- [OPcache Configuration Reference](#opcache-configuration-reference)
- [JIT Configuration](#jit-configuration)
- [Preloading](#preloading)
- [Database Optimization Patterns](#database-optimization-patterns)
- [Memory Management](#memory-management)
- [PHP-FPM Tuning](#php-fpm-tuning)
- [Profiling Tools](#profiling-tools)

## OPcache Configuration Reference

### Key INI Settings

| Setting                           | Default | Dev   | Production | Notes                                                  |
| --------------------------------- | ------- | ----- | ---------- | ------------------------------------------------------ |
| `opcache.enable`                  | 1       | 1     | 1          | 3-10x throughput vs disabled                           |
| `opcache.enable_cli`              | 0       | 0     | 0          | Enable only for long-running CLI                       |
| `opcache.memory_consumption`      | 128     | 128   | 256        | MB; increase if >90% used                              |
| `opcache.max_accelerated_files`   | 10000   | 10000 | 20000      | Count PHP files: `find vendor/ -name "*.php" \| wc -l` |
| `opcache.interned_strings_buffer` | 8       | 8     | 16         | MB; deduplicates immutable strings                     |
| `opcache.validate_timestamps`     | 1       | 1     | 0          | 0 = never revalidate; restart FPM on deploy            |
| `opcache.save_comments`           | 1       | 1     | 1          | Required by Laravel, Doctrine                          |
| `opcache.max_wasted_percentage`   | 5       | 5     | 5          | Triggers restart when wasted memory exceeds %          |

### Monitoring OPcache

```php
$status = opcache_get_status(false);
$used   = $status['memory_usage']['used_memory'];
$free   = $status['memory_usage']['free_memory'];
$cached = $status['opcache_statistics']['num_cached_scripts'];
$hitRate = $status['opcache_statistics']['opcache_hit_rate'];
// Alert: $free < 0.10 * ($used + $free) or $hitRate < 95.0
```

## JIT Configuration

### CRTO Bitmask

| Digit | Meaning            | Values                            |
| ----- | ------------------ | --------------------------------- |
| C     | CPU flags          | 0=disable, 1=enable AVX/SSE       |
| R     | Register allocator | 0=none, 1=local, 2=global         |
| T     | JIT trigger        | 0=all, 4=hot functions, 5=tracing |
| O     | Optimization level | 0-5, higher = more aggressive     |

Common values: `1255` (tracing, recommended), `1205` (function).

### Impact by Workload

| Workload                       | JIT Impact |
| ------------------------------ | ---------- |
| Laravel HTTP (I/O-bound)       | +0-5%      |
| Mathematical computation       | +20-50%    |
| Image processing (GD, Imagick) | +10-30%    |
| CLI batch processing           | +10-40%    |
| Regex-heavy text processing    | +5-15%     |

## Preloading

```php
// preload.php — executed once at FPM start
$files = require __DIR__ . '/vendor/composer/autoload_classmap.php';
foreach (array_values($files) as $file) {
    if (is_file($file)) {
        opcache_compile_file($file);
    }
}
```

```ini
opcache.preload=/var/www/html/preload.php
opcache.preload_user=www-data
```

Laravel: `php artisan optimize` generates a preload file. Run during container builds.

## Database Optimization Patterns

### EXPLAIN Output (MySQL)

| Column  | Good Values              | Red Flags                           |
| ------- | ------------------------ | ----------------------------------- |
| `type`  | `ref`, `eq_ref`, `const` | `ALL` (full table scan)             |
| `rows`  | Close to result count    | Much larger than result count       |
| `Extra` | `Using index`            | `Using filesort`, `Using temporary` |
| `key`   | Named index              | `NULL` (no index used)              |

### Composite Index Rules

- Leftmost prefix rule: `(a, b, c)` supports `(a)`, `(a, b)`, `(a, b, c)`
- Place equality columns first, range/sort columns last
- Covering indexes include all SELECT columns, eliminating row lookups (30-70% faster)

### Eager Loading Patterns

```php
// Single relation
Order::with('user')->get();

// Nested
Order::with('user.address')->get();

// Multiple
Order::with(['user', 'items.product', 'discount'])->get();

// Lazy eager loading (collection already loaded)
$orders->load('user');
```

### Query Caching

```php
Cache::remember("products:top10", 300, fn () =>
    Product::orderByDesc('sale_count')->limit(10)->get()
);

// Event-driven invalidation
static::saved(fn () => Cache::forget('products:top10'));
```

### Read Replica Config

```php
'mysql' => [
    'read'  => ['host' => [env('DB_READ_HOST_1'), env('DB_READ_HOST_2')]],
    'write' => ['host' => [env('DB_HOST')]],
    'sticky' => true, // Write connection used for rest of request after a write
];
```

### Slow Query Logging

```ini
[mysqld]
slow_query_log=1
long_query_time=0.1
log_queries_not_using_indexes=1
```

Analyze with `pt-query-digest`.

## Memory Management

### Key Functions

```php
memory_get_peak_usage(true);    // Real allocation (includes PHP overhead)
memory_get_peak_usage(false);   // emalloc usage (user-space only)
memory_get_usage(true);         // Current usage
```

### Chunking Comparison

| Method         | Memory          | Performance on Large Tables |
| -------------- | --------------- | --------------------------- |
| `Model::all()` | O(n) — all rows | N/A                         |
| `chunk()`      | O(batch)        | Degrades (OFFSET scan)      |
| `chunkById()`  | O(batch)        | O(log n) with index         |
| Generator      | O(1) per yield  | Best                        |

### GC Tuning

```php
gc_disable();                   // Safe for tight loops with flat data
gc_enable();
gc_collect_cycles();            // Force collection, returns freed count
gc_status();                    // Returns runs, collected, threshold, roots
```

```ini
zend.gc_threshold=10000         ; Higher = less frequent GC, higher peak memory
```

### WeakMap vs Array Cache

- `WeakMap`: entries freed when key object has no other references
- Array with `spl_object_id()`: IDs can be reused, causes data corruption
- `SplObjectStorage`: strong references prevent GC

## PHP-FPM Tuning

### Process Manager Modes

| Mode       | Behavior                   | Use Case                     |
| ---------- | -------------------------- | ---------------------------- |
| `static`   | Fixed number of workers    | Containers with fixed memory |
| `dynamic`  | Scales between min and max | VMs, variable load           |
| `ondemand` | Spawns workers on request  | Low-traffic, saves memory    |

### max_children Formula

```
max_children = floor(available_memory / avg_worker_memory)
```

Typical Laravel worker: 30-60 MB. Measure with: `ps -o rss= -p $(pgrep -d, php-fpm)`

### Key Settings

| Setting                   | Recommended  | Notes                           |
| ------------------------- | ------------ | ------------------------------- |
| `pm.max_children`         | Memory-based | See formula above               |
| `pm.start_servers`        | 25% of max   | Processes started on pool boot  |
| `pm.min_spare_servers`    | 2-3          | Minimum idle workers            |
| `pm.max_spare_servers`    | 50% of max   | Kill excess idle workers        |
| `pm.max_requests`         | 500          | Recycle to prevent memory leaks |
| `request_slowlog_timeout` | 5s           | Log slow requests               |

## Profiling Tools

| Tool                          | Use Case                                |
| ----------------------------- | --------------------------------------- |
| `EXPLAIN` / `EXPLAIN ANALYZE` | Query execution plan                    |
| MySQL slow query log          | Slow query identification in production |
| Laravel Telescope             | Per-request query log in development    |
| Laravel Debugbar              | N+1 detection, query count per request  |
| Blackfire                     | End-to-end profiling (CPU, memory, I/O) |
| Xdebug profiler               | Call-level memory/CPU profiling         |
| `pt-query-digest`             | Aggregate slow queries from logs        |
| `memory_get_peak_usage()`     | In-code memory profiling                |
