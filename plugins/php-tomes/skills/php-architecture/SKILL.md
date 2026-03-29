---
name: php-architecture
description:
  "Use this skill when structuring a PHP project, applying SOLID principles, choosing design patterns (Strategy,
  Repository, Factory, Decorator), wiring dependency injection, designing exception hierarchies, setting up PSR-3
  logging with Monolog, or implementing resilience patterns (circuit breaker, retry, timeout, fallback). Also covers
  layered and hexagonal architecture."
---

# PHP Architecture Skill

Apply these principles when designing, reviewing, or refactoring PHP application architecture. Target PHP 8.2+. Use
`final` classes by default, `readonly` constructor promotion, and strict types everywhere.

## SOLID Principles

### Single Responsibility Principle (SRP)

A class has one reason to change, mapped to a specific actor or stakeholder.

```php
// ✅ Good — UserRegistrar handles only registration
final class UserRegistrar
{
    public function __construct(
        private readonly UserRepository $users,
        private readonly PasswordHasher $hasher,
        private readonly EventDispatcher $events,
    ) {}

    public function register(RegisterUserCommand $command): User
    {
        $user = new User(
            email: $command->email,
            passwordHash: $this->hasher->hash($command->password),
        );
        $this->users->save($user);
        $this->events->dispatch(new UserRegistered($user));
        return $user;
    }
}
```

```php
// ❌ Bad — User class that registers, emails, invoices, and logs
// Each concern is driven by a different team — auth, marketing, billing, ops
```

Trade-off: SRP can produce many small classes. Excessive decomposition without cohesion creates "shotgun surgery." Group
by actor, not by technical layer.

### Open/Closed Principle (OCP)

Open for extension, closed for modification. Use abstraction and polymorphism instead of conditionals.

```php
// ✅ Good — new discount types require no modification to existing code
interface DiscountStrategy
{
    public function calculate(Money $price, Customer $customer): Money;
}

final class LoyaltyDiscount implements DiscountStrategy
{
    public function calculate(Money $price, Customer $customer): Money
    {
        $rate = match (true) {
            $customer->ordersCount() >= 100 => 0.20,
            $customer->ordersCount() >= 50  => 0.10,
            default                          => 0.0,
        };
        return $price->multiply(1 - $rate);
    }
}
```

```php
// ❌ Bad — growing if/elseif/else chain for each discount type
```

Trade-off: Apply OCP where variation is known to occur. Premature abstraction for extension points that never change
adds indirection with no benefit.

### Liskov Substitution Principle (LSP)

Subtypes must be substitutable for their base types. Violations occur when overrides strengthen preconditions, weaken
postconditions, or throw unexpected exceptions.

```php
// ✅ Good — both implement Shape independently via interface
interface Shape { public function area(): float; }

final class Rectangle implements Shape
{
    public function __construct(
        private readonly float $width,
        private readonly float $height,
    ) {}
    public function area(): float { return $this->width * $this->height; }
}

final class Square implements Shape
{
    public function __construct(private readonly float $side) {}
    public function area(): float { return $this->side ** 2; }
}
```

```php
// ❌ Bad — Square extends Rectangle and overrides setWidth to also set height
// Breaks caller expectation that width and height are independent
```

Prefer composition over inheritance to avoid LSP violations entirely.

### Interface Segregation Principle (ISP)

Split fat interfaces into cohesive, focused ones. Clients depend only on what they use.

```php
// ✅ Good — role-based interfaces
interface Readable
{
    public function find(int $id): ?User;
    public function findAll(): array;
}

interface Writable
{
    public function save(User $user): void;
    public function delete(int $id): void;
}

interface UserRepository extends Readable, Writable {}

// Read-only service depends only on Readable
final class UserProjectionService
{
    public function __construct(private readonly Readable $users) {}
}
```

```php
// ❌ Bad — single interface with 15 methods; read-only consumers forced to depend on write methods
```

### Dependency Inversion Principle (DIP)

High-level modules depend on abstractions, not low-level modules. Foundation of testability.

```php
// ✅ Good — CheckoutService knows nothing about Stripe
interface PaymentGateway
{
    public function charge(Money $amount, string $token): PaymentResult;
}

final class CheckoutService
{
    public function __construct(private readonly PaymentGateway $gateway) {}

    public function checkout(Cart $cart, string $paymentToken): void
    {
        $result = $this->gateway->charge($cart->total(), $paymentToken);
        if (!$result->isSuccessful()) {
            throw new PaymentFailedException($result->errorMessage());
        }
    }
}
```

```php
// ❌ Bad — CheckoutService directly instantiates new StripeGateway()
// Impossible to test without live Stripe; cannot swap providers
```

## Design Patterns

Use patterns to solve recurring problems. Using a pattern without the problem it solves is over-engineering.

### Strategy

Interchangeable algorithms selected at construction time. Use for pricing engines, export formats, notification
channels, or replacing type-branching conditionals.

### Repository

Decouple domain logic from persistence. The interface lives in the domain layer; the implementation lives in
infrastructure. Never expose query builder methods (`->where()`, `->orderBy()`) through the interface.

