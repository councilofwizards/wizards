---
name: php-integrations
description: "Use this skill when combining Laravel with Pest (actingAs, datasets, RefreshDatabase, Drift migration), using PHP 8.4 property hooks as Eloquent accessors, integrating Filament with Laravel policies and domain services, running Laravel on Octane with FrankenPHP or Swoole (singleton contamination, scoped bindings), or embedding Livewire components inside Filament panels."
---

# PHP Cross-Framework Integration Patterns

This skill covers how PHP's major frameworks and tools work together: Laravel+Pest testing, PHP 8.4 features in Laravel,
Filament's architecture within Laravel, Laravel Octane with application servers, and Livewire+Filament component
integration.

## Laravel + Pest Testing

### Setup

Pest ships as the default test runner for new Laravel projects. The `pest-plugin-laravel` package re-exposes Laravel's
testing helpers as top-level functions.

```bash
# New project — already configured
laravel new my-app

# Existing project
composer require pestphp/pest pestphp/pest-plugin-laravel --dev
php artisan pest:install
```

### Bootstrap (`tests/Pest.php`)

```php
uses(TestCase::class, RefreshDatabase::class)->in('Feature');
uses(TestCase::class)->in('Unit');
```

`uses()` in `Pest.php` is inherited by all test files in the specified directory. Individual files can override or
extend.

### HTTP Testing

The plugin provides `get()`, `post()`, `put()`, `patch()`, `delete()`, and their JSON variants as global functions
returning `TestResponse`.

```php
it('shows a post to guests', function () {
    $post = Post::factory()->published()->create();

    get(route('posts.show', $post))
        ->assertOk()
        ->assertSee($post->title);
});
```

### Authentication

```php
it('allows admins to delete posts', function () {
    $admin = User::factory()->admin()->create();
    $post = Post::factory()->create();

    actingAs($admin)
        ->delete(route('posts.destroy', $post))
        ->assertNoContent();
});

// With specific guard
actingAs($user, 'sanctum')
    ->deleteJson("/api/posts/{$post->id}");
```

### Datasets with Factories

Use factory closures in datasets for lazy DB evaluation with `RefreshDatabase` rollback:

```php
dataset('admin users', [
    'superadmin'  => fn () => User::factory()->superAdmin()->create(),
    'staff admin' => fn () => User::factory()->staff()->admin()->create(),
]);

it('allows admin access', function (User $user) {
    actingAs($user)->get('/admin')->assertOk();
})->with('admin users');
```

### Parallel Testing

Use `RefreshDatabase` exclusively for parallel suites. `DatabaseTransactions` is not parallel-safe.

```bash
vendor/bin/pest --parallel --processes=4
```

| Trait                  | Parallel safe?               |
|------------------------|------------------------------|
| `RefreshDatabase`      | Yes                          |
| `DatabaseTransactions` | No                           |
| `DatabaseTruncation`   | Partial (own DB per process) |

### Mutation Testing (Infection)

```bash
composer require infection/infection --dev
vendor/bin/infection --min-msi=70 --min-covered-msi=80
```

Configure `infection.json5` with `"testFramework": "pest"` and `"testFrameworkOptions": "--parallel"`.

### PHPUnit to Pest Migration (Drift)

```bash
composer require pestphp/pest-plugin-drift --dev
vendor/bin/pest --drift --dry-run  # preview
vendor/bin/pest --drift            # convert
```

Migrate one directory at a time. PHPUnit and Pest files coexist. Drift cannot auto-convert shared assertion helpers from
base `TestCase` classes — extract those to `expect()->extend()`.

### Quick Rules (Laravel+Pest)

1. Apply `uses(TestCase::class, RefreshDatabase::class)` globally in `Pest.php` for Feature tests.
2. Use `actingAs($user)` before the HTTP call — it is fluent-chainable.
3. Use factory closures in datasets to defer DB writes until test execution.
4. Run `--parallel` in CI with `RefreshDatabase`, never `DatabaseTransactions`.
5. Add Infection to CI with `--min-msi=70` as a floor.
6. Migrate PHPUnit files with Drift incrementally — one directory per PR.

---

## PHP 8.4 + Laravel 11

### Property Hooks as Eloquent Accessors

Replace `Attribute::make()` with native PHP 8.4 property hooks:

```php
class User extends Model
{
    // Virtual computed property
    public string $fullName {
        get => "{$this->first_name} {$this->last_name}";
    }

    // Read/write hook on a DB column
    public string $email {
        get => strtolower($this->getRawOriginal('email') ?? '');
        set(string $value) {
            $this->attributes['email'] = strtolower($value);
        }
    }
}
```

