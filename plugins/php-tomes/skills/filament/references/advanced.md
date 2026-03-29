# Filament Advanced Reference

## Table of Contents

- [Actions Quick-Reference](#actions-quick-reference)
- [Modal Configuration](#modal-configuration)
- [Notifications](#notifications)
- [Widgets](#widgets)
- [Custom Pages](#custom-pages)
- [Plugin Development](#plugin-development)
- [Theming](#theming)
- [Deployment](#deployment)

## Actions Quick-Reference

| Class               | Context            | Key Methods                                                       |
| ------------------- | ------------------ | ----------------------------------------------------------------- |
| `Action`            | any                | `action()`, `form()`, `fillForm()`, `mutateFormDataUsing()`       |
| `CreateAction`      | tables, relations  | `form()`, `mutateFormDataUsing()`, `afterCreating()`              |
| `EditAction`        | table rows         | `form()`, `mutateFormDataUsing()`, `afterSaving()`                |
| `ViewAction`        | table rows         | `form()`                                                          |
| `DeleteAction`      | table rows         | `before()`, `after()`                                             |
| `RestoreAction`     | soft-deleted rows  | --                                                                |
| `ForceDeleteAction` | soft-deleted rows  | --                                                                |
| `BulkAction`        | bulk selection     | `action(Collection $records)`, `deselectRecordsAfterCompletion()` |
| `DeleteBulkAction`  | bulk selection     | --                                                                |
| `ActionGroup`       | table rows, header | `actions()`, `button()`, `dropdown()`                             |
| `ExportAction`      | header, page       | `exporter()`, `columnMapping()`, `chunkSize()`                    |
| `ImportAction`      | header, page       | `importer()`, `maxRows()`                                         |

### Standalone Action Class

Extend `Action`, override `getDefaultName()` and `setUp()`. Use as
`PublishAction::make()`.

### Form Actions

Use `Filament\Forms\Components\Actions` with `FormAction` entries. Closures
receive `Get $get`, `Set $set`.

### Page Header Actions

Override `getHeaderActions(): array` on any page class.

## Modal Configuration

Key methods: `->requiresConfirmation()`, `->modalHeading()`,
`->modalDescription()`, `->modalSubmitActionLabel()`, `->modalWidth('lg')`
(sm/md/lg/xl/2xl/3xl/screen), `->closeModalByClickingAway(false)`,
`->slideOver()` (side panel).

## Notifications

| Method        | Color | Icon                 |
| ------------- | ----- | -------------------- |
| `->success()` | green | check-circle         |
| `->warning()` | amber | exclamation-triangle |
| `->danger()`  | red   | x-circle             |
| `->info()`    | blue  | information-circle   |

```php
Notification::make()->title('Saved')->success()->send();                      // flash
Notification::make()->title('Saved')->success()->duration(5000)->send();      // auto-close
Notification::make()->title('Warning')->warning()->persistent()->send();      // no auto-close
Notification::make()->title('Ready')->success()->sendToDatabase($user);       // persistent
Notification::make()->title('Order')->success()->broadcast($user);            // real-time
Notification::make()->title('Failed')->danger()->sendToDatabase($user)->broadcast($user); // both
```

Enable database notifications:
`$panel->databaseNotifications()->databaseNotificationsPolling('30s')`. Run
`php artisan notifications:table && php artisan migrate`. Add actions:
`->actions([\Filament\Notifications\Actions\Action::make('view')->button()->url($url)])`.

## Widgets

### StatsOverviewWidget

Override `getStats()` returning `Stat::make(label, value)` with
`->description()`, `->descriptionIcon()`, `->color()`, `->chart([...])`,
`->url()`.

### ChartWidget

Override `getData()` (Chart.js format: `datasets` + `labels`), `getType()`
(`line`, `bar`, `pie`, `doughnut`, `polarArea`, `radar`). Optional: `$filter`
property + `getFilters()` for dropdown.

### Custom Widget

Set `protected static string $view`, override `getViewData()`, gate with
`canView()`.

### Widget Properties

| Property           | Purpose                                  |
| ------------------ | ---------------------------------------- |
| `$pollingInterval` | `'30s'`, `'1m'`, etc. `null` to disable  |
| `$isLazy`          | `true` to defer loading past page render |
| `$columnSpan`      | `'full'`, int, or responsive array       |

Register: `->widgets([...])` in PanelProvider. Replace dashboard:
`->dashboard(CustomDashboard::class)`.

## Custom Pages

### Basic Page

```php
class Settings extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';
    protected static ?string $navigationGroup = 'System';
    protected static string $view = 'filament.pages.settings';

    public static function canAccess(): bool
    {
        return auth()->user()?->can('manage_settings') ?? false;
    }
}
```

### Form-Backed Page

Implement `HasForms`, use `InteractsWithForms`. Bind with `->statePath('data')`.
Fill in `mount()`, persist in action method. Blade:
`<x-filament-panels::page><form wire:submit="save">{{ $this->form }}<x-filament::button type="submit">Save</x-filament::button></form></x-filament-panels::page>`.

### Layout

`hasTopbar(): bool` (remove top bar), `getMaxContentWidth(): MaxWidth` (e.g.,
`MaxWidth::Full`).

### Embedding Livewire

Wrap with
`<x-filament-panels::page><livewire:component-name /></x-filament-panels::page>`.

## Plugin Development

### Plugin Interface

```php
class MyPlugin implements \Filament\Contracts\Plugin
{
    public static function make(): static { return app(static::class); }
    public function getId(): string { return 'my-plugin'; }

    public function register(Panel $panel): void   // config only, no side effects
    {
        $panel->resources([...])->pages([...])->widgets([...]);
    }

    public function boot(Panel $panel): void        // side effects OK
    {
        Livewire::component('my-component', MyComponent::class);
    }
}
```

### Configuration

Expose fluent setters on the plugin class. Retrieve with `MyPlugin::get()`.

### Package Structure

`src/` (Plugin, ServiceProvider, Resources, Pages, Widgets), `config/`,
`database/migrations/`, `resources/views/`, `tests/`.

### Assets

Register via
`FilamentAsset::register([Css::make(...), Js::make(...)], 'vendor/name')`.

### Testing

Use `orchestra/testbench`. Register a test panel with
`app(PanelRegistry::class)->register($panel)`. Assert with
`livewire(ListRecords::class)->assertCanSeeTableRecords($records)`.

### Composer

Require `"filament/filament": "^3.0"`,
`"illuminate/contracts": "^10.0 || ^11.0"`, `"php": "^8.2"`.

## Theming

```php
$panel->colors([
    'primary' => Color::Violet,
    'gray'    => Color::Zinc,
    'danger'  => Color::Rose,
]);

$panel->colors(['primary' => Color::hex('#7c3aed')]); // custom hex

$panel->viteTheme('resources/css/filament/admin/theme.css');
// Generate stub: php artisan make:filament-theme
```

## Deployment

```bash
php artisan filament:optimize   # publish assets + cache component discovery
php artisan filament:assets     # publish assets only
```

Run `filament:optimize` after every Filament upgrade in CI/CD.
