# Routing, Controllers & Middleware Reference

## Table of Contents

- [Route Naming & Resources](#route-naming--resources)
- [Route Model Binding](#route-model-binding)
- [Route Groups & Rate Limiting](#route-groups--rate-limiting)
- [Route Caching](#route-caching)
- [Controller Design](#controller-design)
- [Form Requests](#form-requests)
- [API Resources](#api-resources)
- [Middleware](#middleware)
- [Anti-Patterns](#anti-patterns)

---

## Route Naming & Resources

Every production route must have a name:

```php
Route::get('/users/{user}', [UserController::class, 'show'])->name('users.show');

// Generate URL
$url = route('users.show', $user);
```

### Resource Routes

```php
Route::apiResource('users', UserController::class);
// Generates: index, store, show, update, destroy

Route::resource('posts', PostController::class);
// Generates: index, create, store, show, edit, update, destroy

// Restrict
Route::resource('posts', PostController::class)->only(['index', 'show']);
```

| HTTP Verb | URI                    | Method    | Route Name       |
| --------- | ---------------------- | --------- | ---------------- |
| GET       | `/photos`              | `index`   | `photos.index`   |
| GET       | `/photos/create`       | `create`  | `photos.create`  |
| POST      | `/photos`              | `store`   | `photos.store`   |
| GET       | `/photos/{photo}`      | `show`    | `photos.show`    |
| GET       | `/photos/{photo}/edit` | `edit`    | `photos.edit`    |
| PUT/PATCH | `/photos/{photo}`      | `update`  | `photos.update`  |
| DELETE    | `/photos/{photo}`      | `destroy` | `photos.destroy` |

---

## Route Model Binding

### Implicit Binding

```php
Route::get('/orders/{order}', [OrderController::class, 'show']);

public function show(Order $order): JsonResponse
{
    // $order resolved via findOrFail — 404 if not found
}
```

### By Column

```php
Route::get('/posts/{post:slug}', [PostController::class, 'show']);
```

### Explicit Binding

```php
// In AppServiceProvider::boot()
Route::bind('order', fn (string $value) =>
    Order::where('uuid', $value)->firstOrFail()
);
```

### Custom Resolution on Model

```php
public function resolveRouteBinding(mixed $value, ?string $field = null): ?Model
{
    return $this->where($field ?? 'id', $value)
        ->where('tenant_id', auth()->user()->tenant_id)
        ->firstOrFail();
}
```

---

## Route Groups & Rate Limiting

```php
Route::prefix('api/v1')
    ->name('api.v1.')
    ->middleware(['auth:sanctum', 'throttle:api'])
    ->group(function () {
        Route::apiResource('users', UserController::class);
    });
```

### Named Rate Limiters

```php
// In AppServiceProvider::boot()
RateLimiter::for('api', function (Request $request) {
    return $request->user()
        ? Limit::perMinute(120)->by($request->user()->id)
        : Limit::perMinute(10)->by($request->ip());
});
```

### Subdomain Routing

```php
Route::domain('{account}.example.com')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'show']);
});
```

### Fallback Routes

```php
Route::fallback(fn () => response()->json(['message' => 'Not found.'], 404));
```

---

## Route Caching

```bash
php artisan route:cache   # serialize route collection (production)
php artisan route:clear   # remove cache
```

Requirements: no closure routes. Use invokable controllers instead:

```php
// WRONG — prevents route:cache
Route::get('/ping', fn () => response()->json(['ok' => true]));

// CORRECT
Route::get('/ping', PingController::class)->name('ping');
```

---

## Controller Design

### Thin Controller Principle

Controllers: (1) extract request data, (2) call service/action, (3) handle exceptions, (4) return response.

```php
final class OrderController extends Controller
{
    public function __construct(private readonly OrderService $orders) {}

    public function store(StoreOrderRequest $request): JsonResponse
    {
        $order = $this->orders->place(
            customer: $request->user(),
            items: $request->validated('items'),
        );
        return (new OrderResource($order))->response()->setStatusCode(201);
    }
}
```

### Invokable (Single-Action) Controllers

```php
final class LoginController extends Controller
{
    public function __invoke(LoginRequest $request): RedirectResponse
    {
        $this->auth->authenticate($request->validated());
        return redirect()->intended(route('dashboard'));
    }
}

Route::post('/login', LoginController::class)->name('login');
```

Use for: non-resource actions (login, import, report), complex operations deserving their own class.

---

## Form Requests

```php
final class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create-orders');
    }

    public function rules(): array
    {
        return [
            'items'              => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', Rule::exists('products', 'id')],
            'items.*.quantity'   => ['required', 'integer', 'min:1', 'max:100'],
        ];
    }
}
```

Rules:

- `authorize()` returns `false` -> 403. Never throw here.
- Use `$request->validated()` in controllers, never `$request->all()`.
- For updates: `Rule::unique()->ignore($this->route('model'))`.
- Form Requests support constructor injection.

---

## API Resources

```php
final class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'         => $this->id,
            'status'     => $this->status->value,
            'total'      => $this->total_cents / 100,
            'items'      => OrderItemResource::collection($this->whenLoaded('items')),
            'created_at' => $this->created_at->toIso8601String(),
            'links'      => ['self' => route('orders.show', $this)],
        ];
    }
}
```

Use `whenLoaded()` for relations. Use semantic field names, not raw columns.

---

## Middleware

### Registration (Laravel 11)

```php
// bootstrap/app.php
->withMiddleware(function (Middleware $middleware) {
    // Global
    $middleware->append(SetLocale::class);
    $middleware->prepend(TrustProxies::class);

    // Aliases (route-level)
    $middleware->alias([
        'team.access'  => EnsureTeamAccess::class,
        'subscription' => RequireSubscription::class,
    ]);

    // Groups
    $middleware->appendToGroup('api', [ForceJsonResponse::class]);
})
```

### Before vs After

```php
// Before — logic runs before controller
public function handle(Request $request, Closure $next): Response
{
    $this->validateApiVersion($request);
    return $next($request);
}

// After — logic runs after controller
public function handle(Request $request, Closure $next): Response
{
    $response = $next($request);
    $response->headers->set('X-Frame-Options', 'DENY');
    return $response;
}
```

### Terminable Middleware

```php
public function terminate(Request $request, Response $response): void
{
    // Runs AFTER response sent. Do not throw exceptions here.
    app(MetricsService::class)->record($request, $response);
}
```

### Middleware Parameters

```php
Route::middleware('role:admin,editor')->group(fn () => ...);

public function handle(Request $request, Closure $next, string ...$roles): Response
{
    if (! $request->user()?->hasAnyRole($roles)) { abort(403); }
    return $next($request);
}
```

### Middleware Priority

`$middleware->priority([...])` enforces ordering. Default: `SubstituteBindings` before `Authorize`.

---

## Anti-Patterns

| Anti-Pattern                         | Fix                                 |
| ------------------------------------ | ----------------------------------- |
| Unnamed routes                       | Always `->name()`                   |
| Closure routes in web/api            | Invokable controllers               |
| Hardcoded URLs                       | Use `route()` helper                |
| Business logic in controller         | Extract to service/action           |
| `$request->all()`                    | Use `$request->validated()`         |
| `$request->validate()` in controller | Use Form Request                    |
| Raw arrays from controller           | Use API Resources                   |
| Business logic in middleware         | Move to service or policy           |
| DB queries in every middleware       | Cache lookups                       |
| Modifying request data in middleware | Modify in Form Requests/controllers |
| `app/Http/Kernel.php` (Laravel 11)   | Use `bootstrap/app.php`             |
