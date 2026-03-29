# Laravel Ecosystem Reference

## Table of Contents

- [Package Decision Matrix](#package-decision-matrix)
- [Sanctum](#sanctum)
- [Passport](#passport)
- [Horizon](#horizon)
- [Telescope](#telescope)
- [Scout](#scout)
- [Cashier](#cashier)
- [Socialite](#socialite)
- [Auth Scaffolding](#auth-scaffolding)
- [Pennant](#pennant)
- [Reverb](#reverb)
- [Pulse](#pulse)
- [Pint](#pint)
- [Sail](#sail)
- [Package Development](#package-development)

---

## Package Decision Matrix

| Package            | Category    | Use When                        | Avoid When             |
| ------------------ | ----------- | ------------------------------- | ---------------------- |
| **Sanctum**        | Auth        | SPA/mobile API tokens           | Need OAuth server      |
| **Passport**       | Auth        | Full OAuth2 server              | Only SPA auth          |
| **Horizon**        | Queues      | Redis queue monitoring          | Non-Redis drivers      |
| **Telescope**      | Debug       | Local/staging introspection     | Unguarded production   |
| **Scout**          | Search      | Full-text (Algolia/Meilisearch) | Simple LIKE queries    |
| **Cashier Stripe** | Billing     | Stripe subscriptions            | Non-Stripe processors  |
| **Cashier Paddle** | Billing     | Paddle with tax handling        | Stripe-centric         |
| **Socialite**      | Auth        | OAuth social login              | SAML SSO               |
| **Fortify**        | Auth        | Headless auth backend           | Want pre-built views   |
| **Breeze**         | Scaffolding | Minimal auth starter            | Complex auth flows     |
| **Jetstream**      | Scaffolding | Auth + teams + API tokens       | Simple apps            |
| **Pennant**        | Flags       | Feature flags, A/B tests        | Simple env booleans    |
| **Reverb**         | WebSockets  | Self-hosted WebSocket server    | Pusher preferred       |
| **Pulse**          | Monitoring  | Performance dashboard           | Full APM in place      |
| **Pint**           | Style       | PHP-CS-Fixer wrapper            | Existing ECS config    |
| **Sail**           | Dev         | Docker local dev                | Existing devcontainers |

## Sanctum

SPA cookie auth + mobile API tokens. Integrates with Laravel's guard system.

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

```php
Route::middleware('auth:sanctum')->get('/user', fn (Request $r) => $r->user());
$token = $user->createToken('mobile-app', ['read', 'write'])->plainTextToken;
```

## Passport

Full OAuth2 server for issuing tokens to third-party applications.

## Horizon

Redis-only queue dashboard. Auto-scaling workers with `balance: 'auto'`.

```bash
composer require laravel/horizon && php artisan horizon:install && php artisan migrate
```

```php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'queue' => ['high', 'default', 'low'],
            'balance' => 'auto',
            'maxProcesses' => 10,
        ],
    ],
],
```

Protect `/horizon` with `Horizon::auth()` in production.

## Telescope

Debug assistant recording requests, jobs, queries, mail. Install as dev
dependency.

```bash
composer require laravel/telescope --dev
php artisan telescope:install && php artisan migrate
```

Restrict production:
`Telescope::auth(fn ($r) => in_array($r->user()?->email, config('telescope.allowed_emails')));`

## Scout

Driver-based full-text search. Drivers: Algolia, Meilisearch, Typesense,
database.

```php
class Article extends Model
{
    use Searchable;
    public function toSearchableArray(): array
    {
        return ['id' => $this->id, 'title' => $this->title, 'body' => $this->body];
    }
}

$results = Article::search('laravel queues')->paginate(15);
```

## Cashier

### Stripe

```php
use Laravel\Cashier\Billable;
class User extends Authenticatable { use Billable; }

$user->newSubscription('default', 'price_monthly')->create($paymentMethodId);
if ($user->subscribed('default')) { /* ... */ }
```

### Paddle

Same philosophy, Paddle manages tax/VAT compliance.

## Socialite

OAuth2 social login. Drivers: GitHub, Google, Facebook, Twitter, LinkedIn,
GitLab, Bitbucket + 100+ community drivers.

```php
Route::get('/auth/github', fn () => Socialite::driver('github')->redirect());
Route::get('/auth/github/callback', function () {
    $ghUser = Socialite::driver('github')->user();
    $user = User::updateOrCreate(['github_id' => $ghUser->getId()], [
        'name' => $ghUser->getName(), 'email' => $ghUser->getEmail(),
    ]);
    Auth::login($user);
    return redirect('/dashboard');
});
```

## Auth Scaffolding

| Package       | Stack                  | Features                                 |
| ------------- | ---------------------- | ---------------------------------------- |
| **Breeze**    | Blade/Livewire/Inertia | Minimal auth views                       |
| **Fortify**   | Headless               | Login, 2FA, email verify, password reset |
| **Jetstream** | Livewire/Inertia       | Breeze + teams + profile + API tokens    |

## Pennant

Feature flags with per-user/team scoping.

```php
Feature::define('new-checkout', fn (User $u) => $u->isInBeta());
if (Feature::active('new-checkout')) { /* ... */ }
```

```blade
@feature('new-checkout')
    <x-new-checkout />
@endfeature
```

## Reverb

First-party WebSocket server using Pusher protocol. Config-only switch between
Reverb and Pusher.

```bash
composer require laravel/reverb
php artisan reverb:install
php artisan reverb:start --host=0.0.0.0 --port=8080
```

## Pulse

Performance monitoring dashboard. Tracks slow requests, queries, jobs, cache
rates, exceptions.

```bash
composer require laravel/pulse
php artisan vendor:publish --provider="Laravel\Pulse\PulseServiceProvider"
php artisan migrate
```

## Pint

PHP-CS-Fixer wrapper with Laravel preset.

```bash
composer require laravel/pint --dev
./vendor/bin/pint          # fix
./vendor/bin/pint --test   # check only (CI)
```

## Sail

Docker Compose for local dev.

```bash
composer require laravel/sail --dev
php artisan sail:install
./vendor/bin/sail up -d
```

## Package Development

### Directory Layout

```
src/             # ServiceProvider, Facades, Contracts
config/          # Default config (mergeConfigFrom)
database/        # Migrations (loadMigrationsFrom)
resources/views/ # Views (loadViewsFrom)
tests/           # Orchestra Testbench tests
```

### Service Provider Pattern

```php
public function register(): void
{
    $this->mergeConfigFrom(__DIR__.'/../config/pkg.php', 'pkg');
    $this->app->singleton(Contract::class, fn ($app) => new Manager($app['config']['pkg']));
}

public function boot(): void
{
    $this->loadViewsFrom(__DIR__.'/../resources/views', 'pkg');
    $this->loadMigrationsFrom(__DIR__.'/../database/migrations');
    if ($this->app->runningInConsole()) {
        $this->publishes([__DIR__.'/../config/pkg.php' => config_path('pkg.php')], 'pkg-config');
    }
}
```

### Auto-Discovery (composer.json)

```json
"extra": {
    "laravel": {
        "providers": ["Vendor\\Pkg\\PkgServiceProvider"],
        "aliases": {"Pkg": "Vendor\\Pkg\\Facades\\Pkg"}
    }
}
```

### Testing with Testbench

| Laravel | Testbench |
| ------- | --------- |
| 11.x    | ^9.0      |
| 10.x    | ^8.0      |

### Key Rules

- Always `mergeConfigFrom()` + publishable config
- Bind to contracts, not concrete classes
- Register publishables only in `runningInConsole()`
- Never resolve services in `register()` — defer to closures
- Use `illuminate/support` as dependency, not `laravel/framework`
- SemVer: bump MAJOR when dropping a Laravel version
