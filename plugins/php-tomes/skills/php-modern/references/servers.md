# Application Servers Reference

## Table of Contents

- [Server Comparison](#server-comparison)
- [FrankenPHP](#frankenphp)
- [Swoole](#swoole)
- [ReactPHP](#reactphp)

## Server Comparison

| Feature             | PHP-FPM       | FrankenPHP        | Swoole              | ReactPHP         |
| ------------------- | ------------- | ----------------- | ------------------- | ---------------- |
| Extension required  | No            | No                | Yes (swoole)        | No               |
| Process model       | Fork per req  | Worker pool       | Multi-process       | Single process   |
| Concurrency         | 1 req/process | 1 req/worker      | N coroutines/worker | Event loop       |
| HTTP/2              | Via nginx     | Native (Caddy)    | Config option       | No               |
| HTTP/3              | No            | Native (Caddy)    | No                  | No               |
| Auto TLS            | No            | Yes (Caddy)       | No                  | No               |
| WebSocket           | No            | Via Caddy modules | Native              | Via react/socket |
| Laravel Octane      | No            | First-class       | First-class         | No               |
| Approx RPS (4-core) | ~800          | ~4,200-6,800      | ~5,000-12,000       | ~2,000           |

## FrankenPHP

PHP embedded in Go/Caddy binary. Two modes: classic (PHP-FPM drop-in) and worker
(long-running, 3-10x throughput).

### Caddyfile: Worker Mode

```caddyfile
{
    frankenphp {
        num_threads 4
        worker {
            file /app/public/index.php
            num 8
            env APP_ENV production
        }
    }
}

example.com {
    root * /app/public
    encode zstd br gzip
    php_server
}
```

### Configuration Reference

| Directive                    | Default      | Description                      |
| ---------------------------- | ------------ | -------------------------------- |
| `frankenphp { num_threads }` | 2x CPU cores | PHP threads per server           |
| `worker { file path }`       | --           | Worker PHP script path           |
| `worker { num N }`           | 2x CPU cores | Persistent worker count          |
| `worker { env KEY VALUE }`   | --           | Environment variable for workers |
| `worker { watch [dir] }`     | disabled     | Dev-mode file watching           |

### Worker Mode PHP Script

```php
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

while ($request = \frankenphp_handle_request()) {
    $response = $kernel->handle($laravelRequest = Illuminate\Http\Request::capture());
    $response->send();
    $kernel->terminate($laravelRequest, $response);
}
```

### Early Hints (HTTP 103)

```php
\frankenphp_send_http_early_hints([
    'Link' => ['</app.css>; rel=preload; as=style', '</app.js>; rel=modulepreload']
]);
```

### Docker Production

```dockerfile
FROM dunglas/frankenphp:1-php8.4-alpine AS base
RUN install-php-extensions pdo_pgsql redis opcache intl zip

WORKDIR /app
COPY . .
RUN composer install --no-dev --optimize-autoloader

ENV FRANKENPHP_NUM_WORKERS=8
ENV SERVER_NAME=":80"
EXPOSE 80 443 443/udp
```

Map `443:443/udp` for HTTP/3 (QUIC).

### Laravel Octane

```bash
composer require laravel/octane
php artisan octane:install --server=frankenphp
php artisan octane:start --server=frankenphp --workers=8
```

### Common Pitfalls

1. **Static files through PHP** — use `root * /app/public` + `php_server`
2. **Missing HTTP/3 UDP port** — map `443:443/udp` in Docker
3. **OPcache disabled** — critical in worker mode; disable `validate_timestamps`
4. **No state isolation** — use Octane or manually reset singletons

## Swoole

C extension providing async, coroutine-based runtime. Multi-process: master,
manager, workers + task workers.

### Server Setup

```php
$server = new Swoole\Http\Server('0.0.0.0', 9501);
$server->set([
    'worker_num'       => swoole_cpu_num() * 2,
    'task_worker_num'  => 4,
    'enable_coroutine' => true,
    'max_request'      => 10000,
    'max_coroutine'    => 100000,
    'open_http2_protocol' => true,
    'reload_async'     => true,
    'log_file'         => '/var/log/swoole.log',
    'log_level'        => SWOOLE_LOG_WARNING,
]);
```

### Lifecycle Events

| Event         | When                 | Use                           |
| ------------- | -------------------- | ----------------------------- |
| `start`       | Master process start | Log PID                       |
| `workerStart` | Each worker start    | Bootstrap app, load container |
| `request`     | Each HTTP request    | Handle request in coroutine   |
| `workerStop`  | Worker exits         | Cleanup resources             |

### Coroutine Hooks

```php
Swoole\Runtime::enableCoroutine(SWOOLE_HOOK_ALL);
// PDO, MySQLi, Redis, cURL, streams become non-blocking automatically
```

### Connection Pooling

```php
$pool = new Swoole\Database\PDOPool(
    (new PDOConfig())->withHost('127.0.0.1')->withDbName('app')
        ->withUsername('user')->withPassword('pass'),
    size: 32
);

// In request handler:
$pdo = $pool->get();
try {
    $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
    $stmt->execute([$id]);
    $response->end(json_encode($stmt->fetchAll()));
} finally {
    $pool->put($pdo); // Always return
}
```

### Swoole Table (Shared Memory)

```php
$table = new Swoole\Table(1024);
$table->column('count', Swoole\Table::TYPE_INT);
$table->column('ip', Swoole\Table::TYPE_STRING, 16);
$table->create(); // Must call before server->start()

// Any worker can read/write:
$table->incr($ip, 'count');
```

Pre-allocated — size with headroom. Silently drops data if exceeded.

### WebSocket Server

```php
$server = new Swoole\WebSocket\Server('0.0.0.0', 9502);
$server->on('message', function ($server, $frame) {
    foreach ($server->connections as $fd) {
        if ($server->isEstablished($fd)) {
            $server->push($fd, $frame->data);
        }
    }
});
```

### Task Workers

Offload blocking work (CPU, file I/O) without blocking HTTP workers:

```php
$server->on('request', function ($req, $res) use ($server) {
    $taskId = $server->task(['type' => 'send_email', 'email' => $req->post['email']]);
    $res->end(json_encode(['queued' => $taskId]));
});
$server->on('task', function ($server, $taskId, $workerId, $data) {
    sendEmail($data['email']);
    $server->finish(['status' => 'done']);
});
```

### Docker

```dockerfile
FROM php:8.4-cli
RUN pecl install swoole && docker-php-ext-enable swoole
RUN docker-php-ext-install pdo_mysql opcache
WORKDIR /app
COPY . .
EXPOSE 9501
CMD ["php", "server.php"]
```

## ReactPHP

Pure PHP, event-driven, non-blocking I/O. No extensions required.
Single-threaded, single-process.

### Event Loop

```php
$loop = React\EventLoop\Loop::get();
$loop->addTimer(1.0, fn() => echo "1 second\n");
$loop->addPeriodicTimer(5.0, fn() => echo "Heartbeat\n");
$loop->futureTick(fn() => echo "Next tick\n");
$loop->run();
```

Auto-detects best backend: `ExtEventLoop` > `ExtEvLoop` > `ExtUvLoop` >
`StreamSelectLoop`.

### HTTP Server

```php
$server = new React\Http\HttpServer(function (ServerRequestInterface $request) {
    return Response::json(['path' => $request->getUri()->getPath()]);
});
$socket = new React\Socket\SocketServer('0.0.0.0:8080');
$server->listen($socket);
```

### Promises

```php
$browser->get('https://api.example.com/data')
    ->then(fn($response) => json_decode($response->getBody()))
    ->catch(fn(\Exception $e) => error_log($e->getMessage()));

// Parallel
React\Promise\all([$browser->get($url1), $browser->get($url2)])
    ->then(fn(array $responses) => /* ... */);
```

### Component Ecosystem

| Package               | Purpose                   |
| --------------------- | ------------------------- |
| `react/event-loop`    | Core event loop           |
| `react/promise`       | Promise/A+ implementation |
| `react/stream`        | Readable/writable streams |
| `react/socket`        | TCP/UDP client and server |
| `react/http`          | HTTP server and client    |
| `react/dns`           | Async DNS resolver        |
| `react/child-process` | Async child processes     |

> Any package making blocking I/O calls blocks the entire event loop. Use
> async-aware alternatives.

### When to Choose ReactPHP

- Cannot install PHP extensions
- Building background workers, queue consumers, CLI async tools
- Team familiar with JS-style async patterns
- Moderate throughput requirements (~2,000 RPS)
