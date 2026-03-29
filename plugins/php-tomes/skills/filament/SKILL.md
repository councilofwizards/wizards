---
name: filament
description:
  "Use this skill when building Filament admin panels: creating resources, defining form schemas, configuring table
  columns and filters, writing actions with modals, building dashboard widgets, creating custom pages, setting up
  multi-tenancy, or developing Filament plugins. Covers PanelProvider config, policy auto-discovery, reactive fields,
  bulk actions, notifications, and standalone form/table usage in Livewire."
---

# Filament 3.x — Admin Panel Engineering

Target: Filament 3.x, Laravel 11.x, Livewire 3.x, PHP 8.2+.

## Architecture

Filament layers on top of Laravel's service provider system and Livewire's component runtime. The top-level unit is a \*
\*Panel\*\* — a self-contained admin area registered as a `PanelProvider` (a Laravel `ServiceProvider` subclass). Each
panel owns its routes, navigation, auth guard, middleware, and the set of Resources, Pages, and Widgets it exposes.

```
Browser (Alpine.js)
  └─ Livewire wire protocol
      └─ Filament Panel Layer
          ├── Resources (CRUD UI → Eloquent models)
          ├── Pages (custom views)
          └── Widgets (stats/charts)
              └─ Form Schema / Table Schema
      └─ PanelProvider (ServiceProvider)
          └─ bootstrap/providers.php
```

### Panel Lifecycle

| Phase               | What happens                                                            |
| ------------------- | ----------------------------------------------------------------------- |
| `register()`        | `PanelProvider::register()` calls `FilamentManager::registerPanel()`    |
| Plugin `register()` | Each plugin's `register()` runs; resources/pages/widgets are registered |
| `boot()`            | `PanelProvider::boot()` sets up routes, middleware stack, auth          |
| Plugin `boot()`     | Each plugin's `boot()` runs; services are fully resolved                |
| Request             | Filament routes match, Livewire renders the panel page                  |

## Panel Configuration

All configuration lives in `PanelProvider::panel(Panel $panel)` — a fluent builder. Key methods: `->default()`,
`->id()`, `->path()`, `->login()`, `->colors()`, `->discoverResources()`, `->middleware()`, `->authMiddleware()`,
`->spa()`, `->plugins()`, `->tenant()`.

### Authentication

Implement `FilamentUser` on the User model to restrict panel access via `canAccessPanel(Panel $panel): bool`.

> **Warning:** Without `FilamentUser`, any authenticated user can access any panel.

### Multiple Panels

Each panel needs a unique `id()`. Only one can be `->default()`. Register all providers in `bootstrap/providers.php`.
Use separate `discoverResources()` paths per panel.

````

## Resources (CRUD)

A Resource binds an Eloquent model to a full CRUD interface: list, create, edit, view pages.

```bash
php artisan make:filament-resource Post              # basic
php artisan make:filament-resource Post --generate    # scaffold form/table from DB
php artisan make:filament-resource Post --soft-deletes
php artisan make:filament-resource Post --simple      # modal editing, no view page
````

### Resource Anatomy

A Resource class defines: `$model`, `$navigationIcon`, `$navigationGroup`, `form(Form $form)`, `table(Table $table)`,
`getPages()`, and optionally `getRelationManagers()`.

```php
class PostResource extends Resource
{
    protected static ?string $model = Post::class;
    protected static ?string $navigationIcon = 'heroicon-o-document-text';

