# Filament, Octane, and Livewire Integration Reference

## Table of Contents

- [Filament Policy Mapping](#filament-policy-mapping)
- [Multi-Panel Configuration](#multi-panel-configuration)
- [Reusable Schemas](#reusable-schemas)
- [Testing Filament Resources](#testing-filament-resources)
- [Laravel Octane Setup](#laravel-octane-setup)
- [Singleton Contamination Fixes](#singleton-contamination-fixes)
- [Octane Swoole Features](#octane-swoole-features)
- [Octane Production Deployment](#octane-production-deployment)
- [Embedding Livewire in Filament](#embedding-livewire-in-filament)
- [Standalone Filament Components](#standalone-filament-components)
- [Cross-Component Events](#cross-component-events)

---

## Filament Policy Mapping

Filament 3.x automatically checks Eloquent policies:

| Filament Action | Policy Method                            |
| --------------- | ---------------------------------------- |
| View list       | `viewAny(User $user)`                    |
| View record     | `view(User $user, Model $record)`        |
| Create          | `create(User $user)`                     |
| Update          | `update(User $user, Model $record)`      |
| Delete          | `delete(User $user, Model $record)`      |
| Bulk delete     | `deleteAny(User $user)`                  |
| Force delete    | `forceDelete(User $user, Model $record)` |
| Restore         | `restore(User $user, Model $record)`     |

If the policy returns `false`, Filament hides the UI element AND blocks the server-side request. Policies are discovered
via Laravel's automatic registration.

---

## Multi-Panel Configuration

```php
// AdminPanelProvider
$panel->id('admin')->path('admin')->authGuard('web')
    ->resources([UserResource::class, PostResource::class]);

// CustomerPanelProvider
$panel->id('customer')->path('portal')->authGuard('customer')
    ->resources([OrderResource::class, InvoiceResource::class]);
```

Register both in `bootstrap/providers.php`. Share logic via abstract base resources.

---

## Reusable Schemas

```php
final class AddressSchema
{
    public static function make(): array
    {
        return [
            Grid::make(2)->schema([
                TextInput::make('address_line1')->required(),
                TextInput::make('city')->required(),
                Select::make('country')->options(CountryList::all())->required(),
            ]),
        ];
    }
}

// In Resource: $form->schema([...AddressSchema::make(), TextInput::make('notes')]);
// In Livewire: $form->schema(AddressSchema::make())->statePath('data');
```

---

## Testing Filament Resources

```php
it('renders post list for admins', function () {
    actingAs(User::factory()->admin()->create())
        ->get(PostResource::getUrl('index'))->assertOk();
});

it('prevents editors from deleting', function () {
    actingAs(User::factory()->editor()->create());
    Livewire::test(PostResource\Pages\ListPosts::class)
        ->assertTableActionHidden('delete', Post::factory()->create());
});

it('creates via form', function () {
    actingAs(User::factory()->admin()->create());
    Livewire::test(PostResource\Pages\CreatePost::class)
        ->fillForm(['title' => 'Test', 'body' => 'Content'])
        ->call('create')->assertHasNoFormErrors();
    expect(Post::where('title', 'Test')->exists())->toBeTrue();
});
```

---

## Laravel Octane Setup

```bash
composer require laravel/octane
php artisan octane:install --server=frankenphp  # or --server=swoole
php artisan octane:start --server=frankenphp --watch  # dev with hot reload
```

Key config (`config/octane.php`):

```php
'warm' => [\App\Services\CountryList::class],  // pre-resolve on worker boot
'flush' => [UserContext::class],                // re-resolve after each request
'garbage' => 50,                                // restart worker after N requests
```

---

## Singleton Contamination Fixes

**Fix 1 — Scoped bindings (preferred):**

```php
$this->app->scoped(UserContext::class);
```

**Fix 2 — Flush config:** Add to `'flush'` array in `config/octane.php`.

**Fix 3 — RequestTerminated listener:**

```php
class ClearAnalyticsBuffer
{
    public function handle(RequestTerminated $event): void
    {
        $event->app->make(AnalyticsBuffer::class)->flush();
    }
}
```

| Workload               | Octane Benefit |
| ---------------------- | -------------- |
| High-traffic JSON APIs | High           |
| Server-rendered Blade  | Medium         |
| Queue workers / CLI    | None           |

---

## Octane Swoole Features

**Ticks:** Periodic tasks running on every worker (design idempotently):

```php
if ($this->app->runningInOctane()) {
    Octane::tick('stats-flush', fn () => StatsBuffer::flush())->seconds(60);
}
```

**Tables:** Shared in-memory data across workers (prefer Redis for most cases):

```php
Octane::table('rate-limits')
    ->row('user_id', OctaneTable::INT_TYPE, 4)
    ->row('hits', OctaneTable::INT_TYPE, 4)
    ->rows(10000)->create();
```

---

## Octane Production Deployment

```dockerfile
FROM dunglas/frankenphp:1-php8.4-alpine
RUN install-php-extensions pdo_pgsql redis opcache intl zip
COPY . /app
RUN composer install --no-dev --optimize-autoloader && \
    php artisan config:cache && php artisan route:cache && php artisan view:cache
CMD ["php", "artisan", "octane:start", "--server=frankenphp", \
     "--host=0.0.0.0", "--port=8000", "--workers=${OCTANE_WORKERS:-auto}"]
```

Zero-downtime restart: `php artisan octane:reload` or `kill -USR1 $(cat /tmp/octane.pid)`.

Key env vars: `OCTANE_SERVER`, `OCTANE_WORKERS`, `OCTANE_MAX_REQUESTS`, `OCTANE_HTTPS`.

---

## Embedding Livewire in Filament

**In custom page views:**

```blade
<x-filament-panels::page>
    @livewire('analytics.visitor-chart')
</x-filament-panels::page>
```

**As widget wrappers:**

```blade
<x-filament-widgets::widget>
    @livewire('activity-feed', ['limit' => 20])
</x-filament-widgets::widget>
```

**Resource page with Livewire reactivity:**

```php
class UserAnalytics extends Page
{
    protected static string $resource = UserResource::class;
    public string $period = '30d';

    #[Computed]
    public function stats(): array
    {
        return UserAnalyticsService::forPeriod($this->userId, $this->period);
    }
}
```

---

## Standalone Filament Components

**Forms outside panels** — implement `HasForms` + `InteractsWithForms`:

```php
class NotificationSettings extends Component implements HasForms
{
    use InteractsWithForms;
    public ?array $data = [];

    public function form(Form $form): Form
    {
        return $form->schema([
            Toggle::make('email_on_comment'),
            CheckboxList::make('push_events')->options([...]),
        ])->statePath('data');
    }
}
```

**Tables outside panels** — implement `HasTable` + `InteractsWithTable`:

```php
class AuditLogTable extends Component implements HasTable
{
    use InteractsWithTable;

    public function table(Table $table): Table
    {
        return $table->query(AuditLog::query()->latest())
            ->columns([
                TextColumn::make('created_at')->dateTime(),
                TextColumn::make('action')->badge(),
            ])->paginated([10, 25, 50]);
    }
}
```

Always include `<x-filament-actions::modals />` in views using Filament modal actions.

---

## Cross-Component Events

```php
// Custom Livewire dispatches
$this->dispatch('record-updated', id: $this->recordId);

// Filament page listens
protected function getListeners(): array
{
    return ['record-updated' => 'refreshRecord'];
}

// Table auto-refresh
protected function getListeners(): array
{
    return ['post-published' => '$refresh'];
}
```

Use Filament's `fi-*` CSS classes in custom views inside panels for dark mode and theming consistency. Alpine.js is
always available (registered by Livewire) — no separate import needed.
