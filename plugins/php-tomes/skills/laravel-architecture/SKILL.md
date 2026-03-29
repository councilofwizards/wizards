---
name: laravel-architecture
description:
  "Use this skill when binding services in Laravel's container, writing service providers, choosing facades vs injected
  contracts, defining Eloquent models/relationships/scopes, preventing N+1 queries, designing routes and controllers,
  writing Form Requests, configuring middleware, or setting up authentication (Sanctum/Passport) and authorization
  (gates/policies). Covers mass assignment, query optimization, and security hardening."
---

# Laravel Architecture Skill

Comprehensive guide for building well-architected Laravel 11.x applications covering the service container, Eloquent
ORM, routing/controllers, and security (authentication + authorization).

## References

- [service-container.md](references/service-container.md) — IoC container, providers, facades, request lifecycle,
  configuration
- [eloquent.md](references/eloquent.md) — Models, relationships, query patterns, performance, architecture
- [routing-controllers.md](references/routing-controllers.md) — Routes, controllers, middleware, Form Requests, API
  Resources
- [security.md](references/security.md) — Sanctum, Passport, gates, policies, security hardening

---

## Service Container & IoC

### Binding Types

| Method                     | Lifecycle                     | When to use                            |
| -------------------------- | ----------------------------- | -------------------------------------- |
| `bind()`                   | New instance per resolution   | Stateful, request-scoped objects       |
| `singleton()`              | One per container             | Stateless services, connections        |
| `scoped()`                 | One per request (Octane-safe) | Request-stateful services under Octane |
| `instance()`               | Pre-built object              | Externally constructed instances       |
| `bindIf()`/`singletonIf()` | Conditional                   | Package providers (allow app override) |

**Prefer `scoped()` over `singleton()` for request-stateful services when running Octane.**

### Auto-Wiring

The container reads constructor type hints via reflection. No explicit binding needed for concrete classes with
resolvable parameters:

```php
final class OrderService
{
    public function __construct(
        private readonly PaymentGateway $gateway,   // resolved via binding
        private readonly OrderRepository $orders,    // auto-wired concrete
    ) {}
}
```

### Contextual Binding

Inject different implementations per consumer:

```php
$this->app->when(ReportMailer::class)
    ->needs(Mailer::class)
    ->give(SmtpMailer::class);
```

### Anti-Patterns

- **Service locator in domain code**: `app()` / `resolve()` outside ServiceProviders hides dependencies. Inject via
  constructor.
- **Binding concretes instead of interfaces**: Couples consumers to implementations.
- **Resolving in `register()`**: Other providers may not exist yet. Defer resolution inside closures.

---

## Service Providers

### `register()` vs `boot()` Lifecycle

```
register() on ALL providers → bind into container only
boot() on ALL providers     → safe to resolve services, register listeners, routes
```

- `register()`: container bindings, `mergeConfigFrom()` only.
- `boot()`: event listeners, view composers, route registration, policy mappings, `extend()`.
- **Never call `make()` inside `register()`** — bindings from other providers may not exist.

### Deferred Providers

Implement `DeferrableProvider` + `provides()` to load only when a binding is requested. Run `php artisan optimize:clear`
after changes.

### Property Bindings

```php
public array $bindings = [OrderRepository::class => EloquentOrderRepository::class];
public array $singletons = [PaymentGateway::class => StripeGateway::class];
```

---

## Facades & Contracts

Facades proxy static calls to container-resolved instances via `__callStatic`.

**When to use facades**: Routes, controllers, Artisan commands where Laravel context is explicit. **When to inject
contracts**: Domain/application layer, testable classes, framework-agnostic packages.

### Testing

- `Facade::fake()` swaps implementation with a test double.
- `shouldReceive()` for Mockery-based expectations.
- Constructor-injected mocks need no container at all.

### Anti-Pattern

Never use facades in domain classes. Inject the contract instead to keep domain code framework-independent.

---

## Configuration & Environment

**Critical Rule**: `env()` is only valid inside `config/*.php` files. Never call `env()` in application code — it
returns `null` after `config:cache`.

```php
// WRONG
$key = env('STRIPE_SECRET');

// CORRECT
$key = config('services.stripe.secret');
```

**Production**: Always run `php artisan config:cache` (10-30% bootstrap reduction). Cast booleans explicitly:
`(bool) env('APP_DEBUG', false)`.

---

## Eloquent Models

### Mass Assignment

