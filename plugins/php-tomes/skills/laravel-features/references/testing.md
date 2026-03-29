# Laravel Testing Reference

## Table of Contents

- [HTTP Test Methods](#http-test-methods)
- [Response Assertions](#response-assertions)
- [JSON Assertions](#json-assertions)
- [Database Assertions](#database-assertions)
- [Authentication Helpers](#authentication-helpers)
- [Facade Fakes](#facade-fakes)
- [File Upload Testing](#file-upload-testing)
- [Time Manipulation](#time-manipulation)
- [Database Traits](#database-traits)
- [Model Factories](#model-factories)

---

## HTTP Test Methods

```php
$this->get('/url');
$this->post('/url', $data);
$this->put('/url', $data);
$this->patch('/url', $data);
$this->delete('/url');

// JSON variants (set Content-Type + Accept headers)
$this->getJson('/api/url');
$this->postJson('/api/url', $data);
$this->putJson('/api/url', $data);
$this->patchJson('/api/url', $data);
$this->deleteJson('/api/url');

// With headers
$this->get('/url', ['Accept' => 'application/json']);
```

## Response Assertions

### Status

| Method                  | Code      |
| ----------------------- | --------- |
| `assertOk()`            | 200       |
| `assertCreated()`       | 201       |
| `assertAccepted()`      | 202       |
| `assertNoContent()`     | 204       |
| `assertNotFound()`      | 404       |
| `assertForbidden()`     | 403       |
| `assertUnauthorized()`  | 401       |
| `assertUnprocessable()` | 422       |
| `assertStatus(418)`     | arbitrary |

### Redirect

```php
$response->assertRedirect('/dashboard');
$response->assertRedirectToRoute('home');
$response->assertRedirectContains('/password');
```

### View & Content

```php
$response->assertViewIs('users.index');
$response->assertViewHas('users');
$response->assertViewHas('users', fn ($u) => $u->count() === 3);
$response->assertSee('Welcome');
$response->assertSeeText('Welcome');    // strips HTML
$response->assertDontSee('Error');
$response->assertSeeInOrder(['First', 'Second']);
```

### Session & Cookie

```php
$response->assertSessionHas('status', 'Updated');
$response->assertSessionHasErrors(['name', 'email']);
$response->assertSessionMissing('error');
$response->assertCookie('token');
$response->assertCookieMissing('debug');
```

## JSON Assertions

```php
$response->assertJson(['name' => 'Alice']);              // partial match
$response->assertExactJson(['id' => 1, 'name' => 'A']); // exact match
$response->assertJsonFragment(['email' => 'a@b.com']);
$response->assertJsonMissing(['password']);
$response->assertJsonCount(3, 'data');
$response->assertJsonPath('data.0.name', 'Alice');
$response->assertJsonStructure([
    'data' => ['*' => ['id', 'name']],
    'meta' => ['total'],
]);
$response->assertJsonValidationErrors(['name']);
$response->assertJsonValidationErrorFor('name');
```

## Database Assertions

```php
$this->assertDatabaseHas('users', ['email' => 'a@b.com']);
$this->assertDatabaseMissing('users', ['email' => 'x@b.com']);
$this->assertDatabaseCount('users', 5);
$this->assertDatabaseEmpty('tokens');
$this->assertModelExists($user);
$this->assertModelMissing($user);
$this->assertSoftDeleted($post);
$this->assertNotSoftDeleted($post);
```

JSON column assertions:

```php
$this->assertDatabaseHas('users', [
    'settings->notifications->email' => true,
]);
```

## Authentication Helpers

```php
$this->actingAs($user)->get('/dashboard');
$this->actingAs($user, 'sanctum')->getJson('/api/profile');
$this->assertAuthenticated();
$this->assertAuthenticatedAs($user);
$this->assertGuest();
```

## Facade Fakes

### Bus::fake (Jobs)

```php
Bus::fake();
Bus::fake([SpecificJob::class]);  // only fake specific jobs
Bus::assertDispatched(Job::class, fn ($j) => $j->id === 42);
Bus::assertNotDispatched(Job::class);
Bus::assertNothingDispatched();
Bus::assertBatched(fn ($batch) => $batch->jobs->count() === 3);
```

### Mail::fake

```php
Mail::fake();
Mail::assertSent(WelcomeMail::class, fn ($m) => $m->hasTo('a@b.com'));
Mail::assertQueued(WelcomeMail::class);
Mail::assertSentCount(1);
Mail::assertNothingSent();
```

### Event::fake

```php
Event::fake();
Event::fake([UserRegistered::class]);  // selective
Event::assertDispatched(Event::class);
Event::assertDispatchedTimes(Event::class, 1);
Event::assertNotDispatched(Event::class);
Event::assertNothingDispatched();
```

Scoped: `Event::fakeFor(fn () => /* code */);`

### Queue::fake

```php
Queue::fake();
Queue::assertPushed(Job::class);
Queue::assertPushedOn('queue-name', Job::class);
Queue::assertCount(1);
Queue::assertNothingPushed();
```

### Notification::fake

```php
Notification::fake();
Notification::assertSentTo($user, OrderShipped::class);
Notification::assertSentOnDemand(Invoice::class);
Notification::assertNothingSent();
```

### Storage::fake

```php
Storage::fake('disk-name');
Storage::disk('disk-name')->assertExists('path/file.jpg');
Storage::disk('disk-name')->assertMissing('path/other.jpg');
```

### Http::fake

```php
Http::fake(['api.example.com/*' => Http::response(['key' => 'val'], 200)]);
Http::fake(['api.stripe.com/*' => Http::sequence()
    ->push(['status' => 'pending'], 202)
    ->push(['status' => 'done'], 200)
]);
Http::fake();  // catch-all empty 200
Http::assertSent(fn ($req) => str_contains($req->url(), 'example.com'));
```

### Broadcast::fake

```php
Broadcast::fake();
Broadcast::assertBroadcasted(OrderUpdated::class, fn ($e) =>
    $e->broadcastWith()['status'] === 'shipped'
);
```

## File Upload Testing

```php
$file = UploadedFile::fake()->image('avatar.jpg', 200, 200);
$file = UploadedFile::fake()->create('doc.pdf', 1024);
$file = UploadedFile::fake()->create('data.csv', 512, 'text/csv');
$file = UploadedFile::fake()->image('photo.png')->size(500);  // 500 KB
```

Always call `Storage::fake()` before the action under test.

## Time Manipulation

```php
$this->travel(5)->days();
$this->travel(61)->minutes();
$this->travelTo(Carbon::parse('2024-01-01'));
$this->travelBack();

// Raw Carbon
Carbon::setTestNow(Carbon::parse('2024-01-01'));
Carbon::setTestNow();  // reset
```

Methods: `->seconds()`, `->minutes()`, `->hours()`, `->days()`, `->weeks()`,
`->years()`.

Laravel auto-resets `Carbon::setTestNow()` after each test.

## Database Traits

| Trait                  | Speed   | Mechanism                          |
| ---------------------- | ------- | ---------------------------------- |
| `RefreshDatabase`      | Fast    | Migrate once, transaction per test |
| `DatabaseTransactions` | Fastest | Transaction only (no migration)    |
| `DatabaseMigrations`   | Slowest | Migrate + rollback per class       |

Seed with RefreshDatabase: `protected bool $seed = true;` or
`protected string $seeder = RolesSeeder::class;`.

## Model Factories

```php
User::factory()->create();              // persist
User::factory()->make();                // no persist
User::factory()->count(5)->create();
User::factory()->create(['role' => 'admin']);  // override

// States
User::factory()->unverified()->create();
User::factory()->admin()->suspended()->create();

// Sequences
User::factory()->count(3)->sequence(
    ['role' => 'admin'], ['role' => 'editor'], ['role' => 'viewer']
)->create();

// Relationships
User::factory()->has(Post::factory()->count(3))->create();
User::factory()->hasPosts(3, ['status' => 'published'])->create();
Post::factory()->for($user)->create();
Post::factory()->hasAttached(Tag::factory()->count(3), ['created_by' => 1])->create();
```

Factory callbacks:

```php
public function configure(): static
{
    return $this->afterCreating(fn (User $u) => $u->profile()->create([...]));
}
```
