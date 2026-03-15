---
name: laravel-features
description: "Use this skill when dispatching Laravel jobs, configuring queues or Horizon, writing event listeners, broadcasting with Reverb/Echo, writing feature tests with facade fakes, building Blade components, creating Livewire components with Alpine.js, or choosing ecosystem packages (Sanctum, Scout, Cashier, Pennant, Pulse). Covers job batching, factory patterns, wire:model, #[Computed], and package development."
---

# Laravel Features Skill

Covers Laravel queues/events, testing, Blade templating, Livewire, and ecosystem packages.
Target: Laravel 11.x, PHP 8.2+, Livewire 3.x.

---

## Queues & Jobs

### Job Design

Implement `ShouldQueue` with four traits: `Dispatchable`, `InteractsWithQueue`, `Queueable`, `SerializesModels`.

```php
final class ProcessOrder implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $maxExceptions = 2;
    public int $timeout = 60;

    public function __construct(private readonly int $orderId) {}

    public function handle(OrderService $service): void
    {
        $order = Order::findOrFail($this->orderId);
        $service->process($order);
    }

    public function backoff(): array { return [1, 5, 10]; }

    public function failed(\Throwable $e): void
    {
        Log::error('Order processing failed', ['order_id' => $this->orderId]);
    }
}
```

**Critical rules:**

- Store IDs in constructors, not Eloquent models (avoids bloated payloads, stale data)
- Make jobs idempotent — guard with state checks before performing actions
- Use `->afterCommit()` when dispatching inside database transactions
- Set `$timeout` < `retry_after` in queue config, or duplicate execution occurs
- SQS has 256 KB message limit — never store file contents in constructor

### Dispatch Patterns

```php
ProcessOrder::dispatch($id);                            // async
ProcessOrder::dispatchSync($id);                        // synchronous
ProcessOrder::dispatchAfterResponse($id);               // after HTTP response
ProcessOrder::dispatch($id)->delay(now()->addMinutes(5));
ProcessOrder::dispatch($id)->onQueue('orders')->onConnection('sqs');
ProcessOrder::dispatch($id)->afterCommit();              // safe in transactions
```

### Job Chaining & Batching

```php
// Chain: sequential, stops on failure
Bus::chain([new StepOne($id), new StepTwo($id)])->dispatch();

// Batch: parallel, with callbacks
Bus::batch([new ImportRow($slice1), new ImportRow($slice2)])
    ->then(fn (Batch $b) => ImportDone::dispatch($b->id))
    ->catch(fn (Batch $b, \Throwable $e) => Log::error('batch failed'))
    ->dispatch();
```

Batch jobs must `use Batchable` and check `$this->batch()->cancelled()`.

### Rate Limiting & Uniqueness

```php
// Prevent overlapping runs per resource
public function middleware(): array
{
    return [new WithoutOverlapping($this->orderId)];
}

// Rate limit against a named limiter
public function middleware(): array
{
    return [new RateLimited('payment-gateway')];
}

// Unique jobs (requires atomic cache driver)
final class ProcessOrder implements ShouldQueue, ShouldBeUnique
{
    public int $uniqueFor = 3600;
    public function uniqueId(): string { return (string) $this->orderId; }
}
```

### Horizon

Redis-only queue dashboard and auto-balancing supervisor. Protect `/horizon` with a `viewHorizon` gate.

```bash
composer require laravel/horizon && php artisan horizon:install
php artisan horizon  # production: supervise with Supervisor/systemd
```

---

## Events & Listeners

### Event Classes

Events are data carriers with no logic:

```php
final class OrderPlaced
{
    use Dispatchable, InteractsWithSockets, SerializesModels;
    public function __construct(public readonly Order $order) {}
}
```

### Listeners

Container-resolved; return `false` from `handle()` to stop propagation.

```php
final class ReserveInventory
{
    public function handle(OrderPlaced $event): void
    {
        $this->inventory->reserve($event->order);
    }
}
```