> **Warning:** Inside a `get` hook, access raw values via `$this->getRawOriginal('column')` or
`$this->attributes['column']` to avoid infinite recursion.

**When to use which:**

| Scenario                                      | Recommendation                        |
|-----------------------------------------------|---------------------------------------|
| New codebase on PHP 8.4                       | Property hooks                        |
| Need `shouldCache()` or serialization control | `Attribute::make()`                   |
| Package targeting PHP 8.2+                    | `Attribute::make()` for compatibility |

### Asymmetric Visibility in DTOs

```php
final class CreateUserData
{
    public function __construct(
        public private(set) string $name,
        public private(set) string $email,
        public private(set) string $password,
        public private(set) ?string $role = null,
    ) {}

    public static function fromRequest(array $validated): self
    {
        return new self(...$validated);
    }
}
```

Properties are publicly readable but immutable after construction — no boilerplate getters needed.

### `#[\Deprecated]` for Package APIs

```php
class InvoiceFormatter
{
    #[\Deprecated(message: 'Use formatWithLocale() instead.', since: '3.2')]
    public function format(\DateTimeInterface $date): string
    {
        return $date->format('Y-m-d');
    }
}
```

Triggers a native PHP deprecation warning at call time. Works on methods, functions, class constants, and enum cases.
Configure PHPUnit 10+/11+ with `failOnDeprecation="true"` to catch usage in tests.

### Quick Rules (PHP 8.4+Laravel)

1. Use property hooks for computed Eloquent attributes; avoid `$this->propertyName` inside the hook.
2. Use `public private(set)` in DTOs/Value Objects instead of private fields + getters.
3. Apply `#[\Deprecated]` to deprecated package methods for runtime warnings.
4. Require `"php": "^8.4"` in `composer.json` before using property hooks in production.
5. Keep `Attribute::make()` in projects that must support PHP 8.2/8.3.

---

## Filament + Laravel Architecture

### Core Principle: Filament Is a UI Layer

```
Filament Panel (forms, tables, actions)     ← Presentation
    ↓ calls
Laravel Application Layer (Actions, DTOs)   ← Business logic
    ↓ uses
Domain/Eloquent Layer (Models, Policies)    ← Data
```

**Anti-pattern:** Business logic in `form()` or `table()` callbacks.
**Correct:** Filament forms call domain actions (`Post::generateSlug($state)`).

### Policy-Based Authorization

Filament 3.x automatically checks Eloquent policies. No manual gate checks needed.

| Filament action | Policy method                       |
|-----------------|-------------------------------------|
| View list       | `viewAny(User $user)`               |
| Create          | `create(User $user)`                |
| Update          | `update(User $user, Model $record)` |
| Delete          | `delete(User $user, Model $record)` |
| Bulk delete     | `deleteAny(User $user)`             |

If the policy method returns `false`, Filament hides the UI element AND blocks the server-side request.

### Multi-Panel Architecture

Separate `PanelProvider` classes for each audience:

```php
// AdminPanelProvider
$panel->id('admin')->path('admin')->authGuard('web');

// CustomerPanelProvider
$panel->id('customer')->path('portal')->authGuard('customer');
```

Share logic via abstract base resources with panel-specific subclasses.

### Reusable Form Schemas

Extract form schemas to static classes for reuse across Resources and standalone Livewire components:

```php
final class AddressSchema
{
    public static function make(): array
    {
        return [
            Grid::make(2)->schema([
                TextInput::make('address_line1')->required(),
                TextInput::make('city')->required(),
                Select::make('country')->options(CountryList::all()),
            ]),
        ];
    }
}
```

### Testing Filament Resources

```php
it('creates a post via Filament form', function () {
    actingAs(User::factory()->admin()->create());

    Livewire::test(PostResource\Pages\CreatePost::class)
        ->fillForm(['title' => 'Test Post', 'body' => 'Content'])
        ->call('create')
        ->assertHasNoFormErrors();

    expect(Post::where('title', 'Test Post')->exists())->toBeTrue();
});
```

### Quick Rules (Filament+Laravel)

1. Keep domain logic in Actions/Services — Filament forms call domain code, they do not contain it.
2. Write Eloquent policies for every Resource — Filament checks them automatically.
3. Use separate `PanelProvider` classes per audience.
4. Extract reusable schemas to static classes (`AddressSchema::make()`).
5. Test with `Livewire::test(ResourcePage::class)` for full component stack testing.

---

## Laravel Octane + Application Servers

### Installation

```bash
composer require laravel/octane
php artisan octane:install --server=frankenphp  # or --server=swoole
php artisan octane:start --server=frankenphp --watch  # dev with hot reload
```

