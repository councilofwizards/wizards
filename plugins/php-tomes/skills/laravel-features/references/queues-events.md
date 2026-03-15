# Queues, Events & Broadcasting Reference

## Table of Contents

- [Job Configuration Properties](#job-configuration-properties)
- [Dispatch Methods](#dispatch-methods)
- [Job Middleware](#job-middleware)
- [Queue CLI Commands](#queue-cli-commands)
- [Event Registration](#event-registration)
- [Model Events](#model-events)
- [Broadcasting Channels](#broadcasting-channels)
- [Echo Client API](#echo-client-api)
- [Anti-Patterns](#anti-patterns)

---

## Job Configuration Properties

| Property                   | Type      | Description                                   |
|----------------------------|-----------|-----------------------------------------------|
| `$tries`                   | int       | Max retry attempts                            |
| `$maxExceptions`           | int       | Max exceptions before marking failed          |
| `$timeout`                 | int       | Seconds before job is killed (requires pcntl) |
| `$uniqueFor`               | int       | Lock TTL for `ShouldBeUnique` (seconds)       |
| `$backoff`                 | int/array | Seconds between retries                       |
| `$queue`                   | string    | Named queue                                   |
| `$connection`              | string    | Queue connection name                         |
| `$deleteWhenMissingModels` | bool      | Skip instead of fail when model not found     |

Methods: `backoff(): array`, `retryUntil(): DateTime`, `failed(Throwable)`, `uniqueId(): string`, `middleware(): array`.

## Dispatch Methods

```php
Job::dispatch($args);                    // async (default)
Job::dispatchSync($args);               // immediate, current process
Job::dispatchAfterResponse($args);      // after HTTP response
Job::dispatchIf($condition, $args);     // conditional
Job::dispatch($args)->delay(now()->addMinutes(5));
Job::dispatch($args)->onQueue('high')->onConnection('redis');
Job::dispatch($args)->afterCommit();    // wait for DB transaction commit
```

### Chaining

```php
Bus::chain([new A(), new B(), new C()])->dispatch();
Bus::chain([...])->onQueue('processing')->dispatch();
```

### Batching

```php
Bus::batch([new A(), new B()])
    ->name('import')
    ->then(fn (Batch $b) => ...)
    ->catch(fn (Batch $b, Throwable $e) => ...)
    ->finally(fn (Batch $b) => ...)
    ->allowFailures()
    ->dispatch();
```

Requires `job_batches` table. Jobs must `use Batchable`.

## Job Middleware

| Middleware                            | Purpose                              |
|---------------------------------------|--------------------------------------|
| `WithoutOverlapping($key)`            | Prevent concurrent runs per resource |
| `RateLimited($limiterName)`           | Integrate with named RateLimiter     |
| `ThrottlesExceptions($max, $minutes)` | Back off after N exceptions          |
| `Skip::when($condition)`              | Skip job execution conditionally     |

## Queue CLI Commands

```bash
php artisan queue:work redis --queue=high,default --tries=3 --timeout=60
php artisan queue:work --once          # single job then exit
php artisan queue:listen               # dev only — reloads per job
php artisan queue:retry all            # retry all failed jobs
php artisan queue:retry {id}           # retry specific failed job
php artisan queue:failed               # list failed jobs
php artisan queue:flush                # delete all failed jobs
php artisan queue:clear redis --queue=default  # purge pending jobs
php artisan queue:monitor redis:default --max=100  # alert if queue exceeds threshold
```

## Event Registration

### Auto-Discovery (Laravel 11 default)

Any listener with a typed `handle()` in `app/Listeners` is auto-registered.

### Manual Registration

```php
// AppServiceProvider::boot()
Event::listen(OrderPlaced::class, ReserveInventory::class);
Event::listen('order.*', LogOrderEvent::class);  // wildcard
Event::subscribe(OrderAuditSubscriber::class);   // subscriber class
```

### Dispatching

```php
OrderPlaced::dispatch($order);
Event::dispatch(new OrderPlaced($order));
event(new OrderPlaced($order));
OrderPlaced::dispatchIf($order->isNew(), $order);
```

### Event Subscriber

```php
final class OrderAuditSubscriber
{
    public function subscribe(Dispatcher $events): void
    {
        $events->listen(OrderPlaced::class, [self::class, 'onPlaced']);
        $events->listen(OrderCancelled::class, [self::class, 'onCancelled']);
    }
}
```

## Model Events

Lifecycle: `creating`, `created`, `updating`, `updated`, `saving`, `saved`, `deleting`, `deleted`, `restoring`,
`restored`, `replicating`, `retrieved`.

```php
// Observer
Order::observe(OrderObserver::class);

// Inline in model
protected static function booted(): void
{
    static::creating(fn (Order $o) => $o->uuid = Str::uuid());
}
```

> Observers do NOT fire on bulk operations.

## Broadcasting Channels

| Type     | Class                     | Auth Required               |
|----------|---------------------------|-----------------------------|
| Public   | `Channel('name')`         | No                          |
| Private  | `PrivateChannel('name')`  | Yes (return bool)           |
| Presence | `PresenceChannel('name')` | Yes (return array or false) |

### Channel Authorization (routes/channels.php)

```php
Broadcast::channel('orders.{orderId}', fn (User $user, int $id): bool =>
    Order::find($id)?->user_id === $user->id
);

Broadcast::channel('chat.{roomId}', fn (User $user, int $id): array|false =>
    $user->canJoin($id) ? ['id' => $user->id, 'name' => $user->name] : false
);
```

### ShouldBroadcast vs ShouldBroadcastNow

- `ShouldBroadcast`: queued (default, recommended for high traffic)
- `ShouldBroadcastNow`: synchronous (low-volume, latency-sensitive)

### Model Broadcasting

```php
class Order extends Model
{
    use BroadcastsEvents;
    public function broadcastOn(string $event): array
    {
        return [new PrivateChannel("orders.{$this->id}")];
    }
}
```

## Echo Client API

```javascript
// Public
Echo.channel('announcements').listen('EventName', (e) => {});

// Private
Echo.private(`orders.${id}`).listen('.custom.name', (e) => {});

// Presence
Echo.join(`chat.${id}`)
    .here((members) => {})
    .joining((m) => {})
    .leaving((m) => {})
    .listen('MessageSent', (e) => {});

// Notifications
Echo.private(`App.Models.User.${userId}`)
    .notification((n) => {});
```

Note: leading dot (`.custom.name`) for custom `broadcastAs()` names.

## Anti-Patterns

- **Dispatching inside DB transaction** without `->afterCommit()` — race condition
- **Serializing Eloquent models** in job constructor — store IDs, load in `handle()`
- **Non-idempotent jobs** — guard with state checks
- **Oversized payloads** — SQS 256KB limit; pass references, not data
- **Blanket `Event::fake()`** — silences model observers, corrupts test state
