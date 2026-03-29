# Observability Reference

## Table of Contents

- [Structured Logging](#structured-logging)
- [Correlation IDs](#correlation-ids)
- [Monolog Configuration](#monolog-configuration)
- [Metrics Collection](#metrics-collection)
- [Distributed Tracing](#distributed-tracing)
- [Health Checks](#health-checks)

## Structured Logging

### PSR-3 Log Levels

| Level       | Use                                         |
| ----------- | ------------------------------------------- |
| `debug`     | Developer context, suppressed in production |
| `info`      | Normal events (order placed, user login)    |
| `warning`   | Recoverable errors, unexpected conditions   |
| `error`     | Operation failed, needs attention           |
| `critical`+ | System impaired, page someone               |

### Good Log Line

```json
{
  "message": "order.placed",
  "level": "INFO",
  "extra": {
    "correlation_id": "01954b22-f9e3-7000-9345-3e9a2b1c5d6f",
    "order_id": 42,
    "user_id": 7,
    "total_cents": 4999
  }
}
```

Rules: dot-namespaced events, IDs not objects, flat context, include `duration_ms` for slow ops. Never log
passwords/tokens/PII. In containers, write to `stdout`/`stderr` only.

## Correlation IDs

```php
// Processor — attach to every log line
final class CorrelationIdProcessor implements ProcessorInterface
{
    private static string $id = '';
    public static function set(string $id): void { self::$id = $id; }
    public static function get(): string { return self::$id; }
    public function __invoke(array $record): array
    {
        $record['extra']['correlation_id'] = self::$id;
        return $record;
    }
}

// Middleware — extract or generate
$id = $request->header('X-Correlation-Id') ?? (string) Uuid::uuid4();
CorrelationIdProcessor::set($id);
$response->headers->set('X-Correlation-Id', $id);

// Queue propagation — include in job constructor
ProcessPaymentJob::dispatch($order->id, CorrelationIdProcessor::get());
```

## Monolog Configuration

### Laravel (config/logging.php)

```php
'stdout' => [
    'driver' => 'monolog', 'handler' => StreamHandler::class,
    'with' => ['stream' => 'php://stdout'],
    'formatter' => JsonFormatter::class,
],
```

### Processors

| Processor                  | Adds                                             |
| -------------------------- | ------------------------------------------------ |
| `WebProcessor`             | `url`, `ip`, `http_method`, `server`, `referrer` |
| `IntrospectionProcessor`   | `file`, `line`, `class`, `function`              |
| `MemoryUsageProcessor`     | `memory_usage`                                   |
| `MemoryPeakUsageProcessor` | `memory_peak_usage`                              |
| `UidProcessor`             | Per-process unique ID                            |

### Log Aggregation

| Pattern            | Environment | Stack                     |
| ------------------ | ----------- | ------------------------- |
| Stdout + collector | Containers  | Fluent Bit/Fluentd        |
| File + shipper     | VMs         | Filebeat to Elasticsearch |
| Loki push          | Grafana     | Promtail or Loki driver   |

## Metrics Collection

### RED Method (Request-Driven)

| Signal   | Metric                            | Type      |
| -------- | --------------------------------- | --------- |
| Rate     | `http_requests_total`             | Counter   |
| Errors   | `http_requests_total{status=5xx}` | Counter   |
| Duration | `http_request_duration_seconds`   | Histogram |

### Metric Types

| Type      | Behavior                | Use For                  |
| --------- | ----------------------- | ------------------------ |
| Counter   | Only increases          | Requests, errors         |
| Gauge     | Up or down              | Queue depth, connections |
| Histogram | Distribution in buckets | Duration, payload size   |

Prefer histograms over summaries (summaries not aggregatable across instances).

### Prometheus Middleware

```php
$start = hrtime(true);
$response = $next($request);
$duration = (hrtime(true) - $start) / 1e9;
$metrics->recordRequest($request->method(), $route, $response->getStatusCode(), $duration);
```

Storage: Redis for FPM (shared across workers), APC for long-running, InMemory for tests.

### Label Rules

Good (bounded): `method`, `route`, `status_code`, `queue_name`, `job_class` Bad (unbounded): `user_id`, `order_id`,
`ip_address` — cardinality explosion.

### PHP-Specific Metrics

| Metric                              | Type      | Purpose              |
| ----------------------------------- | --------- | -------------------- |
| `app_cache_hits/misses_total`       | Counter   | Cache efficiency     |
| `app_db_query_duration_seconds`     | Histogram | Slow query detection |
| `app_job_duration/failures`         | Hist/Ctr  | Queue health         |
| `app_external_api_duration_seconds` | Histogram | Dependency health    |
| `php_opcache_hit_rate`              | Gauge     | OPcache tuning       |

## Distributed Tracing

### OpenTelemetry Setup

```bash
composer require open-telemetry/sdk open-telemetry/exporter-otlp
```

```php
$tracerProvider = new TracerProvider(
    spanProcessors: [new BatchSpanProcessor($exporter)],
    sampler: new AlwaysOnSampler(),
    resource: $resource, // SERVICE_NAME, SERVICE_VERSION, DEPLOYMENT_ENVIRONMENT
);
```

### Creating Spans

```php
$span = $tracer->spanBuilder('order.place')
    ->setAttribute('order.id', $order->id)->startSpan();
$scope = $span->activate();
try {
    // work
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

Name spans after operations (`order.place`), not implementations. Use W3C TraceContext (`traceparent` header).

### Sampling

| Strategy                   | Use Case                |
| -------------------------- | ----------------------- |
| `AlwaysOnSampler`          | Low-traffic services    |
| `TraceIdRatioBasedSampler` | High-traffic (e.g. 10%) |
| `ParentBasedSampler`       | Respect upstream        |

## Health Checks

### Probe Types

| Probe     | On Failure        | Check                 |
| --------- | ----------------- | --------------------- |
| Liveness  | Container restart | Internal state only   |
| Readiness | Remove from LB    | DB, cache, queue      |
| Startup   | Delay liveness    | Slow boot, migrations |

Never put DB checks in liveness probes.

```php
Route::get('/health/live', fn () => response()->json(['status' => 'ok']));
Route::get('/health/ready', function (HealthCheckService $h) {
    $r = $h->check();
    return response()->json($r->toArray(), $r->isHealthy() ? 200 : 503);
});
```

Response: `200` = healthy, `503` = unhealthy. Keep `/health/live` trivially fast (no I/O). Exclude non-critical deps
from readiness.