    public static function form(Form $form): Form
    {
        return $form->schema([
            TextInput::make('title')->required()->maxLength(255),
            RichEditor::make('body')->required()->columnSpanFull(),
            Select::make('status')->options(['draft' => 'Draft', 'published' => 'Published'])->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('title')->searchable()->sortable(),
                TextColumn::make('status')->badge(),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->actions([EditAction::make()])
            ->bulkActions([DeleteBulkAction::make()]);
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListPosts::route('/'),
            'create' => Pages\CreatePost::route('/create'),
            'edit'   => Pages\EditPost::route('/{record}/edit'),
        ];
    }
}
```

### Policy Integration

Filament auto-checks model policies: `viewAny`, `view`, `create`, `update`, `delete`, `deleteAny`, `restore`,
`restoreAny`, `forceDelete`, `forceDeleteAny`.

> **Warning:** No policy = all actions allowed by default. Create policies before production. Enable strict mode:
> `$panel->authorizationPolicy(AuthorizationPolicy::Strict)` (Filament 3.1+).

### Relation Managers

Embed sub-tables on Edit pages: `php artisan make:filament-relation-manager PostResource comments body`. Set
`protected static string $relationship` and define `form()` / `table()`.

### Global Search

Declare `getGloballySearchableAttributes(): array` returning column names (dot notation for relations). Eager-load via
`getGlobalSearchEloquentQuery()`.

## Forms API

Forms are PHP arrays of field objects. Closures receive injected state via typed `Get`/`Set` parameters.

### Reactive Fields

Use `live()` for real-time reactivity, `live(onBlur: true)` for blur-triggered (cheaper for text inputs).

```php
Select::make('category_id')
    ->options(Category::all()->pluck('name', 'id'))
    ->live()
    ->afterStateUpdated(fn (Set $set) => $set('subcategory_id', null)),

Select::make('subcategory_id')
    ->options(function (Get $get): array {
        if (! $categoryId = $get('category_id')) return [];
        return Subcategory::where('category_id', $categoryId)->pluck('name', 'id')->toArray();
    })
    ->searchable()->preload(),
```

### Closure Injection Parameters

| Parameter    | Type                  | Description                              |
| ------------ | --------------------- | ---------------------------------------- |
| `Get $get`   | `\Filament\Forms\Get` | Read another field's current value       |
| `Set $set`   | `\Filament\Forms\Set` | Write to another field                   |
| `$record`    | `?Model`              | Current Eloquent record (null on create) |
| `$state`     | `mixed`               | Current field value                      |
| `$operation` | `string`              | `'create'` or `'edit'`                   |

### Layout Components

- **Section** — collapsible group with heading, description, icon
- **Grid** — responsive column layout: `Grid::make(3)`
- **Fieldset** — grouped fields with label
- **Tabs** — tabbed sections: `Tabs::make()->tabs([Tab::make('Details')->schema([...])])`
- **Wizard** — multi-step with per-step validation

### Select with Relationships

```php
Select::make('author_id')
    ->relationship('author', 'name')
    ->searchable()->preload()
    ->createOptionForm([TextInput::make('name')->required()]),
```

### Repeater and Builder

Repeater: nested schema with `minItems()`, `maxItems()`, `reorderable()`, `collapsible()`. Builder: Repeater variant
with typed `Block` entries — for content blocks, page builders.

### Validation

All Laravel rules via `->rules()` plus shorthands: `->email()`, `->numeric()`, `->minLength()`,
`->unique(ignoreRecord: true)`.

## Tables API

Tables are defined in `table(Table $table)` on Resources, RelationManagers, or Livewire components with `HasTable`.

### Column Types

`TextColumn`, `IconColumn`, `ImageColumn`, `ColorColumn`, `ToggleColumn`, `SelectColumn`, `TextInputColumn`,
`CheckboxColumn`, `ViewColumn`.

### Key Patterns

```php
TextColumn::make('price')->money('usd')->sortable(),
TextColumn::make('status')->badge()->color(fn (string $state) => match ($state) {
    'active' => 'success', 'inactive' => 'danger', default => 'gray',
}),
```

Filters: `SelectFilter` (with `->relationship()`), `TernaryFilter`, `TrashedFilter`, custom `Filter` with `->form()` and
`->query()`.

### Performance

- Eager-load relationships via `getTableQuery()` — Filament does NOT auto-detect N+1s
- Use `toggleable(isToggledHiddenByDefault: true)` on low-priority columns
- Use `$table->deferLoading()` on pages with heavy widgets
- Index columns used in `searchable()` and `sortable()`

## Actions & Notifications

Actions are first-class objects with behavior, UI, confirmation flow, and optional modal forms.

### Action with Modal Form

```php
Action::make('reject')
    ->requiresConfirmation()
    ->form([Textarea::make('reason')->required()])
    ->action(function (array $data, Post $record): void {
        $record->reject($data['reason']);
        Notification::make()->title('Rejected')->warning()->send();
    }),
```

For reusable actions, extend `Action` with `getDefaultName()` and `setUp()`.

### Notifications

```php
Notification::make()->title('Saved')->success()->send();              // flash
Notification::make()->title('Export ready')->success()->sendToDatabase($user); // persistent
Notification::make()->title('New order')->success()->broadcast($user);        // real-time
```

Enable: `$panel->databaseNotifications()->databaseNotificationsPolling('30s')`.

### Action Best Practices

- Always add `->authorize()` or `->visible()` — Livewire calls can be replayed
- Use `->requiresConfirmation()` for destructive actions
- Dispatch queued jobs for heavy work; notify asynchronously

## Widgets

Three built-in types: **StatsOverviewWidget**, **ChartWidget**, and base **Widget**.

- **StatsOverviewWidget**: Override `getStats()` returning `Stat::make()` objects with `->description()`, `->color()`,
  `->chart()`.
- **ChartWidget**: Override `getData()` (Chart.js format) and `getType()` (`line`, `bar`, `pie`, etc.). Use
  `getFilters()` for built-in dropdown.
- **Base Widget**: Custom Blade view via `protected static string $view`.

### Widget Performance

- **Polling**: `protected static ?string $pollingInterval = '30s';` — use selectively
- **Lazy loading**: `protected static bool $isLazy = true;` — defers queries past page load
- **Cache**: wrap expensive aggregates in `Cache::remember()`
- **Gate**: always implement `canView()` on sensitive KPIs
- **Column span**: `protected int|string|array $columnSpan = ['default' => 'full', 'md' => 2];`

## Custom Pages

For settings, reports, dashboards — pages not tied to a Resource.

```bash
php artisan make:filament-page Settings
```

### Settings Page Pattern

Implement `HasForms`, use `InteractsWithForms` trait, bind with `->statePath('data')`. Fill in `mount()`, persist in a
`save()` method. Blade uses `<x-filament-panels::page>` wrapper with `wire:submit`.

> **Note:** Use `statePath('data')` to avoid property name collisions.

Always implement `canAccess(): bool` on sensitive pages — Filament does not gate custom pages by default.

## Multi-Tenancy

Enable with `$panel->tenant(Team::class)`. User model implements `HasTenants` with `getTenants()` and
`canAccessTenant()`. Filament auto-scopes all resource queries to the active tenant.

> **Warning:** Never bypass with `Model::all()` — always use `static::getEloquentQuery()`. Override the tenant
> relationship name via `getTenantOwnershipRelationshipName()` on the Resource.

## Plugin Development

Plugins implement `Filament\Contracts\Plugin` with `make()`, `getId()`, `register()`, `boot()`. Use `register()` for
panel configuration only (resources, pages, widgets). Use `boot()` for side effects (Livewire registration, routes).
Expose configuration via fluent setters; retrieve with `MyPlugin::get()`.

### Key Rules

- Never hardcode panel IDs — use `filament()->getId()`
- Let users publish and review migrations — never auto-migrate
- Document expected model policies
- Test with `orchestra/testbench` + Pest; register a test panel with the plugin

## Deployment

```bash
php artisan filament:optimize  # publish assets + cache component discovery
```

Run `filament:optimize` in CI/CD after every Filament upgrade.

## References

- [resources-panels.md](references/resources-panels.md) — Resources, panels, multi-tenancy quick-reference
- [forms-tables.md](references/forms-tables.md) — Forms API and Tables API quick-reference
- [advanced.md](references/advanced.md) — Widgets, custom pages, actions, notifications, plugins
