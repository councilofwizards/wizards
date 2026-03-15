# Concurrency & Long-Running PHP Reference

## Table of Contents

- [Fibers](#fibers)
- [Swoole Coroutines](#swoole-coroutines)
- [pcntl_fork Parallelism](#pcntl_fork-parallelism)
- [parallel Extension](#parallel-extension)
- [Shared-Nothing vs Shared-State](#shared-nothing-vs-shared-state)
- [Memory Leak Prevention](#memory-leak-prevention)
- [State Isolation](#state-isolation)
- [Database Connection Management](#database-connection-management)
- [Graceful Restart](#graceful-restart)
- [Exception Handling](#exception-handling)
- [Migration Checklist](#migration-checklist)

## Fibers

PHP 8.1+ stackful coroutines. Cooperative, single-threaded — interleave I/O, not CPU work.

```php
$fiber = new Fiber(function (): void {
    $value = Fiber::suspend('paused');
    echo "Resumed with: {$value}\n";
});
$result = $fiber->start();   // 'paused'
$fiber->resume('hello');     // Prints "Resumed with: hello"
```

### Lifecycle

| Method                 | Returns                         |
|------------------------|---------------------------------|
| `$fiber->start(...$a)` | Value from first `suspend()`    |
| `$fiber->resume($v)`   | Value from next `suspend()`     |
| `Fiber::suspend($v)`   | Value passed to next `resume()` |
| `$fiber->getReturn()`  | Return value after termination  |
| `Fiber::getCurrent()`  | Current Fiber or null           |

### Fibers + ReactPHP

```php
use React\Async;
$user = Async\await($browser->get('https://api.example.com/users/1'));
// Suspends fiber while event loop processes other callbacks

// Parallel with Fibers:
[$a, $b] = Async\await(React\Promise\all([$promise1, $promise2]));
```

### Limitations

- No parallelism (single thread)
- No preemption (CPU-bound fiber blocks all others)
- Cannot suspend from `__destruct` or signal handlers
- Cannot suspend inside catch with finally (edge cases)

## Swoole Coroutines

C-level coroutines with transparent I/O suspension. More powerful than PHP Fibers for Swoole apps.

```php
Runtime::enableCoroutine(SWOOLE_HOOK_ALL);
// PDO, Redis, cURL, streams become non-blocking

go(function () {
    Coroutine::sleep(1.0); // Non-blocking
    echo "Done\n";
});
```

### WaitGroup Pattern

```php
$wg = new Swoole\Coroutine\WaitGroup();
foreach ($urls as $url) {
    $wg->add();
    go(function () use ($wg, $url, &$results) {
        $results[] = fetchUrl($url);
        $wg->done();
    });
}
$wg->wait(); // Suspends until all done
```

### Channel Pattern (Go-style)

```php
$channel = new Swoole\Coroutine\Channel(capacity: 10);

go(fn() => $channel->push("item"));     // Producer (blocks if full)
go(fn() => $item = $channel->pop());     // Consumer (blocks if empty)
$channel->push(null);                    // Sentinel to signal done
```

## pcntl_fork Parallelism

Fork-based parallel for CPU-intensive work. Each child gets full memory copy.

```php
function parallelMap(array $items, callable $fn, int $workers = 4): array
{
    $chunks = array_chunk($items, (int) ceil(count($items) / $workers));
    $pipes = []; $pids = [];

    foreach ($chunks as $chunk) {
        $pipe = stream_socket_pair(STREAM_PF_UNIX, STREAM_SOCK_STREAM, STREAM_IPPROTO_IP);
        $pid = pcntl_fork();
        if ($pid === 0) {
            fclose($pipe[0]);
            fwrite($pipe[1], serialize(array_map($fn, $chunk)));
            fclose($pipe[1]);
            exit(0);
        }
        fclose($pipe[1]);
        $pipes[] = $pipe[0]; $pids[] = $pid;
    }

    $results = [];
    foreach ($pipes as $pipe) { $results[] = unserialize(stream_get_contents($pipe)); fclose($pipe); }
    foreach ($pids as $pid) { pcntl_waitpid($pid, $status); }
    return array_merge(...$results);
}
```

> `pcntl_fork()` is NOT safe inside Swoole coroutines. Use `Swoole\Process` or Task Workers instead.

## parallel Extension

PECL extension for true parallel PHP execution with separate threads. Requires ZTS build.

```php
$runtime = new parallel\Runtime(__DIR__ . '/vendor/autoload.php');
$future = $runtime->run(fn(int $n): int => fibonacci($n), [40]);
$result = $future->value(); // Block until complete
```

Only scalar values, arrays, and closures without captured objects can cross threads. Swoole coroutines preferred for
most scenarios.

## Shared-Nothing vs Shared-State

**Shared-nothing (default):** Workers communicate via Redis/DB/queue. No race conditions, easy horizontal scaling.

**Shared state (Swoole Table):** For read-heavy, rarely-changing data where Redis latency is too high.

```php
$rateLimitTable = new Swoole\Table(10000);
$rateLimitTable->column('count', Swoole\Table::TYPE_INT);
$rateLimitTable->create();
$rateLimitTable->incr($clientIp, 'count'); // Safe from any worker
```

## Memory Leak Prevention

In long-running servers, leaked memory accumulates until worker crash.

### Static Caches

```php
// DANGEROUS: unbounded growth
private static array $cache = [];

// SAFE: instance cache with reset()
private array $cache = [];
public function reset(): void { $this->cache = []; }
```

### Closures Capturing Large Objects

```php
// DANGEROUS
$handler = function () use ($largeObject) { return $largeObject->compute(); };

// SAFE: WeakReference
$weakRef = WeakReference::create($largeObject);
$handler = function () use ($weakRef) { return $weakRef->get()?->compute(); };
```

### WeakMap for Request-Scoped Data

```php
$requestMeta = new WeakMap();
$requestMeta[$request] = ['start_time' => microtime(true)];
// Auto-freed when $request is GC'd
```

### GC and Monitoring

```php
if ($requestCount % 500 === 0) gc_collect_cycles(); // Not every request

$leaked = memory_get_usage(true) - $memBefore;
if ($leaked > 1024 * 1024) error_log("Memory leak: {$leaked} bytes");
```

## State Isolation

**Cardinal rule:** No state survives between requests unless explicitly shared.

### Singleton Contamination

```php
// DANGEROUS: user bleeds into next request
class AuthContext { private static ?self $instance = null; private ?User $user = null; }

// SAFE: explicit reset
class AuthContext {
    private ?User $user = null;
    public function reset(): void { $this->user = null; }
}
```

### Container Scoping

Laravel Octane clones container per request. Without Octane:

```php
class RequestScopeResetter {
    private array $resetters = [];
    public function register(callable $resetter): void { $this->resetters[] = $resetter; }
    public function reset(): void { foreach ($this->resetters as $r) ($r)(); }
}
// Call $resetter->reset() in finally block after every request
```

### Superglobals

Never write to `$_SERVER`, `$_GET`, `$_POST`. Use the request object exclusively.

## Database Connection Management

### Reconnect-on-Failure

```php
class ReconnectingPdo {
    public function connection(): \PDO {
        try { $this->pdo->query('SELECT 1'); }
        catch (\PDOException) { $this->pdo = null; $this->connect(); }
        return $this->pdo;
    }
}
```

### Transaction Cleanup

```php
$db->beginTransaction();
try {
    $db->exec($sql);
    $db->commit();
} catch (\Throwable $e) {
    if ($db->inTransaction()) $db->rollBack();
    throw $e;
}
```

### Pool Sizing

`pool_size = max_db_connections / worker_count * 0.8` (80% headroom for admin connections).

## Graceful Restart

### SIGTERM Handler

```php
pcntl_signal(SIGTERM, function () use (&$shouldStop) {
    $shouldStop = true;
});

while ($request = \frankenphp_handle_request()) {
    if ($shouldStop) break;
    handleRequest($request);
    pcntl_signal_dispatch();
}
```

### Max Request Limits

Swoole: `$server->set(['max_request' => 10000])`. Safety valve for undetected memory leaks.

## Exception Handling

Wrap request handlers in `try/catch(\Throwable)`. Uncaught exceptions can kill the worker.

```php
$server->on('request', function ($request, $response) {
    try {
        handleRequest($request, $response);
    } catch (\Throwable $e) {
        error_log($e->getMessage());
        $response->status(500);
        $response->end('Internal Server Error');
        resetRequestState();
    }
});
```

### File Descriptor Leaks

Always close resources in `finally` blocks. Missing `fclose()` hits fd limits after ~1000 requests.

## Migration Checklist

- [ ] Identify all singletons/static properties — add `reset()` methods
- [ ] Audit static caches for unbounded growth
- [ ] Implement connection pooling with reconnect-on-failure
- [ ] Verify transactions commit/rollback in finally blocks
- [ ] Add try/catch(\Throwable) around request handlers
- [ ] Register SIGTERM handler for graceful drain
- [ ] Set max_request limits
- [ ] Monitor memory_get_usage per request in staging
- [ ] Remove direct writes to superglobals
- [ ] Review registered event listeners for persistent references
- [ ] Load test 10,000 requests — confirm flat memory growth