```php
// ✅ Good — domain-focused interface
interface OrderRepository
{
    public function findById(OrderId $id): ?Order;
    /** @return Order[] */
    public function findByCustomer(CustomerId $customerId): array;
    public function save(Order $order): void;
}
```

Skip this pattern for simple CRUD with no domain logic. Using Eloquent directly is fine for basic screens.

### Factory

Use when object construction is complex, conditional, or requires coordination of dependencies the caller should not
know about.

```php
// ✅ Good — factory encapsulates construction complexity
final class NotificationFactory
{
    public function __construct(
        private readonly MailTransport $mail,
        private readonly SmsTransport $sms,
        private readonly PushTransport $push,
    ) {}

    public function create(NotificationType $type, array $data): Notification
    {
        return match ($type) {
            NotificationType::Email => new EmailNotification($this->mail, $data),
            NotificationType::Sms   => new SmsNotification($this->sms, $data),
            NotificationType::Push  => new PushNotification($this->push, $data),
        };
    }
}
```

```php
// ❌ Bad — static factory methods that call app() or resolve()
// Hides dependencies, untestable without full framework bootstrap
```

Skip factories when `new ClassName()` is clear and sufficient.

### Observer

Decouple reactions to state changes. In Laravel, prefer the Event/Listener system over SplSubject/SplObserver.

```php
// ❌ Bad — observer cascades: observers triggering observers triggering more observers
// Creates implicit ordering dependencies and debugging nightmares
```

### Decorator

Add behavior without subclassing. Compose capabilities at runtime. Use for cross-cutting concerns: logging, caching,
authorization, retry logic, metrics.

```php
// ✅ Good — composable decorators wrapping the same interface
$logger = new ContextEnrichingLogger(
    inner: new TimestampLogger(
        inner: new FileLogger('/var/log/app.log'),
    ),
    extra: ['app_version' => '2.4.1'],
);
```

## Dependency Injection

### Constructor Injection is the Default

All dependencies declared in the constructor are explicit, required, and available for the object's full lifetime.

```php
// ✅ Good — explicit, testable, always valid
final class OrderService
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly PaymentGateway $payments,
        private readonly EventDispatcher $events,
    ) {}
}
```

Use setter injection only for genuinely optional dependencies (e.g., optional logger in a library).

### Anti-Patterns

```php
// ❌ Bad — property injection via #[Inject] attributes
// Object can be constructed in invalid state; couples to container

// ❌ Bad — Service Locator in application code
$payments = app(PaymentGateway::class); // inside a service method
// Hides dependencies, non-portable, requires running container for tests
```

**Rule:** If you write `app()` or `resolve()` outside a ServiceProvider, factory, or bootstrap file, the dependency
graph design is wrong.

### Laravel Container Bindings

```php
// Interface to implementation
$this->app->bind(PaymentGateway::class, StripeGateway::class);

// Singleton lifetime
$this->app->singleton(OrderRepository::class, EloquentOrderRepository::class);

// Contextual binding — different implementation per consumer
$this->app->when(ReportMailer::class)
    ->needs(Mailer::class)
    ->give(SmtpMailer::class);

// Factory binding for complex construction
$this->app->bind(PaymentGateway::class, static function ($app): PaymentGateway {
    return match ($app->make('config')->get('payment.driver')) {
        'stripe' => new StripeGateway($app->make('config')->get('payment.stripe_key')),
        default  => throw new \InvalidArgumentException('Unknown payment driver'),
    };
});
```

## Layered Architecture

### Three Layers

| Layer          | Contains                                                      | Depends On           | Never Imports       |
| -------------- | ------------------------------------------------------------- | -------------------- | ------------------- |
| Domain         | Entities, VOs, repository interfaces, domain services, events | Nothing              | Framework, DB, HTTP |
| Application    | Use-case handlers, commands, DTOs                             | Domain               | Framework, DB       |
| Infrastructure | Eloquent repos, HTTP clients, mailers, queue adapters         | Domain + Application | -                   |

**Dependency direction:** Infrastructure -> Application -> Domain. Domain defines interfaces; infrastructure implements
them.

```php
// ❌ Bad — domain entity extending Eloquent Model
use Illuminate\Database\Eloquent\Model;
class Order extends Model {} // Corrupts the layer boundary
```

### When Layering Helps

- Non-trivial domain logic benefiting from isolation and unit testing
- Multiple infrastructure backends (swap MySQL for Postgres, Mailgun for SES)
- Teams of 3+ developers where layer boundaries define ownership
- Long-lived applications (3+ years)

### When Layering Hurts

- Simple CRUD with no business logic
- Solo/small-team projects where overhead is unjustified
- Prototypes and MVPs prioritizing iteration speed

A Laravel app using Eloquent directly in controllers with no complex domain logic is not "bad architecture" -- it is
appropriate for the problem size.

### Hexagonal Architecture (Ports and Adapters)

- **Driving adapters** (primary): Controllers, Artisan commands, queue listeners -- call application services
- **Driven adapters** (secondary): Eloquent repositories, HTTP clients, mailers -- implement domain ports

## Exception Hierarchy

