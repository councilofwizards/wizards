# Error Handling Reference

## Table of Contents

- [PHP Throwable Tree](#php-throwable-tree)
- [SPL Exception Semantics](#spl-exception-semantics)
- [Custom Exception Hierarchy](#custom-exception-hierarchy)
- [Exception Chaining](#exception-chaining)
- [When to Throw vs Return](#when-to-throw-vs-return)
- [Error-to-Exception Conversion](#error-to-exception-conversion)
- [Global Exception Handler](#global-exception-handler)
- [PSR-3 Logging](#psr-3-logging)
- [Monolog Setup](#monolog-setup)
- [Structured Logging](#structured-logging)
- [Correlation IDs](#correlation-ids)
- [What to Log vs Never Log](#what-to-log-vs-never-log)
- [Circuit Breaker](#circuit-breaker)
- [Retry with Backoff](#retry-with-backoff)
- [Timeouts](#timeouts)
- [Fallback Strategies](#fallback-strategies)
- [Partial Failure Handling](#partial-failure-handling)
- [Anti-Patterns](#anti-patterns)

## PHP Throwable Tree

```
\Throwable (interface)
├── \Exception
│   ├── \LogicException          — programmer errors
│   │   ├── \BadFunctionCallException
│   │   │   └── \BadMethodCallException
│   │   ├── \DomainException
│   │   ├── \InvalidArgumentException
│   │   ├── \LengthException
│   │   └── \OutOfRangeException
│   └── \RuntimeException        — external/runtime failures
│       ├── \OutOfBoundsException
│       ├── \OverflowException
│       ├── \RangeException
│       ├── \UnderflowException
│       └── \UnexpectedValueException
└── \Error                       — engine-level
    ├── \ArithmeticError → \DivisionByZeroError
    ├── \AssertionError
    ├── \ParseError
    └── \TypeError
```

Catch `\Throwable` only at top-level handlers (global handler, middleware).

## SPL Exception Semantics

| Class                      | When                                            |
| -------------------------- | ----------------------------------------------- |
| `LogicException`           | Programmer error; invariant violated            |
| `RuntimeException`         | External failure; I/O, network, filesystem      |
| `InvalidArgumentException` | Wrong input type or value                       |
| `DomainException`          | Valid type but illegal in domain (negative age) |
| `LengthException`          | Exceeds defined length limit                    |
| `OutOfBoundsException`     | Index/key out of range at runtime               |
| `UnexpectedValueException` | Return value or external input wrong format     |

## Custom Exception Hierarchy

```php
// One base per bounded context
class BillingException extends \RuntimeException {}

class PaymentDeclinedException extends BillingException
{
    public function __construct(
        private readonly string $declineCode,
        string $message = '',
        int $code = 0,
        ?\Throwable $previous = null,
    ) {
        parent::__construct($message ?: "Payment declined: {$declineCode}", $code, $previous);
    }

    public function getDeclineCode(): string { return $this->declineCode; }
}

class InsufficientFundsException extends PaymentDeclinedException {}
class CardExpiredException extends PaymentDeclinedException {}
```

Rules: (1) one base per context, (2) extend RuntimeException for I/O /
LogicException for programmer errors, (3) structured context in properties, (4)
keep shallow (3 levels max).

## Exception Chaining

Always pass `$previous` when wrapping exceptions.

```php
try {
    return $this->db->query('SELECT * FROM orders WHERE id = ?', [$id]);
} catch (\PDOException $e) {
    throw new OrderNotFoundException("Order #{$id} not found", 0, $e);
}
```

## When to Throw vs Return

| Scenario                     | Approach                           |
| ---------------------------- | ---------------------------------- |
| Programmer error             | `throw \InvalidArgumentException`  |
| External system failure      | `throw \RuntimeException` subclass |
| "Not found" (expected)       | Return `null` or empty collection  |
| Validation failure           | Return `ValidationResult` VO       |
| Multiple concurrent failures | Collect into error bag             |

```php
// "Not found" is normal — return null
public function findUser(int $id): ?User { return $this->repository->find($id); }

// Null-guard with ?? throw (PHP 8.0+)
public function requireUser(int $id): User {
    return $this->repository->find($id)
        ?? throw new \InvalidArgumentException("User #{$id} not found");
}
```

## Error-to-Exception Conversion

Convert PHP errors to exceptions at bootstrap via `set_error_handler` throwing
`\ErrorException`. Use `register_shutdown_function` + `error_get_last()` for
fatal errors (`E_ERROR`, `E_PARSE`, `E_CORE_ERROR`) which `set_error_handler`
cannot intercept.

Register `set_exception_handler` at the application boundary to catch uncaught
`\Throwable`, log with full context, and render an appropriate error response.

## PSR-3 Logging

Depend on `Psr\Log\LoggerInterface`, never concrete classes. Test with
`NullLogger` or `TestLogger`.

### RFC 5424 Levels

| Level     | Numeric | When                                |
| --------- | ------- | ----------------------------------- |
| emergency | 0       | System unusable                     |
| alert     | 1       | Immediate action needed             |
| critical  | 2       | Component failure                   |
| error     | 3       | Runtime errors, monitored           |
| warning   | 4       | Exceptional but not error           |
| notice    | 5       | Normal but significant              |
| info      | 6       | Routine operations, business events |
| debug     | 7       | Debug only; never in production     |

## Monolog Setup

Use `JsonFormatter` for structured output. Key handlers: `RotatingFileHandler`
(daily rotation), `StreamHandler` (stderr for containers),
`FingersCrossedHandler` (buffer until error for context). Add
`IntrospectionProcessor` and `WebProcessor` for auto-enrichment.

## Structured Logging

```php
// ❌ Bad — data embedded in string
$this->logger->info("User 42 placed order 1234 for $99.00");

// ✅ Good — every field independently queryable
$this->logger->info('Order placed', [
    'user_id' => 42, 'order_id' => 1234, 'amount_cents' => 9900, 'currency' => 'USD',
]);
```

## Correlation IDs

Implement as a Monolog `ProcessorInterface`. Accept `X-Correlation-ID` from
upstream headers or generate via `bin2hex(random_bytes(16))`. Propagate to all
outgoing HTTP calls.

## What to Log vs Never Log

**Log:** Service entry/exit for critical ops, external system calls, exceptions,
auth events, auth denials, config warnings.

**Never log:** PII (GDPR violation), passwords, API keys, full request bodies
(may contain payment data).

```php
// ❌ Bad
$this->logger->info('Login', ['email' => $user->email, 'password' => $password]);

// ✅ Good — identifiers only
$this->logger->info('Login', ['user_id' => $user->id]);
```

## Circuit Breaker

Three states: Closed (normal), Open (fail fast), Half-Open (probe). Store state
in Redis for multi-worker PHP-FPM.

```php
$breaker = new CircuitBreaker(
    name: 'payment-gateway', logger: $logger,
    failureThreshold: 3, resetTimeoutSeconds: 60.0,
);

$result = $breaker->call(
    operation: fn() => $this->stripe->createCharge($params),
    fallback: fn() => $this->queueForRetry($params),
);
```

## Retry with Backoff

Exponential backoff with full jitter. Cap retries (typically 3) and max delay.

```php
$retry = new RetryStrategy(logger: $logger, maxAttempts: 3, baseDelayMs: 100.0);
$result = $retry->execute(
    operation: fn() => $this->api->fetchData(),
    retryOn: [\RuntimeException::class],
);
```

AWS Architecture Blog (2015): full jitter outperforms no-jitter and equal-jitter
for load distribution.

## Timeouts

Every external call must have a bounded timeout.

```php
// HTTP (Guzzle)
$client = new \GuzzleHttp\Client(['timeout' => 5.0, 'connect_timeout' => 2.0]);

// PDO
$pdo = new \PDO($dsn, $user, $pass, [\PDO::ATTR_TIMEOUT => 5]);

// Redis
$redis->connect('127.0.0.1', 6379, timeout: 2.0);
```

## Fallback Strategies

Hierarchy: (1) Live data -> (2) Hot cache -> (3) Stale cache -> (4) Static
default -> (5) Graceful null.

```php
public function getProduct(int $id): ?Product
{
    try {
        $product = $this->db->findProduct($id);
        $this->cache->set("product:{$id}", $product, ttl: 300);
        return $product;
    } catch (\RuntimeException $e) {
        $this->logger->error('DB unavailable, falling back to cache', ['product_id' => $id]);
    }

    $cached = $this->cache->get("product:{$id}");
    if ($cached !== null) { return $cached; }

    return null; // Caller renders degraded UI
}
```

## Partial Failure Handling

Process collections without aborting on first failure.

```php
public function notifyAll(array $users, string $message): array
{
    $sent = $failed = 0;
    $errors = [];
    foreach ($users as $user) {
        try {
            $this->mailer->send(to: $user->email, body: $message);
            $sent++;
        } catch (\RuntimeException $e) {
            $failed++;
            $errors[$user->id] = $e->getMessage();
        }
    }
    return compact('sent', 'failed', 'errors');
}
```

## Anti-Patterns

```php
// ❌ Bare catch — swallowed exception
try { $this->process(); } catch (\Exception $e) { /* silence */ }

// ❌ Catching \Throwable without re-throwing
try { $this->compute(); } catch (\Throwable $e) { return null; }

// ❌ Infinite retry
while (true) { try { return $svc->call(); } catch (\Exception) { continue; } }

// ❌ Retry without backoff — thundering herd
for ($i = 0; $i < 3; $i++) { try { return $svc->call(); } catch (\Exception) {} }

// ❌ No timeout on external calls
$data = file_get_contents('https://api.example.com/data');

// ❌ Logging PII
$this->logger->info('Login', ['email' => $email, 'password' => $pw]);
```
