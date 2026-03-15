# SOLID & Design Patterns Reference

## Table of Contents

- [SRP — Single Responsibility](#srp--single-responsibility)
- [OCP — Open/Closed](#ocp--openclosed)
- [LSP — Liskov Substitution](#lsp--liskov-substitution)
- [ISP — Interface Segregation](#isp--interface-segregation)
- [DIP — Dependency Inversion](#dip--dependency-inversion)
- [Strategy Pattern](#strategy-pattern)
- [Repository Pattern](#repository-pattern)
- [Factory Pattern](#factory-pattern)
- [Observer Pattern](#observer-pattern)
- [Decorator Pattern](#decorator-pattern)
- [Dependency Injection](#dependency-injection)
- [Layered Architecture](#layered-architecture)
- [Evidence](#evidence)

## SRP — Single Responsibility

A class has one reason to change, mapped to a specific actor/stakeholder. Many small classes > fewer large ones, but
excessive decomposition without cohesion creates shotgun surgery.

## OCP — Open/Closed

Achieve through abstraction and polymorphism, not conditionals.

```php
interface DiscountStrategy
{
    public function calculate(Money $price, Customer $customer): Money;
}

final class PercentageDiscount implements DiscountStrategy
{
    public function __construct(private readonly float $rate) {}
    public function calculate(Money $price, Customer $customer): Money
    {
        return $price->multiply(1 - $this->rate);
    }
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

// ✅ Good — adding new discount types requires no modification
final class PriceCalculator
{
    public function __construct(private readonly DiscountStrategy $discount) {}
    public function calculate(Money $price, Customer $customer): Money
    {
        return $this->discount->calculate($price, $customer);
    }
}
```

Apply OCP where variation is known. Premature abstraction for stable extension points is wasted indirection.

## LSP — Liskov Substitution

Subtypes must be substitutable without altering correctness.

```php
// ✅ Good — independent implementations via interface
interface Shape { public function area(): float; }

final class Rectangle implements Shape
{
    public function __construct(private readonly float $width, private readonly float $height) {}
    public function area(): float { return $this->width * $this->height; }
}

final class Square implements Shape
{
    public function __construct(private readonly float $side) {}
    public function area(): float { return $this->side ** 2; }
}
```

```php
// ❌ Bad — classic LSP violation
class Square extends Rectangle
{
    public function setWidth(float $w): void
    {
        parent::setWidth($w);
        parent::setHeight($w); // Mutates height unexpectedly
    }
}
```

PHP's type system enforces structural contracts only, not behavioral ones. Prefer composition over inheritance.

## ISP — Interface Segregation

```php
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

// Full repository composes both
interface UserRepository extends Readable, Writable {}

// ✅ Good — read-only consumer depends only on Readable
final class UserProjectionService
{
    public function __construct(private readonly Readable $users) {}
}
```

Name interfaces after the client role, not the implementor. Avoid excessive fragmentation -- group methods a real client
uses together.

## DIP — Dependency Inversion

```php
// ✅ Good — high-level module depends on abstraction
interface PaymentGateway
{
    public function charge(Money $amount, string $token): PaymentResult;
}

final class StripeGateway implements PaymentGateway
{
    public function charge(Money $amount, string $token): PaymentResult { /* Stripe SDK */ }
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

For simple scripts with no meaningful variation, the abstraction cost may not be worth paying.

## Strategy Pattern

Problem: Behavior varies by context; algorithm family is stable.

When to use: Interchangeable algorithms, configurable behaviors (pricing, export formats, notification channels),
replacing type-branching conditionals.

When NOT to use: Only one algorithm with no real variation expected.

## Repository Pattern

Problem: Decouple domain logic from persistence. Interface in domain layer; implementation in infrastructure.

```php
interface OrderRepository
{
    public function findById(OrderId $id): ?Order;
    public function findByCustomer(CustomerId $customerId): array;
    public function save(Order $order): void;
}
```

Never expose `->where()`, `->orderBy()`, `->paginate()` through the interface. Use `InMemoryOrderRepository` for tests.
Skip for simple CRUD.

## Factory Pattern

Problem: Object construction is complex, conditional, or requires hidden dependencies.

```php
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

Skip when `new ClassName()` is clear and sufficient. Never use static factories that call `app()`.

## Observer Pattern

Problem: Decouple reactions to state changes. In Laravel, use Event/Listener system.

Avoid observer cascades (observers triggering observers) -- creates implicit ordering dependencies.

## Decorator Pattern

Problem: Add behavior without subclassing. Compose at runtime.

```php
interface Logger
{
    public function log(string $level, string $message, array $context = []): void;
}

final class TimestampLogger implements Logger
{
    public function __construct(private readonly Logger $inner) {}
    public function log(string $level, string $message, array $context = []): void
    {
        $this->inner->log($level, sprintf('[%s] %s', date('c'), $message), $context);
    }
}

// Compose at bootstrap
$logger = new ContextEnrichingLogger(
    inner: new TimestampLogger(inner: new FileLogger('/var/log/app.log')),
    extra: ['app_version' => '2.4.1'],
);
```

Use for logging, caching, auth checks, retry, metrics. Prefer middleware pipeline when interface has many methods.

## Dependency Injection

Constructor injection is the default. All dependencies visible, object always valid, fully testable.

```php
// ✅ Good — constructor injection
final class OrderService
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly PaymentGateway $payments,
        private readonly EventDispatcher $events,
    ) {}
}
```

Setter injection: only for genuinely optional deps. Property injection (`#[Inject]`): never in application code.

Service Locator (`app()`, `resolve()`) in domain/application code: never. Only in ServiceProviders, factories,
bootstrap.

## Layered Architecture

**Domain:** Entities, VOs, repository interfaces, domain services, events. Zero framework imports.

**Application:** Use-case handlers, commands, DTOs. Depends on domain only.

**Infrastructure:** Eloquent repos, HTTP clients, mailers. Implements domain interfaces.

```
App\Domain\Order\Entity\Order
App\Domain\Order\Repository\OrderRepository          // Interface
App\Application\Order\Handler\PlaceOrderHandler
App\Infrastructure\Order\Repository\EloquentOrderRepository
```

Hexagonal: driving adapters (controllers, CLI) call application layer; driven adapters (repos, clients) implement domain
ports.

Layer only when domain complexity justifies it. Simple CRUD does not need layering.

## Evidence

- Dallal & Morasca (2010) -- classes violating OCP/SRP had 2-3x higher defect counts
- Martin (2018) "Clean Architecture" -- DIP at every boundary prevents fragility
- Gamma et al. (1994) "Design Patterns" -- canonical pattern definitions
- Fowler (2002) "PoEAA" -- Repository warns against leaking query builders; layered architecture trade-offs
- Cockburn (2005) -- hexagonal architecture / ports and adapters
- Evans (2003) "DDD" -- domain isolation and corruption by infrastructure concerns
- Seemann (2011) "Dependency Injection in .NET" -- constructor injection as safest DI pattern
- PSR-11 (PHP-FIG, 2017) -- standard ContainerInterface
