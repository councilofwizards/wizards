# Eloquent ORM Reference

## Table of Contents

- [Model Conventions](#model-conventions)
- [Type Casting](#type-casting)
- [Accessors & Mutators](#accessors--mutators)
- [Relationships](#relationships)
- [Eager Loading](#eager-loading)
- [Query Builder Patterns](#query-builder-patterns)
- [Performance Patterns](#performance-patterns)
- [Architecture Patterns](#architecture-patterns)
- [Anti-Patterns](#anti-patterns)

---

## Model Conventions

### Mass Assignment

```php
// PREFERRED: explicit allowlist
protected $fillable = ['title', 'body', 'published_at'];

// NEVER in production
protected $guarded = [];
```

### Table & Key Configuration

```php
protected $table = 'audit_logs';      // non-standard table name
protected $primaryKey = 'log_id';     // non-standard PK
public $incrementing = false;         // UUID or string PK
protected $keyType = 'string';        // required for non-integer PKs
public $timestamps = false;           // no created_at/updated_at
```

### UUID Primary Keys

```php
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Order extends Model
{
    use HasUuids; // auto-generates UUID v7, sets incrementing = false
}
```

### Hidden Attributes

```php
protected $hidden = ['password', 'remember_token', 'api_key'];
// Controls toArray()/toJson() — does NOT prevent $model->password access
```

---

## Type Casting

| Cast                   | PHP Type          | Notes                        |
| ---------------------- | ----------------- | ---------------------------- |
| `'boolean'`            | `bool`            |                              |
| `'integer'`            | `int`             |                              |
| `'float'`              | `float`           |                              |
| `'array'`              | `array`           | JSON encode/decode           |
| `'collection'`         | `Collection`      | JSON encode/decode           |
| `'datetime'`           | `Carbon`          | Format: `'datetime:Y-m-d'`   |
| `'immutable_datetime'` | `CarbonImmutable` | Prefer for value objects     |
| `'encrypted'`          | `string`          | AES-256-CBC via APP_KEY      |
| `'encrypted:array'`    | `array`           | Encrypted JSON               |
| `MyEnum::class`        | backed enum       | PHP 8.1+ only                |
| `MyCast::class`        | custom            | Implements `CastsAttributes` |

### Custom Cast Example

```php
class MoneyCast implements CastsAttributes
{
    public function get(Model $model, string $key, mixed $value, array $attributes): Money
    {
        return new Money((int) $value, new Currency($attributes['currency']));
    }

    public function set(Model $model, string $key, mixed $value, array $attributes): array
    {
        return [$key => $value->getAmount(), 'currency' => $value->getCurrency()->getCode()];
    }
}
```

---

## Accessors & Mutators

```php
use Illuminate\Database\Eloquent\Casts\Attribute;

protected function fullName(): Attribute
{
    return Attribute::make(get: fn () => "{$this->first_name} {$this->last_name}");
}

protected function email(): Attribute
{
    return Attribute::make(set: fn (string $v) => strtolower(trim($v)));
}

// Append to serialization
protected $appends = ['full_name'];
```

---

## Relationships

### Type Reference

| Method                        | Returns          | FK Location           |
| ----------------------------- | ---------------- | --------------------- |
| `hasOne`                      | model or null    | child table           |
| `hasMany`                     | Collection       | child table           |
| `belongsTo`                   | model or null    | this table            |
| `belongsToMany`               | Collection       | pivot table           |
| `hasOneThrough`               | model or null    | intermediate          |
| `hasManyThrough`              | Collection       | intermediate          |
| `morphOne`/`morphMany`        | model/Collection | child `*_type`/`*_id` |
| `morphTo`                     | model or null    | this `*_type`/`*_id`  |
| `morphToMany`/`morphedByMany` | Collection       | polymorphic pivot     |

### Many-to-Many with Pivot Data

```php
public function teams(): BelongsToMany
{
    return $this->belongsToMany(Team::class)
        ->withTimestamps()
        ->withPivot('role', 'joined_at')
        ->as('membership');
}

// Attach with extra columns
$user->teams()->attach($teamId, ['role' => 'admin']);
$user->teams()->sync([1, 2, 3]);
$user->teams()->syncWithoutDetaching([4]);
```

### Polymorphic — Morph Map

```php
// Always register in AppServiceProvider::boot()
Relation::morphMap(['post' => Post::class, 'user' => User::class]);
```

### Default Models

```php
public function author(): BelongsTo
{
    return $this->belongsTo(User::class)->withDefault(['name' => 'Anonymous']);
}
```

### Existence Queries

```php
Post::has('comments')->get();
Post::has('comments', '>=', 3)->get();
Post::whereHas('comments', fn ($q) => $q->where('approved', true))->get();
Post::doesntHave('comments')->get();
```

---

## Eager Loading

```php
// Prevent N+1 in development
Model::preventLazyLoading(! app()->isProduction());

// Basic
Post::with(['author', 'tags'])->get();

// Nested
Post::with('comments.author')->get();

// Constrained
Post::with(['comments' => fn ($q) => $q->where('approved', true)])->get();

// Select specific columns (MUST include FK)
Post::with(['author:id,name'])->get();

// Count without loading
Post::withCount('comments')->get();
Post::withSum('items', 'quantity')->get();

// Lazy eager load on existing collection
$posts->load('author');
$posts->loadMissing('tags');
```

---

## Query Builder Patterns

### Local Scopes

```php
public function scopePublished(Builder $query): void
{
    $query->where('status', 'published')->whereNotNull('published_at');
}

// Chainable
Post::published()->recent(7)->byAuthor($userId)->paginate();
```

### Global Scopes

```php
static::addGlobalScope('active', fn (Builder $b) => $b->where('is_active', true));

// Remove for a query
User::withoutGlobalScope('active')->get();
```

### Conditional Clauses

```php
Post::query()
    ->when($request->status, fn ($q, $s) => $q->where('status', $s))
    ->when($request->search, fn ($q, $s) => $q->where('title', 'like', "%{$s}%"))
    ->paginate();
```

### Raw Expressions (Always Use Bindings)

```php
Post::whereRaw('CHAR_LENGTH(title) > ?', [50])->get();
Post::orderByRaw('FIELD(status, ?, ?, ?)', ['published', 'draft', 'archived'])->get();
```

### Subqueries

```php
User::addSelect([
    'latest_post_title' => Post::select('title')
        ->whereColumn('user_id', 'users.id')->latest()->limit(1),
])->get();
```

### Useful Methods

| Method                       | Description                  |
| ---------------------------- | ---------------------------- |
| `pluck('name', 'id')`        | Keyed array `[id => name]`   |
| `value('name')`              | Single scalar from first row |
| `exists()` / `doesntExist()` | Boolean check, no hydration  |
| `firstOrCreate([], [])`      | Find or insert               |
| `updateOrCreate([], [])`     | Upsert                       |
| `upsert([], ['email'], [])`  | Bulk DB-level upsert         |
| `toSql()` / `dd()`           | Debug: dump query            |

---

## Performance Patterns

### Chunking

| Method               | Best For                        |
| -------------------- | ------------------------------- |
| `chunkById(500, fn)` | Mutation-safe batch operations  |
| `chunk(500, fn)`     | Read-only, stable order         |
| `lazy()`             | Pipeline with Collection API    |
| `cursor()`           | Minimum memory, generator-based |

```php
Post::chunkById(500, function (Collection $posts) {
    foreach ($posts as $post) { ProcessPost::dispatch($post); }
});
```

### Avoiding Hydration Waste

```php
$count = Post::where('status', 'published')->count();  // not ->get()->count()
$titles = Post::pluck('title');                         // no model creation
if (Post::where('slug', $slug)->exists()) { ... }      // no hydration
$rows = Post::toBase()->get();                          // stdClass, not models
```

### Query Count Assertions

```php
DB::enableQueryLog();
$this->getJson('/api/posts');
$this->assertDatabaseQueryCount(3);
```

---

## Architecture Patterns

### Action Classes

```php
final class CompleteOrder
{
    public function __construct(
        private readonly OrderRepository $orders,
        private readonly Dispatcher $events,
    ) {}

    public function execute(Order $order): Order
    {
        $order->update(['status' => 'completed']);
        $this->events->dispatch(new OrderCompleted($order));
        return $order->fresh();
    }
}
```

### Repository Pattern

Worth it when: multiple persistence stores, complex shared queries, unit tests without DB. Over-engineering for: simple
CRUD, single Eloquent driver.

### Practical Middle Ground

1. Eloquent models = persistence (relationships, casts, scopes)
2. Action/Service classes = business logic
3. Repositories = only when persistence abstraction earns its cost

---

## Anti-Patterns

| Anti-Pattern                               | Fix                                     |
| ------------------------------------------ | --------------------------------------- |
| `$guarded = []` in production              | Use `$fillable`                         |
| Missing `$casts` for non-string cols       | Define all casts                        |
| N+1 queries                                | `with()`, enable `preventLazyLoading()` |
| `->get()->count()`                         | Use `->count()` directly                |
| `chunk()` with mutations                   | Use `chunkById()`                       |
| FK missing in eager-load `select()`        | Always include FK column                |
| Business logic in models                   | Extract to Action classes               |
| `$with` on model for rarely-used relations | Explicit `with()` at call site          |
| Model dispatching jobs/notifications       | Keep in Action/Service classes          |