### PHP Throwable Tree

- `\Exception` -> `\LogicException` (programmer errors) and `\RuntimeException` (external failures)
- `\Error` (engine-level) -- `TypeError`, `DivisionByZeroError`, etc.
- Catch `\Throwable` only at top-level handlers. In application code, catch the most specific type.

### Custom Exception Design Rules

1. One base exception per bounded context (`BillingException`, `InventoryException`)
2. Extend `RuntimeException` for I/O failures, `LogicException` for programmer errors
3. Add structured context via constructor properties -- never encode data only in the message string
4. Keep hierarchies shallow -- rarely more than 3 levels

```php
// ✅ Good — structured context, proper chaining
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
```

### Exception Chaining

Always pass the original exception as `$previous` when wrapping. Throwing without `$previous` discards the original
stack trace.

```php
// ✅ Good — preserves cause chain
catch (\PDOException $e) {
    throw new OrderNotFoundException("Order #{$id} not found", 0, $e);
}
```

### When to Throw vs Return

| Scenario                       | Approach                                                    |
| ------------------------------ | ----------------------------------------------------------- |
| Programmer error               | `throw \InvalidArgumentException`                           |
| External system failure        | `throw \RuntimeException` subclass                          |
| "Not found" (expected, common) | Return `null` or empty collection                           |
| Validation failure             | Return `ValidationResult` VO or throw `ValidationException` |

```php
// ✅ Good — "not found" is normal; null-guard with ?? throw
public function findUser(int $id): ?User { return $this->repository->find($id); }
public function requireUser(int $id): User {
    return $this->repository->find($id) ?? throw new \InvalidArgumentException("User #{$id} not found");
}
```

### Anti-Patterns

```php
// ❌ Bad — bare catch; exception swallowed
try { $this->processPayment($order); } catch (\Exception $e) { /* silence */ }

// ❌ Bad — catching \Throwable without re-throwing; hides TypeError
try { $result = $this->compute(); } catch (\Throwable $e) { return null; }

// ❌ Bad — context only in message string
throw new \RuntimeException("User 42 payment failed with code D0012");
// ✅ Good — structured context
throw new PaymentDeclinedException(declineCode: 'D0012');
```

## Logging (PSR-3)

### Rules

- Depend on `Psr\Log\LoggerInterface`, never on a concrete logger class
- Use structured context arrays, not string interpolation
- Use correct severity levels per RFC 5424
- Never log PII, passwords, API keys, or full request bodies

### Log Level Guide

| Level     | When                                                               |
| --------- | ------------------------------------------------------------------ |
| emergency | System unusable; immediate human intervention required             |
| alert     | Immediate action needed (full disk, DB down)                       |
| critical  | Component failure                                                  |
| error     | Runtime errors; monitored but not immediate                        |
| warning   | Exceptional but not error (deprecated API, rate limit approaching) |
| notice    | Normal but significant events                                      |
| info      | Business events (order placed, user registered)                    |
| debug     | Detailed debug info; never in production                           |

```php
// ❌ Bad — "not found" logged as error; creates alert fatigue
$this->logger->error('User not found', ['id' => $id]);

// ✅ Good — "not found" is informational
$this->logger->info('User lookup: not found', ['user_id' => $id]);

// ✅ Good — structured, queryable fields
$this->logger->info('Order placed', [
    'user_id' => 42, 'order_id' => 1234, 'amount_cents' => 9900, 'currency' => 'USD',
]);
```

### Correlation IDs

Attach a unique request/trace ID to every log entry. Accept `X-Correlation-ID` from upstream or generate one. Propagate
to all outgoing HTTP calls.

## Graceful Degradation

### Circuit Breaker

Prevent hammering a failing dependency. Three states: Closed (normal), Open (fail fast), Half-Open (probe). Store state
in Redis for multi-worker environments.

```php
$result = $breaker->call(
    operation: fn() => $this->stripe->createCharge($params),
    fallback: fn() => $this->queueForRetry($params),
);
```

### Retry with Exponential Backoff

Use for transient failures. Always add jitter to avoid thundering herd. Cap max retries (3 is typical) and max delay.

```php
// ❌ Bad — infinite retry
while (true) { try { return $this->service->call(); } catch (\Exception $e) { continue; } }

// ❌ Bad — retry without backoff
for ($i = 0; $i < 3; $i++) { try { return $svc->call(); } catch (\Exception) {} }
```

### Timeouts

Every external call must have a bounded timeout. Unbounded calls let a slow dependency exhaust all PHP-FPM workers.

### Fallback Hierarchy

1. Primary (live data)
2. Hot cache (Redis, short TTL)
3. Stale cache (expired but usable)
4. Static default (hardcoded safe value)
5. Graceful null (degraded UI)

### Partial Failure Handling

When processing collections, collect errors and continue rather than aborting on first failure. Return structured
results: `{sent: int, failed: int, errors: array}`.

## References

- [SOLID Patterns Reference](references/solid-patterns.md) -- detailed examples and evidence
- [Error Handling Reference](references/error-handling.md) -- exception hierarchy, logging setup, resilience patterns