Always use `$fillable` (explicit allowlist). Never use `$guarded = []` in production. Always pass
`$request->validated()`, never `$request->all()`.

### Type Casting

Define `$casts` for all non-string columns: `'boolean'`, `'array'`, `'datetime'`, `'encrypted'`, enum classes, custom
`CastsAttributes`.

### Accessors/Mutators (PHP 8+)

```php
protected function fullName(): Attribute
{
    return Attribute::make(
        get: fn () => "{$this->first_name} {$this->last_name}",
    );
}
```

### Model Events

Events (`creating`, `created`, `updating`, etc.) fire on single-model operations only. Bulk operations (
`where()->delete()`) skip events. Use observers for cross-cutting concerns, not business logic.

---

## Eloquent Relationships

### Quick Reference

| Method                 | Returns          | FK location             |
| ---------------------- | ---------------- | ----------------------- |
| `hasOne`               | single model     | child table             |
| `hasMany`              | Collection       | child table             |
| `belongsTo`            | single model     | this table              |
| `belongsToMany`        | Collection       | pivot table             |
| `hasManyThrough`       | Collection       | intermediate table      |
| `morphOne`/`morphMany` | model/Collection | child (`*_type`/`*_id`) |
| `morphToMany`          | Collection       | polymorphic pivot       |

### Eager Loading (Prevent N+1)

```php
// Enable in development
Model::preventLazyLoading(! app()->isProduction());

// Eager load
Post::with(['author', 'comments'])->get();
Post::with('comments.author')->get();

// Count without loading
Post::withCount('comments')->get();

// Constrained eager load
Post::with(['comments' => fn ($q) => $q->where('approved', true)])->get();
```

### Morph Map

Always register a morph map to decouple class names from the database:

```php
Relation::morphMap(['post' => Post::class, 'user' => User::class]);
```

---

## Eloquent Performance

### Top 3 Issues

1. **N+1 queries**: Enable `preventLazyLoading()`. Always `with()` relationships used in loops.
2. **Hydration waste**: Use `count()`, `exists()`, `pluck()`, `value()` instead of hydrating full models for scalar
   needs.
3. **Memory on large datasets**: Use `chunkById()` (mutation-safe), `lazy()` (pipeline), or `cursor()` (minimum memory).

### Chunking Decision Table

| Need                                       | Method        |
| ------------------------------------------ | ------------- |
| Bulk job dispatch, writes during iteration | `chunkById()` |
| Read-only, stable order                    | `chunk()`     |
| Pipeline/filter/map                        | `lazy()`      |
| Minimum memory, simple iteration           | `cursor()`    |

### Query Builder vs Eloquent

Use `DB::table()` for: bulk inserts (10k+ rows), complex reporting joins, cross-table analytics. Use Eloquent for: CRUD,
relationships, model events/casts.

---

## Eloquent Architecture

### Fat Model Anti-Pattern

Signs: methods >15 lines, model imports Request, business rules mixed with persistence, notifications/jobs dispatched
inside model.

### Action Classes (Preferred Pattern)

```php
final class CompleteOrder
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly Dispatcher $events,
    ) {}

    public function execute(Order $order): Order
    {
        $order->update(['status' => 'completed', 'completed_at' => now()]);
        $this->events->dispatch(new OrderCompleted($order));
        return $order->fresh();
    }
}
```

Models own data (relationships, casts, scopes). Actions own behavior. Repositories add value only when you need
persistence abstraction.

---

## Routing

### Conventions

- **Every route must have a name**: `->name('users.show')`. Use `route()` helper, never hardcode URLs.
- **Use `Route::resource` / `apiResource`**: Generates all RESTful routes consistently.
- **No closure routes in web/api**: Prevents `route:cache`. Use invokable controllers.
- **Route model binding**: Implicit (`Order $order`), by column (`{post:slug}`), or explicit via `Route::bind()`.

### Route Groups

```php
Route::prefix('api/v1')->name('api.v1.')
    ->middleware(['auth:sanctum', 'throttle:api'])
    ->group(function () {
        Route::apiResource('users', UserController::class);
    });
```

---

## Controllers

### Thin Controller Principle

Controllers do four things: (1) extract request data, (2) call service/action, (3) handle exceptions, (4) return
response. Business logic belongs in services/actions.

### Form Requests

Encapsulate validation + authorization per request type. Always use `$request->validated()`, never `$request->all()`.

### API Resources

Transform models to JSON, decoupling DB schema from API contract. Use `whenLoaded()` for conditional relationships.

