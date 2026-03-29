# Pest 3.x Reference

## Table of Contents

- [Test Functions](#test-functions)
- [Expectations API](#expectations-api)
- [Datasets](#datasets)
- [Lifecycle & Configuration](#lifecycle--configuration)
- [Architecture Testing](#architecture-testing)
- [Test Modifiers](#test-modifiers)
- [Custom Expectations](#custom-expectations)
- [CLI Flags](#cli-flags)
- [Plugins](#plugins)

---

## Test Functions

```php
it('returns the full name', function () {
    expect((new User('Jane', 'Doe'))->fullName())->toBe('Jane Doe');
});

test('fullName concatenates first and last', function () {
    expect((new User('Jane', 'Doe'))->fullName())->toBe('Jane Doe');
});
```

`describe()` groups related tests with nested scope for hooks:

```php
describe('User', function () {
    it('has a name', fn () => expect(new User('Jane'))->name->toBe('Jane'));
});
```

---

## Expectations API

### Equality & Type

| Method                                                                      | Asserts      |
| --------------------------------------------------------------------------- | ------------ |
| `toBe($v)`                                                                  | Strict `===` |
| `toEqual($v)`                                                               | Loose `==`   |
| `toBeTrue()` / `toBeFalse()` / `toBeNull()` / `toBeEmpty()`                 | Truthiness   |
| `toBeInstanceOf($class)`                                                    | `instanceof` |
| `toBeArray()` / `toBeString()` / `toBeInt()` / `toBeFloat()` / `toBeBool()` | Type checks  |
| `toBeCallable()` / `toBeObject()` / `toBeNumeric()`                         | Type checks  |

### Numeric

| Method                                               | Asserts         |
| ---------------------------------------------------- | --------------- |
| `toBeGreaterThan($n)` / `toBeGreaterThanOrEqual($n)` | `>` / `>=`      |
| `toBeLessThan($n)` / `toBeLessThanOrEqual($n)`       | `<` / `<=`      |
| `toBeBetween($min, $max)`                            | Inclusive range |

### String

| Method                              | Asserts            |
| ----------------------------------- | ------------------ |
| `toContain($sub)`                   | Contains substring |
| `toStartWith($p)` / `toEndWith($s)` | Prefix / suffix    |
| `toMatch($regex)`                   | Regex match        |

### Array & Object

| Method                                     | Asserts              |
| ------------------------------------------ | -------------------- |
| `toContain($v)`                            | Array contains value |
| `toHaveCount($n)`                          | Count check          |
| `toHaveKey($k)` / `toHaveKeys([$k1, $k2])` | Key existence        |
| `toMatchArray($arr)`                       | Subset match         |
| `toHaveProperty($p)` / `toMatchObject($o)` | Object checks        |

### Exception

```php
expect(fn () => risky())->toThrow(RuntimeException::class, 'message');
expect(fn () => risky())->toThrow(function (RuntimeException $e) {
    expect($e->getCode())->toBe(503);
});
```

### Chaining & Iteration

```php
expect($user)->toBeInstanceOf(User::class)
    ->and($user->name)->toBe('Jane');           // and()

expect([2, 4, 6])->each->toBeInt();             // each()

expect(['a', 'b'])->sequence(                   // sequence()
    fn ($v) => $v->toBe('a'),
    fn ($v) => $v->toBe('b'),
);

expect($r)->when($isProd, fn ($e) => $e->not->toContain('debug'));  // when()
```

Negation: `->not->toBe(...)` on any expectation.

---

## Datasets

```php
// Inline
it('validates', fn (string $e) => ...)->with(['a@b.com', 'x@y.org']);

// Named inline
->with(['missing @' => 'bad', 'double @' => 'a@@b.com']);

// Multi-argument
->with([[100.0, 0.10, 90.0], [200.0, 0.25, 150.0]]);

// Shared (in Pest.php)
dataset('emails', ['a@b.com', 'x@y.org']);
it('validates', fn (string $e) => ...)->with('emails');

// Lazy (generator)
dataset('csv', function () { /* yield rows from file */ });

// Cartesian product
->with(['en_US', 'de_DE'], ['USD', 'EUR']);  // 4 combinations
```

---

## Lifecycle & Configuration

```php
beforeEach(function () { $this->service = new Service(); });
afterEach(function () { /* cleanup */ });
beforeAll(function () { /* static context only */ });
afterAll(function () { /* static context only */ });
```

### uses() in tests/Pest.php

```php
uses(TestCase::class, RefreshDatabase::class)->in('Feature');
uses(TestCase::class)->in('Unit');
uses()->group('slow')->in('Feature/SlowTests');
uses(TestCase::class)->beforeEach(fn () => $this->artisan('db:seed'))->in('Feature');
```

Global helpers:

```php
function createUser(array $attrs = []): User {
    return User::factory()->create($attrs);
}
```

---

## Architecture Testing

```php
arch('strict types')->expect('App')->toUseStrictTypes();
arch('no debug')->expect('App')->not->toUse(['dd', 'dump', 'var_dump']);
arch('models extend Eloquent')->expect('App\Models')->toExtend(Model::class);
arch('controllers final')->expect('App\Http\Controllers')->toBeFinal();
arch('VOs readonly')->expect('App\Domain\ValueObjects')->toBeReadonly();
arch('jobs queued')->expect('App\Jobs')->toImplement(ShouldQueue::class)->ignoring('App\Jobs\Sync');
```

### Rules

| Rule                                                | Asserts                   |
| --------------------------------------------------- | ------------------------- |
| `toExtend($c)` / `toImplement($i)`                  | Inheritance               |
| `toUseStrictTypes()`                                | `declare(strict_types=1)` |
| `not->toUse($ns)`                                   | No imports from namespace |
| `toBeReadonly()` / `toBeFinal()` / `toBeAbstract()` | Class modifiers           |
| `toBeInterface()` / `toBeEnum()` / `toBeTrait()`    | Type kind                 |
| `toHaveSuffix($s)` / `toHavePrefix($p)`             | Naming                    |
| `toOnlyBeUsedIn($ns)` / `toOnlyUse($deps)`          | Dependency direction      |
| `toHaveMethod($name)`                               | Method existence          |
| `->ignoring($ns)`                                   | Exclude from rule         |

### Presets

`arch()->preset()->php()`, `->security()`, `->laravel()`, `->relaxed()`.

---

## Test Modifiers

| Modifier                              | Purpose          |
| ------------------------------------- | ---------------- |
| `->todo()`                            | Incomplete       |
| `->skip()` / `->skip(bool, 'reason')` | Skip             |
| `->group('name')`                     | Group            |
| `->throws(Exception::class)`          | Expect exception |
| `->fails()`                           | Known failure    |
| `->only()`                            | Focus mode       |
| `->repeat(n)`                         | Stress test      |
| `->depends('name')`                   | Dependency       |

---

## Custom Expectations

```php
expect()->extend('toBeValidEmail', function () {
    expect($this->value)->toMatch('/^[^@\s]+@[^@\s]+\.[^@\s]+$/');
    return $this;
});

expect()->extend('toHaveStatusCode', function (int $code) {
    expect($this->value->getStatusCode())->toBe($code);
    return $this;
});
```

Higher-order: `expect($user)->name->toBe('Jane')->active->toBeTrue();`

---

## CLI Flags

| Flag                                             | Purpose                   |
| ------------------------------------------------ | ------------------------- |
| `--parallel` / `--processes=N`                   | Parallel execution        |
| `--coverage` / `--coverage-html=dir` / `--min=N` | Coverage                  |
| `--type-coverage` / `--min=100`                  | Type declaration coverage |
| `--watch`                                        | File-watch re-runner      |
| `--drift`                                        | PHPUnit to Pest migration |
| `--filter=pattern` / `--group=name`              | Test filtering            |
| `--bail`                                         | Stop on first failure     |
| `--retry`                                        | Re-run failed only        |
| `--ci`                                           | CI output                 |
| `--profile`                                      | Show slowest tests        |

---

## Plugins

| Plugin                           | Purpose                                           |
| -------------------------------- | ------------------------------------------------- |
| `pest-plugin-laravel`            | HTTP/auth/artisan helpers (`get()`, `actingAs()`) |
| `pest-plugin-watch`              | File-watch re-runner                              |
| `pest-plugin-drift`              | PHPUnit migration codemod                         |
| `pest-plugin-type-coverage`      | Type declaration coverage                         |
| `pest-plugin-stressless`         | Load/stress testing                               |
| `pest-plugin-parallel` (bundled) | Parallel execution                                |
| `pest-plugin-arch` (bundled)     | Architecture testing                              |
