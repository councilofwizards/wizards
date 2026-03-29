# Service Container, Providers, Facades & Configuration Reference

## Table of Contents

- [Container Binding Methods](#container-binding-methods)
- [Resolution Methods](#resolution-methods)
- [Contextual & Tagged Bindings](#contextual--tagged-bindings)
- [Service Provider API](#service-provider-api)
- [Deferred Providers](#deferred-providers)
- [Facade Mechanics](#facade-mechanics)
- [Facade-to-Contract Mapping](#facade-to-contract-mapping)
- [Configuration & Environment](#configuration--environment)
- [Request Lifecycle](#request-lifecycle)
- [Anti-Patterns](#anti-patterns)

---

## Container Binding Methods

```php
// New instance per resolution
$this->app->bind(PaymentGateway::class, StripeGateway::class);

// Singleton — one instance per container (per request in PHP-FPM)
$this->app->singleton(PaymentGateway::class, StripeGateway::class);

// Scoped — one per request, flushed between requests under Octane
$this->app->scoped(PaymentGateway::class, StripeGateway::class);

// Pre-constructed object
$this->app->instance(PaymentGateway::class, $gateway);

// Conditional — only bind if nothing registered
$this->app->bindIf(PaymentGateway::class, StripeGateway::class);
$this->app->singletonIf(PaymentGateway::class, StripeGateway::class);
```

### Factory Closures

```php
$this->app->singleton(PaymentGateway::class, static function ($app): PaymentGateway {
    return match ($app['config']['services.payment.driver']) {
        'stripe' => new StripeGateway($app['config']['services.stripe.key']),
        'braintree' => new BraintreeGateway($app['config']['services.bt.key']),
    };
});
```

### Extending Bindings (Decorator Pattern)

```php
// In boot() — base binding must exist
$this->app->extend(PaymentGateway::class, function (PaymentGateway $gw, $app) {
    return new LoggingPaymentGateway($gw, $app->make(Logger::class));
});
```

---

## Resolution Methods

```php
$gateway = app(PaymentGateway::class);
$gateway = $this->app->make(PaymentGateway::class);
$gateway = $this->app->makeWith(StripeGateway::class, ['apiKey' => 'override']);
```

Auto-wiring resolves concrete classes via reflection — no binding needed if all
constructor params are type-hinted or have defaults.

---

## Contextual & Tagged Bindings

```php
// Different implementation per consumer
$this->app->when(ReportMailer::class)->needs(Mailer::class)->give(SmtpMailer::class);
$this->app->when(PasswordReset::class)->needs(Mailer::class)->give(QueuedMailer::class);

// Scalar parameter injection
$this->app->when(ReportGenerator::class)->needs('$reportTitle')->give('Monthly Revenue');

// Tagged bindings — group and resolve all
$this->app->tag([CsvExporter::class, PdfExporter::class], 'exporters');
$exporters = $this->app->tagged('exporters');

// Inject tagged group
$this->app->when(ExportManager::class)->needs('$exporters')->giveTagged('exporters');
```

---

## Service Provider API

### Lifecycle

```
register() called on ALL providers (in order) → bind only
boot() called on ALL providers (in order)     → resolve, configure, register listeners
```

### Method Reference

| Method                         | Phase    | Purpose                                     |
| ------------------------------ | -------- | ------------------------------------------- |
| `register()`                   | Register | Bind into container, `mergeConfigFrom`      |
| `boot()`                       | Boot     | Routes, events, views, policies, `extend()` |
| `mergeConfigFrom($path, $key)` | Register | Merge package defaults                      |
| `loadMigrationsFrom($path)`    | Boot     | Auto-load migrations                        |
| `loadViewsFrom($path, $ns)`    | Boot     | Register view namespace                     |
| `loadRoutesFrom($path)`        | Boot     | Include route file                          |
| `publishes($paths, $group)`    | Boot     | Define publishable assets                   |
| `provides()`                   | —        | Required by `DeferrableProvider`            |

### Property Bindings

```php
public array $bindings = [OrderRepository::class => EloquentOrderRepository::class];
public array $singletons = [PaymentGateway::class => StripeGateway::class];
```

### Registration (Laravel 11)

```php
// bootstrap/providers.php
return [
    App\Providers\AppServiceProvider::class,
    App\Providers\PaymentServiceProvider::class,
];
```

---

## Deferred Providers

```php
class PdfServiceProvider extends ServiceProvider implements DeferrableProvider
{
    public function register(): void
    {
        $this->app->singleton(PdfRenderer::class, ChromiumPdfRenderer::class);
    }

    public function provides(): array
    {
        return [PdfRenderer::class];
    }
}
```

Run `php artisan optimize:clear` after adding/removing deferred providers.

---

## Facade Mechanics

Facades extend `Illuminate\Support\Facades\Facade`, implement
`getFacadeAccessor()` returning a container key. `__callStatic` resolves the
instance and forwards the call.

```php
// These are equivalent:
Cache::get('key');
app('cache')->get('key');
app(\Illuminate\Contracts\Cache\Factory::class)->get('key');
```

### Real-Time Facades

Prefix any class namespace with `Facades\`:

```php
use Facades\App\Services\OrderPricer;
$price = OrderPricer::calculate($order);
```

### Testing Facades

```php
Mail::fake();
Mail::assertSent(WelcomeEmail::class);

Cache::shouldReceive('get')->once()->with('key')->andReturn('value');
```

---

## Facade-to-Contract Mapping

| Facade      | Contract                                  |
| ----------- | ----------------------------------------- |
| `Auth`      | `Illuminate\Contracts\Auth\Factory`       |
| `Cache`     | `Illuminate\Contracts\Cache\Factory`      |
| `Config`    | `Illuminate\Contracts\Config\Repository`  |
| `DB`        | `Illuminate\Database\DatabaseManager`     |
| `Event`     | `Illuminate\Contracts\Events\Dispatcher`  |
| `Gate`      | `Illuminate\Contracts\Auth\Access\Gate`   |
| `Hash`      | `Illuminate\Contracts\Hashing\Hasher`     |
| `Log`       | `Illuminate\Contracts\Logging\Log`        |
| `Mail`      | `Illuminate\Contracts\Mail\Factory`       |
| `Queue`     | `Illuminate\Contracts\Queue\Factory`      |
| `Route`     | `Illuminate\Contracts\Routing\Registrar`  |
| `Storage`   | `Illuminate\Contracts\Filesystem\Factory` |
| `Validator` | `Illuminate\Contracts\Validation\Factory` |
| `View`      | `Illuminate\Contracts\View\Factory`       |

---

## Configuration & Environment

### env() Rule

`env()` is valid ONLY inside `config/*.php`. After `config:cache`, `env()`
returns `null` elsewhere.

```php
// config/services.php
'stripe' => ['secret' => env('STRIPE_SECRET')];

// Application code — always use config()
$secret = config('services.stripe.secret');
```

### Config Caching

```bash
php artisan config:cache   # compile to bootstrap/cache/config.php
php artisan config:clear   # remove cache
php artisan optimize       # cache config + routes + events
```

### Boolean Casting

```php
'debug' => (bool) env('APP_DEBUG', false),
'feature' => filter_var(env('FEATURE_FLAG', false), FILTER_VALIDATE_BOOLEAN),
```

### .env Files

```
.env           # local development
.env.testing   # APP_ENV=testing (Pest/PHPUnit)
.env.example   # committed, documents required vars
```

---

## Request Lifecycle

```
public/index.php → autoload → Application (bootstrap/app.php)
→ LoadEnvironmentVariables → LoadConfiguration → HandleExceptions
→ RegisterFacades → RegisterProviders (register()) → BootProviders (boot())
→ Global Middleware Pipeline → Router::dispatch()
→ Route Middleware → Controller (DI resolved) → Response
→ Middleware response phase (LIFO) → Terminable Middleware
```

### bootstrap/app.php (Laravel 11)

```php
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(web: __DIR__.'/../routes/web.php', api: __DIR__.'/../routes/api.php')
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->append(TrackActivity::class);
        $middleware->alias(['signed' => ValidateSignature::class]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->renderable(fn (DomainException $e) => response()->json(...));
    })
    ->create();
```

---

## Anti-Patterns

| Anti-Pattern                    | Problem                          | Fix                                          |
| ------------------------------- | -------------------------------- | -------------------------------------------- |
| `app()` in domain code          | Service locator, hidden deps     | Constructor injection                        |
| Binding concrete, not interface | Tight coupling                   | `bind(Interface::class, Concrete::class)`    |
| `make()` in `register()`        | Provider ordering fragility      | Defer inside closure                         |
| Fat service provider            | God object                       | Split into focused providers                 |
| `env()` in application code     | Breaks `config:cache`            | Use `config()`                               |
| `APP_DEBUG=true` default        | Info disclosure in production    | Default to `false`                           |
| Forgot `optimize:clear`         | Stale deferred provider manifest | Run after adding/removing deferred providers |