**Laravel 11 auto-discovery:** Any listener with a typed `handle()` parameter in `app/Listeners` is auto-registered. No
`$listen` array needed.

### Queued Listeners

Implement `ShouldQueue` on the listener class. Add `$queue`, `$delay`, `$tries`, `$timeout` properties. Use
`shouldQueue()` for conditional queueing.

### Model Observers

Centralize model event handling. Register via `Order::observe(OrderObserver::class)`.

> **Warning:** Observers do NOT fire on bulk operations (`Model::where()->delete()`).

### Testing Events

```php
Event::fake();
// ... trigger action ...
Event::assertDispatched(OrderPlaced::class, fn ($e) => $e->order->is($order));
Event::assertNotDispatched(OrderCancelled::class);
```

Scope fakes: `Event::fake([OrderPlaced::class])` — blanket fakes silence Eloquent model events.

---

## Broadcasting

### ShouldBroadcast

```php
final class OrderStatusUpdated implements ShouldBroadcast
{
    public function broadcastOn(): array { return [new PrivateChannel("orders.{$this->order->id}")]; }
    public function broadcastAs(): string { return 'order.updated'; }
    public function broadcastWith(): array { return ['status' => $this->order->status]; }
}
```

Channel types: `Channel` (public), `PrivateChannel` (auth required), `PresenceChannel` (auth + member tracking).

### Channel Authorization

```php
// routes/channels.php
Broadcast::channel('orders.{orderId}', fn (User $user, int $orderId): bool =>
    Order::find($orderId)?->user_id === $user->id
);
```

### Reverb (Self-Hosted WebSocket)

First-party WebSocket server. Uses Pusher wire protocol — switching between Reverb and Pusher requires only config
changes.

### Echo Client

```javascript
Echo.private(`orders.${orderId}`)
    .listen('.order.updated', (e) => updateStatus(e.status));
```

---

## Laravel Testing

### HTTP Testing

All methods return `TestResponse`. Use `RefreshDatabase` trait for isolation.

```php
$this->actingAs($user, 'sanctum')
    ->postJson('/api/posts', ['title' => 'Hello'])
    ->assertCreated()
    ->assertJsonPath('data.title', 'Hello')
    ->assertJsonStructure(['data' => ['id', 'title']]);

$this->assertDatabaseHas('posts', ['title' => 'Hello', 'user_id' => $user->id]);
```

### Key Response Assertions

| Method                  | Status |
|-------------------------|--------|
| `assertOk()`            | 200    |
| `assertCreated()`       | 201    |
| `assertNoContent()`     | 204    |
| `assertNotFound()`      | 404    |
| `assertForbidden()`     | 403    |
| `assertUnauthorized()`  | 401    |
| `assertUnprocessable()` | 422    |

JSON: `assertJson()` (partial), `assertExactJson()` (exact), `assertJsonStructure()`, `assertJsonPath()`,
`assertJsonValidationErrors()`.

View: `assertViewIs()`, `assertViewHas()`, `assertSee()`, `assertSeeInOrder()`.

### Facade Fakes

| Fake                   | Assert methods                                                     |
|------------------------|--------------------------------------------------------------------|
| `Bus::fake()`          | `assertDispatched`, `assertBatched`, `assertNotDispatched`         |
| `Mail::fake()`         | `assertSent`, `assertQueued`, `assertSentCount`                    |
| `Event::fake()`        | `assertDispatched`, `assertDispatchedTimes`, `assertNotDispatched` |
| `Queue::fake()`        | `assertPushed`, `assertPushedOn`, `assertCount`                    |
| `Notification::fake()` | `assertSentTo`, `assertNothingSent`                                |
| `Storage::fake()`      | `assertExists`, `assertMissing`                                    |
| `Http::fake()`         | `assertSent`, URL pattern matching, sequences                      |

**Warning:** `Event::fake()` without arguments silences ALL events including Eloquent model events. Use selective
faking: `Event::fake([SpecificEvent::class])`.

### Http::fake for Outbound Requests

