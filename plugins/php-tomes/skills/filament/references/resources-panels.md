# Filament Resources & Panels Reference

## Table of Contents

- [Panel Provider Config](#panel-provider-config)
- [Resource Properties](#resource-properties)
- [Policy Methods](#policy-methods)
- [Global Search](#global-search)
- [Multi-Tenancy](#multi-tenancy)
- [Navigation](#navigation)
- [Artisan Commands](#artisan-commands)

## Panel Provider Config

| Method                           | Default              | Description                    |
|----------------------------------|----------------------|--------------------------------|
| `id(string)`                     | required             | Unique panel identifier        |
| `path(string)`                   | `''`                 | URL prefix                     |
| `default()`                      | false                | Mark as default panel          |
| `domain(string)`                 | null                 | Restrict to subdomain          |
| `login()`                        | disabled             | Enable login page              |
| `registration()`                 | disabled             | Enable registration page       |
| `passwordReset()`                | disabled             | Enable password reset          |
| `emailVerification()`            | disabled             | Require email verification     |
| `profile()`                      | disabled             | Enable profile page            |
| `authGuard(string)`              | `'web'`              | Auth guard name                |
| `authUserModel(string)`          | `User::class`        | User model class               |
| `colors(array)`                  | Filament defaults    | Color palette                  |
| `darkMode(bool)`                 | true                 | Enable dark mode toggle        |
| `defaultThemeMode(ThemeMode)`    | System               | Starting theme mode            |
| `brandName(string)`              | app name             | Sidebar/header brand text      |
| `brandLogo(string)`              | null                 | Logo asset URL                 |
| `favicon(string)`                | null                 | Favicon asset URL              |
| `spa()`                          | disabled             | SPA navigation mode            |
| `middleware(array)`              | `[]`                 | Web middleware stack           |
| `authMiddleware(array)`          | `[]`                 | Auth middleware                |
| `plugins(array)`                 | `[]`                 | Filament plugins               |
| `tenant(Model, slugAttribute)`   | null                 | Enable multi-tenancy           |
| `viteTheme(string)`              | null                 | Vite-compiled theme CSS path   |
| `globalSearch(bool)`             | true                 | Enable/disable global search   |
| `globalSearchKeyBindings(array)` | `['ctrl+k','cmd+k']` | Search keyboard shortcuts      |
| `discoverResources(in, for)`     | app path             | Auto-discover resource classes |
| `discoverPages(in, for)`         | app path             | Auto-discover page classes     |
| `discoverWidgets(in, for)`       | app path             | Auto-discover widget classes   |
| `resources(array)`               | `[]`                 | Explicitly register resources  |
| `pages(array)`                   | `[]`                 | Explicitly register pages      |
| `widgets(array)`                 | `[]`                 | Explicitly register widgets    |
| `databaseNotifications()`        | disabled             | Enable notification drawer     |
| `databaseNotificationsPolling()` | null                 | Polling interval for notifs    |

## Resource Properties

| Property / Method                      | Purpose                                           |
|----------------------------------------|---------------------------------------------------|
| `$model`                               | Eloquent model class string                       |
| `$navigationIcon`                      | Heroicons name for nav item                       |
| `$navigationGroup`                     | Groups nav items under a heading                  |
| `$navigationSort`                      | Integer sort order within group                   |
| `$navigationLabel`                     | Override auto-generated nav label                 |
| `$slug`                                | Override URL segment (default: plural kebab-case) |
| `$recordTitleAttribute`                | Model attribute for breadcrumbs                   |
| `$recordRouteKeyName`                  | Route key (default: `id`)                         |
| `form(Form $form)`                     | Define create/edit form schema                    |
| `table(Table $table)`                  | Define list table schema                          |
| `getPages()`                           | Map route names to page classes                   |
| `getRelationManagers()`                | Relation managers for edit page                   |
| `getGloballySearchableAttributes()`    | Attributes in global search                       |
| `getEloquentQuery()`                   | Override base query (scopes, eager loads)         |
| `getTenantOwnershipRelationshipName()` | Override tenant relationship name                 |
| `getNavigationBadge()`                 | Return badge string for nav item                  |
| `getNavigationBadgeColor()`            | Badge color: success, warning, danger, etc.       |

## Policy Methods

Filament auto-checks these policy methods:

| Policy method    | Filament action                                |
|------------------|------------------------------------------------|
| `viewAny`        | Seeing resource in nav and listing records     |
| `view`           | Viewing a record detail page                   |
| `create`         | Accessing create page and saving               |
| `update`         | Accessing edit page and saving changes         |
| `delete`         | Deleting individual records                    |
| `deleteAny`      | Bulk-deleting records                          |
| `restore`        | Restoring soft-deleted records                 |
| `restoreAny`     | Bulk-restoring soft-deleted records            |
| `forceDelete`    | Permanently deleting soft-deleted records      |
| `forceDeleteAny` | Bulk permanently deleting soft-deleted records |

No policy = all allowed. Use `$panel->authorizationPolicy(AuthorizationPolicy::Strict)` to flip to deny-all.

## Global Search

```php
// Required: declare searchable attributes
public static function getGloballySearchableAttributes(): array
{
    return ['title', 'body', 'author.name'];
}

// Optional: customize result display
public static function getGlobalSearchResultTitle(Model $record): string { return $record->title; }
public static function getGlobalSearchResultDetails(Model $record): array
{
    return ['Status' => $record->status, 'Author' => $record->author->name];
}
public static function getGlobalSearchResultUrl(Model $record): string
{
    return static::getUrl('edit', ['record' => $record]);
}

// Eager-load for search results
public static function getGlobalSearchEloquentQuery(): Builder
{
    return parent::getGlobalSearchEloquentQuery()->with('author');
}
```

## Multi-Tenancy

```php
// Panel config
$panel->tenant(Team::class)->tenantRoutePrefix('team');

// User model
class User extends Authenticatable implements HasTenants
{
    public function getTenants(Panel $panel): Collection { return $this->teams; }
    public function canAccessTenant(Model $tenant): bool { return $this->teams->contains($tenant); }
}

// Override relationship name on Resource
public static function getTenantOwnershipRelationshipName(): string { return 'organization'; }
```

## Navigation

### Groups

```php
$panel->navigationGroups([
    NavigationGroup::make('Content')->icon('heroicon-o-document-text'),
    NavigationGroup::make('Settings')->icon('heroicon-o-cog-6-tooth')->collapsed(),
]);
```

### Custom Items

```php
$panel->navigationItems([
    NavigationItem::make('Analytics')
        ->url('https://analytics.example.com', shouldOpenInNewTab: true)
        ->icon('heroicon-o-chart-bar')->badge('New')->group('Reports')->sort(3),
]);
```

### User Menu

```php
$panel->userMenuItems([
    MenuItem::make()->label('Profile')->url(fn () => ProfilePage::getUrl())->icon('heroicon-o-user-circle'),
    'logout' => MenuItem::make()->label('Sign out'),
]);
```

## Artisan Commands

| Command                                                                | Description                          |
|------------------------------------------------------------------------|--------------------------------------|
| `make:filament-resource {Model}`                                       | Generate resource + pages            |
| `make:filament-resource {Model} --generate`                            | Auto-scaffold form/table from DB     |
| `make:filament-resource {Model} --simple`                              | Modal editing, no view page          |
| `make:filament-resource {Model} --soft-deletes`                        | Add restore/force-delete actions     |
| `make:filament-relation-manager {Resource} {relationship} {attribute}` | Generate relation manager            |
| `make:filament-page {Name}`                                            | Generate custom page                 |
| `make:filament-page {Name} --resource={Resource}`                      | Add page to a resource               |
| `make:filament-panel {id}`                                             | Scaffold a new PanelProvider         |
| `make:filament-theme`                                                  | Generate theme CSS stub              |
| `make:filament-user`                                                   | Create admin user interactively      |
| `filament:optimize`                                                    | Publish assets + cache discovery     |
| `filament:assets`                                                      | Publish/update panel assets          |
| `filament:cache-components`                                            | Cache resource/page/widget discovery |
| `filament:clear-cached-components`                                     | Clear discovery cache                |