### Singleton Contamination (The #1 Gotcha)

With Octane, the container survives across requests. Singletons from request 1 leak into request 2.

**Fix:** Use `scoped()` bindings (preferred) or add to the `flush` config array:

```php
// Preferred: scoped binding
$this->app->scoped(UserContext::class);

// Alternative: flush config
// config/octane.php
'flush' => [UserContext::class],
```

### Warm and Flush

- **`warm`**: Pre-resolve expensive services on worker boot (before first request)
- **`flush`**: Re-resolve singletons after each request
- **`scoped()`**: Equivalent to flush but declared in service providers

### When Octane Helps

| Workload               | Benefit                              |
|------------------------|--------------------------------------|
| High-traffic JSON APIs | High — eliminates bootstrap overhead |
| Server-rendered Blade  | Medium — DB queries dominate         |
| Queue workers          | None — already long-running          |
| WebSocket servers      | Use Swoole directly                  |

### Production Docker (FrankenPHP)

```dockerfile
FROM dunglas/frankenphp:1-php8.4-alpine
RUN install-php-extensions pdo_pgsql redis opcache intl zip
# ... composer install, cache config/routes/views
ENV OCTANE_SERVER=frankenphp
CMD ["php", "artisan", "octane:start", "--server=frankenphp", \
     "--host=0.0.0.0", "--port=8000", "--workers=${OCTANE_WORKERS:-auto}"]
```

### Zero-Downtime Restart

```bash
php artisan octane:reload
# Or in CI/CD: kill -USR1 $(cat /tmp/octane.pid)
```

### Quick Rules (Octane)

1. Use `$this->app->scoped()` for all request-scoped state.
2. Run `octane:start --watch` locally to catch contamination early.
3. Add `octane:reload` to deployment pipelines for zero-downtime restarts.
4. Always set `OCTANE_MAX_REQUESTS` as a memory leak safety net.
5. Ticks run on every worker — design handlers to be idempotent.

---

## Livewire + Filament Integration

### Filament's Livewire Foundation

Every Filament page, resource, widget, and custom page extends `Livewire\Component`. This means:

- Standard Livewire lifecycle hooks (`mount()`, `updated()`) work in custom Filament pages
- Alpine.js `$wire` is available in any Filament Blade view
- Livewire events dispatched from one component reach others on the page
- All `wire:` directives work in custom Blade partials

### Embedding Livewire in Filament

**In custom pages:**

```blade
<x-filament-panels::page>
    @livewire('analytics.visitor-chart')
</x-filament-panels::page>
```

**As widget wrappers:**

```php
class RecentActivityWidget extends Widget
{
    protected static string $view = 'filament.widgets.recent-activity';
}
```

```blade
<x-filament-widgets::widget>
    @livewire('activity-feed', ['limit' => 20])
</x-filament-widgets::widget>
```

### Standalone Filament Components in Livewire

Use Filament's Forms/Tables APIs in any Livewire component outside of panels:

```php
class NotificationSettings extends Component implements HasForms
{
    use InteractsWithForms;

    public function form(Form $form): Form
    {
        return $form->schema([
            Toggle::make('email_on_comment'),
            CheckboxList::make('push_events')->options([...]),
        ])->statePath('data');
    }
}
```

Always include `<x-filament-actions::modals />` in views using Filament actions with modal confirmations.

### Cross-Component Communication

```php
// Custom Livewire component dispatches
$this->dispatch('record-updated', id: $this->recordId);

// Filament page listens
protected function getListeners(): array
{
    return ['record-updated' => 'refreshRecord'];
}
```

### Theming

Use Filament's `fi-*` CSS classes in custom views inside panels for dark mode and color consistency. Alpine.js is always
available — registered by Livewire, no separate import needed.

### Quick Rules (Livewire+Filament)

1. Any Livewire component works in Filament pages via `@livewire('...')` with no changes.
2. Use `InteractsWithForms` + `HasForms` for standalone Filament forms outside panels.
3. Include `<x-filament-actions::modals />` in views using Filament modal actions.
4. Use `fi-*` CSS classes inside panels for theming consistency.
5. Use `$this->dispatch()` from custom Livewire to trigger Filament table/page refreshes.
6. Alpine.js is always available — no separate import needed.

---

## References

- [references/laravel-pest.md](references/laravel-pest.md) — Full Laravel+Pest API reference
- [references/php84-laravel.md](references/php84-laravel.md) — PHP 8.4 feature usage in Laravel
- [references/filament-octane-livewire.md](references/filament-octane-livewire.md) — Filament, Octane, and Livewire
  integration reference