```php
Http::fake([
    'api.example.com/*' => Http::response(['data' => 'value'], 200),
]);
// ... action ...
Http::assertSent(fn ($req) => str_contains($req->url(), 'api.example.com'));
```

### Time Travel

```php
$this->travel(61)->minutes();
$this->travelTo(now()->startOfDay());
$this->travelBack();
```

### Database Testing

**RefreshDatabase** (default): migrates once, wraps each test in transaction.
**DatabaseTransactions**: no migration overhead, assumes schema is current.

### Model Factories

```php
$user = User::factory()->admin()->create();
$user = User::factory()->has(Post::factory()->count(3))->create();
$post = Post::factory()->for($user)->create();
User::factory()->count(3)->sequence(
    ['role' => 'admin'], ['role' => 'editor'], ['role' => 'viewer']
)->create();
```

States, sequences, relationships (`has`, `for`, `hasAttached`), and callbacks (`afterCreating`).

### File Upload Testing

```php
Storage::fake('avatars');
$file = UploadedFile::fake()->image('avatar.jpg', 200, 200);
$this->post('/avatar', ['avatar' => $file])->assertOk();
Storage::disk('avatars')->assertExists('path/avatar.jpg');
```

---

## Blade Templates

### Component-First Architecture

Every reusable UI piece should be a component, not an `@include`.

**Anonymous components** (no PHP class): live in `resources/views/components/`.

```blade
@props(['type' => 'info', 'dismissible' => false])
<div {{ $attributes->merge(['class' => 'alert alert-' . $type]) }}>
    {{ $slot }}
</div>
```

**Class-based components**: use when PHP logic is needed (data fetching, formatting, DI). Class in
`app/View/Components/`.

### Props, Attributes, Slots

- `@props` declares accepted variables; undeclared values stay in `$attributes`
- `$attributes->merge()` is additive for `class`, override for other attributes
- Named slots: `<x-slot:header>`, check with `$header->isNotEmpty()`

### Layouts

**Component-based** (recommended): `<x-layouts.app>` with `{{ $slot }}`.
**Template inheritance** (legacy): `@extends` / `@section` / `@yield`.

### Asset Injection

`@push('scripts')` / `@stack('scripts')` — use `@once` to prevent duplicate script loading.

### Blade Security

- `{{ }}` auto-escapes via `htmlspecialchars()` — always use for untrusted data
- `{!! !!}` is raw output — only use with sanitized HTML (Markdown parser, HTMLPurifier output)
- `@js()` for safe JavaScript embedding — uses `JSON_HEX_*` flags
- `{{ }}` does NOT prevent `javascript:` URIs — validate URL schemes before rendering in `href`/`src`
- Never pass user input to `Blade::render()` first argument or `<x-dynamic-component :component="...">`

---

## Livewire

### Component Architecture

PHP class + Blade view. Single root element required. Auto-discovered in `app/Livewire/`.

**Lifecycle:** `boot()` → `mount()` → `render()` (initial); `boot()` → `hydrate()` → `updated{Prop}()` → `render()` →
`dehydrate()` (updates).

### Wire Directives

| Directive                        | Purpose                       |
|----------------------------------|-------------------------------|
| `wire:model`                     | Two-way bind on submit (lazy) |
| `wire:model.live`                | Bind on every input           |
| `wire:model.live.debounce.300ms` | Live with debounce            |
| `wire:model.blur`                | Sync on blur                  |
| `wire:click="method"`            | Call action on click          |
| `wire:submit="method"`           | Call on form submit           |
| `wire:loading`                   | Show while request in flight  |
| `wire:poll.5s`                   | Re-render every 5s            |
| `wire:navigate`                  | SPA-style navigation          |
| `wire:confirm="msg"`             | Prompt before action          |
| `wire:ignore`                    | Exclude from DOM morphing     |

### Forms & Validation

```php
#[Validate('required|string|min:3|max:255')]
public string $title = '';

public function save(): void
{
    $validated = $this->validate();
    Post::create($validated);
    $this->reset('title');
}
```

