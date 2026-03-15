# Laravel + Pest Integration Reference

## Table of Contents

- [HTTP Helper Functions](#http-helper-functions)
- [Authentication Helpers](#authentication-helpers)
- [Pest.php Bootstrap Patterns](#pestphp-bootstrap-patterns)
- [Dataset Patterns with Factories](#dataset-patterns-with-factories)
- [Faking Laravel Services](#faking-laravel-services)
- [Parallel Testing Configuration](#parallel-testing-configuration)
- [Mutation Testing (Infection)](#mutation-testing-infection)
- [PHPUnit Migration (Drift)](#phpunit-migration-drift)
- [Complete Feature Test Example](#complete-feature-test-example)

---

## HTTP Helper Functions

The `pest-plugin-laravel` package exposes Laravel's HTTP testing methods as global functions:

| Function                        | Description                         |
|---------------------------------|-------------------------------------|
| `get($uri, $headers)`           | GET request                         |
| `post($uri, $data, $headers)`   | POST request                        |
| `put($uri, $data, $headers)`    | PUT request                         |
| `patch($uri, $data, $headers)`  | PATCH request                       |
| `delete($uri, $data, $headers)` | DELETE request                      |
| `getJson($uri)`                 | GET with `Accept: application/json` |
| `postJson($uri, $data)`         | POST JSON                           |
| `putJson($uri, $data)`          | PUT JSON                            |
| `patchJson($uri, $data)`        | PATCH JSON                          |
| `deleteJson($uri, $data)`       | DELETE JSON                         |
| `followingRedirects()`          | Follow redirects on next request    |
| `withHeaders($headers)`         | Set headers for next request        |
| `withCookie($name, $value)`     | Set cookie for next request         |
| `withSession($data)`            | Set session data for next request   |

All return a `TestResponse` object — the same as `$this->get()` in PHPUnit-style Laravel tests.

---

## Authentication Helpers

```php
// Basic authentication
actingAs($user)->get('/dashboard')->assertOk();

// With specific guard
actingAs($user, 'sanctum')->getJson('/api/profile');

// Chained with request
actingAs($admin)
    ->delete(route('posts.destroy', $post))
    ->assertNoContent();

// Guest (unauthenticated)
get('/admin')->assertRedirect('/login');
```

---

## Pest.php Bootstrap Patterns

### Standard Laravel Setup

```php
<?php
// tests/Pest.php

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

uses(TestCase::class, RefreshDatabase::class)->in('Feature');
uses(TestCase::class)->in('Unit');
```

### With Custom Expectations

```php
expect()->extend('toBeValidEmail', function () {
    return $this->toMatch('/^[^@]+@[^@]+\.[^@]+$/');
});

expect()->extend('toBePublished', function () {
    return $this->status->toBe('published')
        ->and($this->published_at)->not->toBeNull();
});
```

### With Custom Higher-Order Functions

```php
expect()->intercept('toBeAdmin', function () {
    return $this->hasRole('admin')->toBeTrue();
});
```

---

## Dataset Patterns with Factories

### Inline Dataset

```php
it('validates post status', function (string $status, bool $valid) {
    $response = actingAs(User::factory()->create())
        ->postJson('/api/posts', ['title' => 'Test', 'status' => $status]);

    $valid
        ? $response->assertCreated()
        : $response->assertUnprocessable();
})->with([
    'published' => ['published', true],
    'draft'     => ['draft', true],
    'invalid'   => ['garbage', false],
    'empty'     => ['', false],
]);
```

### Shared Dataset File

```php
// tests/Datasets/Users.php
dataset('admin users', [
    'superadmin'  => fn () => User::factory()->superAdmin()->create(),
    'staff admin' => fn () => User::factory()->staff()->admin()->create(),
]);

dataset('regular users', [
    'verified'   => fn () => User::factory()->verified()->create(),
    'unverified' => fn () => User::factory()->create(),
]);
```

```php
// Usage in tests
it('allows admin access', function (User $user) {
    actingAs($user)->get('/admin')->assertOk();
})->with('admin users');
```

Factory closures are evaluated lazily — one per test case, with `RefreshDatabase` rollback between each.

---

## Faking Laravel Services

```php
beforeEach(function () {
    Queue::fake();
    Event::fake([OrderPlaced::class]);
    Notification::fake();
    Storage::fake('s3');
    Mail::fake();
    Http::fake([
        'api.example.com/*' => Http::response(['ok' => true], 200),
    ]);
});

it('dispatches job on order creation', function () {
    actingAs(User::factory()->create())
        ->postJson('/api/orders', ['product_id' => 42, 'quantity' => 2])
        ->assertCreated();

    Queue::assertPushed(FulfillOrder::class);
    Event::assertDispatched(OrderPlaced::class);
    Queue::assertNothingPushed(); // assert nothing else was pushed
});
```

---

## Parallel Testing Configuration

### Running Parallel

```bash
vendor/bin/pest --parallel
vendor/bin/pest --parallel --processes=4
vendor/bin/pest --parallel --ci
```

### Database Isolation

| Trait                  | Parallel safe? | Notes                         |
|------------------------|----------------|-------------------------------|
| `RefreshDatabase`      | Yes            | Migrates fresh per-process DB |
| `DatabaseTransactions` | No             | Single-process only           |
| `DatabaseTruncation`   | Partial        | Safe with per-process DBs     |

Always use `RefreshDatabase` for parallel suites. Laravel automatically creates `test_<token>` databases per process.

---

## Mutation Testing (Infection)

### Configuration (`infection.json5`)

```json5
{
    "source": {
        "directories": ["app"],
        "excludes": ["app/Console", "app/Providers"]
    },
    "logs": {
        "text": "infection.log",
        "html": "infection.html"
    },
    "minMsi": 70,
    "minCoveredMsi": 80,
    "testFramework": "pest",
    "testFrameworkOptions": "--parallel"
}
```

### Targeted Runs

```bash
# Specific mutators
vendor/bin/infection --mutators=Assignment,BooleanSubstitution,Return_

# Only changed files (PR-scoped)
vendor/bin/infection --git-diff-filter=AM --git-diff-base=main
```

---

## PHPUnit Migration (Drift)

### Conversion Table

| PHPUnit                          | Pest                             |
|----------------------------------|----------------------------------|
| `class FooTest extends TestCase` | `uses(TestCase::class)`          |
| `public function test_foo()`     | `it('foo', function () {...})`   |
| `$this->assertEquals($a, $b)`    | `expect($b)->toBe($a)`           |
| `$this->assertCount(3, $items)`  | `expect($items)->toHaveCount(3)` |
| `setUp()` / `tearDown()`         | `beforeEach()` / `afterEach()`   |
| `#[DataProvider('provider')]`    | `->with(dataset)`                |
| `$this->markTestSkipped('...')`  | `->skip('...')`                  |

### Incremental Migration

```bash
# Convert one directory at a time
vendor/bin/pest --drift tests/Unit
# Review diff, run suite, commit
vendor/bin/pest --drift tests/Feature
```

Drift cannot convert shared assertion helpers from base `TestCase` classes. Extract those to `expect()->extend()` or
shared `beforeEach()` closures.

---

## Complete Feature Test Example

```php
<?php
// tests/Feature/OrderTest.php

use App\Events\OrderPlaced;
use App\Jobs\FulfillOrder;
use App\Models\Order;
use App\Models\User;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Queue;

uses()->group('orders');

beforeEach(function () {
    Queue::fake();
    Event::fake([OrderPlaced::class]);
});

it('creates an order for authenticated users', function () {
    $user = User::factory()->verified()->create();

    actingAs($user)
        ->postJson('/api/orders', ['product_id' => 42, 'quantity' => 2])
        ->assertCreated();

    expect(Order::where('user_id', $user->id)->count())->toBe(1);
    Queue::assertPushed(FulfillOrder::class);
    Event::assertDispatched(OrderPlaced::class);
});

it('rejects orders from unverified users', function () {
    actingAs(User::factory()->unverified()->create())
        ->postJson('/api/orders', ['product_id' => 42, 'quantity' => 1])
        ->assertForbidden();

    Queue::assertNothingPushed();
});

it('validates quantity range', function (int $qty, int $status) {
    actingAs(User::factory()->verified()->create())
        ->postJson('/api/orders', ['product_id' => 42, 'quantity' => $qty])
        ->assertStatus($status);
})->with([
    'zero'       => [0,   422],
    'one'        => [1,   201],
    'max'        => [100, 201],
    'over limit' => [101, 422],
]);
```