### Invokable Controllers

Single `__invoke()` method for non-resource actions (login, import, report generation). Required for cacheable non-CRUD
routes.

---

## Middleware

### Registration (Laravel 11)

All middleware configured in `bootstrap/app.php` — no more `Kernel.php`:

```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->append(SetLocale::class);           // global
    $middleware->alias(['team' => EnsureTeam::class]); // route-level
    $middleware->appendToGroup('api', [ForceJson::class]); // group
})
```

### Before vs After

Position of `$next($request)` determines timing. Response path unwinds LIFO.

### Terminable Middleware

`terminate()` runs after response is sent. Use for metrics, log flushing, lock release. Never throw exceptions in
`terminate()`.

### Anti-Pattern

Never put business logic in middleware. Use services or policies instead.

---

## Authentication

### Sanctum (Recommended for Most Apps)

**SPA mode**: Cookie-based sessions + CSRF via double-submit cookie. SPA must call `GET /sanctum/csrf-cookie` first.

**Token mode**: Opaque tokens with abilities and expiration. Tokens hashed with SHA-256 before storage.

```php
$token = $user->createToken('mobile', ['read:posts'], now()->addYear());
```

### Passport (OAuth2 Server)

Use only when issuing tokens to third-party applications. Authorization Code + PKCE for SPAs/mobile. Client Credentials
for machine-to-machine. Avoid Password Grant (deprecated in OAuth 2.1).

### Session vs Token Auth

| Dimension    | Session (Cookie)           | Token (Bearer)       |
| ------------ | -------------------------- | -------------------- |
| CSRF         | Yes (mitigated by Sanctum) | No                   |
| XSS          | Cookie HttpOnly (safe)     | localStorage exposed |
| Revocation   | Immediate                  | Requires DB lookup   |
| Cross-domain | Requires SameSite=None     | Works natively       |

---

## Authorization

### Gates

Closure-based checks for actions not tied to a model. Register in `AppServiceProvider::boot()`.

```php
Gate::define('publish-post', fn (User $user) => $user->role === 'editor');
Gate::authorize('publish-post'); // throws 403 on failure
```

`Gate::before()` for super-admin bypass — use narrowly, returns `true` bypasses ALL checks.

### Policies

Group authorization per model. Auto-discovered at `App\Policies\{Model}Policy`.

```php
$this->authorize('update', $post);          // in controller
$this->authorizeResource(Post::class);      // maps all 7 resource methods
```

Return `Response::deny('message', 403)` for human-readable API error messages.

### Blade Directives

`@can('update', $post)` hides UI only — always enforce authorization in the controller.

---

## Security Hardening

### Critical Rules

1. **Mass assignment**: Use `$fillable`, never `$guarded = []`. Pass `$request->validated()`.
2. **SQL injection**: Use bindings in `whereRaw()`/`orderByRaw()`. Whitelist column names for dynamic ordering.
3. **XSS**: Use `{{ }}` (escaped) for user content. `{!! !!}` only for trusted, sanitized HTML.
4. **CSRF in SPAs**: Use `$middleware->statefulApi()` with Sanctum. Never exclude API routes from CSRF globally.
5. **APP_DEBUG**: Must be `false` in production. Default: `(bool) env('APP_DEBUG', false)`.
6. **Rate limiting**: Define named limiters for login, API endpoints. Key by user ID or IP.

### Signed URLs

HMAC-SHA256 tamper-proof links for email verification, downloads, unsubscribe:

```php
$url = URL::temporarySignedRoute('download', now()->addMinutes(30), ['file' => $id]);
Route::get('/download/{file}', Controller::class)->middleware('signed');
```

### Encryption

`Crypt` facade uses AES-256-CBC + HMAC. Model cast `'encrypted'` for transparent column encryption.

---

## Request Lifecycle

```
HTTP Request → public/index.php → Bootstrap (env, config, providers)
→ register() ALL providers → boot() ALL providers
→ Global Middleware → Router::dispatch() → Route Middleware
→ Controller (DI resolved) → Response
→ Route Middleware (LIFO) → Global Middleware (LIFO)
→ Response sent → Terminable Middleware
```

Key points:

- `bootstrap/app.php` configures middleware, routing, exceptions (Laravel 11)
- Middleware pipeline is nested closures (Chain of Responsibility)
- `SubstituteBindings` resolves route model bindings before controller
- `terminate()` runs after response is sent