**Form Objects**: extract state to a `Livewire\Form` class for reuse. Bind with `wire:model="form.title"`.

### Computed Properties

`#[Computed]` — evaluated once per request, memoized. Access as `$this->posts` in Blade. Not serialized into snapshots.

### Lazy Loading

`#[Lazy]` skips initial server render, shows placeholder, loads via background request. Multiple lazy components load in
parallel.

### Performance Rules

- Store IDs in properties, compute full objects in `#[Computed]` methods
- Use `wire:model` (lazy) for forms, `wire:model.live.debounce` for search
- Paginate with `WithPagination` — never `Model::all()`
- Split large components into children — re-render scope is per-component
- Use `wire:key` on loop items for stable DOM morphing
- Eager load relationships to prevent N+1 queries

### Alpine.js Integration

Alpine ships with Livewire 3 — no separate install needed.

**Rule:** Keep state in Alpine when server doesn't need it. Use Livewire when PHP must act.

```blade
{{-- Alpine for UI toggle, Livewire for persistence --}}
<div x-data="{ open: $wire.entangle('showModal') }">
    <button @click="open = !open">Toggle</button>
    <div x-show="open">...</div>
</div>
```

`$wire` proxy: read/write properties, call actions (returns Promise), dispatch events.

### Volt (Single-File Components)

```php
<?php
use function Livewire\Volt\{state, computed, action};
state(['count' => 0]);
$increment = action(fn () => $this->count++);
?>
<div>
    <span>{{ $count }}</span>
    <button wire:click="increment">+</button>
</div>
```

### wire:navigate (SPA Mode)

Converts page navigation to fetch + DOM swap. Use `.hover` for prefetch. `#[Persist]` keeps components alive across
navigations.

### Security

- Snapshots are HMAC-signed — tampering causes `CorruptComponentPayloadException`
- Public properties are visible in snapshots — never store sensitive data
- `#[Locked]` prevents browser mutation of a public property
- Action arguments come from HTTP body — always validate and authorize inside actions

---

## Laravel Ecosystem Packages

### Decision Matrix

| Package            | Use When                               | Avoid When                       |
|--------------------|----------------------------------------|----------------------------------|
| **Sanctum**        | SPA/mobile API auth                    | Need OAuth server (use Passport) |
| **Passport**       | Full OAuth2 server                     | Only SPA auth (Sanctum simpler)  |
| **Horizon**        | Redis queue monitoring                 | Non-Redis drivers                |
| **Telescope**      | Dev/staging debug                      | Unguarded production             |
| **Scout**          | Full-text search (Algolia/Meilisearch) | Simple LIKE queries              |
| **Cashier Stripe** | Stripe billing                         | Non-Stripe processors            |
| **Socialite**      | OAuth social login                     | SAML SSO                         |
| **Fortify**        | Headless auth backend                  | Want pre-built views             |
| **Breeze**         | Minimal auth starter                   | Complex auth flows               |
| **Jetstream**      | Auth + teams + API tokens              | Simple apps                      |
| **Pennant**        | Feature flags, A/B tests               | Simple env booleans              |
| **Reverb**         | Self-hosted WebSockets                 | Pusher preferred                 |
| **Pulse**          | Performance monitoring                 | Full APM in place                |
| **Pint**           | Code style (PHP-CS-Fixer wrapper)      | Existing ECS config              |

### Building Laravel Packages

Structure: `src/` (provider, facades, contracts), `config/`, `database/migrations/`, `resources/views/`.

**Key rules:**

- Always `mergeConfigFrom()` in `register()` for defaults
- Use `loadMigrationsFrom()` for automatic migration discovery
- Register publishables only inside `runningInConsole()`
- Bind to contracts/interfaces, not concrete classes
- Add `extra.laravel.providers` to `composer.json` for auto-discovery
- Test with Orchestra Testbench (`orchestra/testbench`)

See references/ for detailed API coverage.
