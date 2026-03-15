---
name: php-testing
description: "Use this skill when writing PHP tests, choosing between PHPUnit and Pest, designing test architecture (unit/integration/E2E), creating mocks and stubs, writing data providers or datasets, setting up architecture testing with arch(), or configuring mutation testing with Infection. Covers PHPUnit 11 attributes, Pest 3 expect() API, and CI pipeline patterns."
---

# PHP Testing

## Test Architecture: The Test Pyramid

- **Unit tests (70-80%)** — Fast (< 1ms each), no I/O, test one behavioral unit. Run on every file save.
- **Integration tests (15-20%)** — Cross one system boundary (database, HTTP, filesystem). Run on every commit.
- **E2E tests (5-10%)** — Full system through UI or public API. Run pre-deploy or nightly.

> Principle: prefer the cheapest test that adequately covers the risk.

**Unit test candidates:** Pure functions, value objects, domain logic, service classes with mocked collaborators,
complex conditionals.

**Do NOT unit test:** Getters/setters with no logic, framework infrastructure, configuration, database schema.

**Integration test candidates:** Repository implementations, HTTP handlers, service coordination, event publishing.

### Directory Structure

Mirror source under `tests/` with separate suites (`unit`, `integration`, `feature`) in `phpunit.xml`. No unit test
should import a framework class.

---

## PHPUnit 11+

### Test Anatomy (Arrange / Act / Assert)

```php
// ❌ Bad — annotations removed in PHPUnit 11
/** @test */
public function it_calculates_tax(): void { ... }

// ✅ Good — PHP 8 attributes
#[Test]
public function it_calculates_tax(): void { ... }
```

```php
<?php
declare(strict_types=1);

namespace Tests\Unit\Billing;

use App\Billing\TaxCalculator;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

final class TaxCalculatorTest extends TestCase
{
    private TaxCalculator $calculator;

    protected function setUp(): void
    {
        $this->calculator = new TaxCalculator(rate: 0.20);
    }

    #[Test]
    public function it_applies_standard_rate(): void
    {
        self::assertSame(20_00, $this->calculator->calculate(100_00));
    }
}
```

Key rules: extend `TestCase` (not framework base classes), declare `final`, use `strict_types`, one logical assertion
per test.

### Naming

```php
// ❌ Bad — testCalculate(), test_calculate_method()
// ✅ Good — it_applies_standard_rate(), it_throws_for_negative_amount()
```

### Assertions

Prefer strict: `assertSame` (type + value) over `assertEquals` (loose). See references/phpunit.md for full list.

### Data Providers

```php
#[Test]
#[DataProvider('vatRateProvider')]
public function it_applies_rate(int $amount, float $rate, int $expected): void
{
    self::assertSame($expected, (new TaxCalculator($rate))->calculate($amount));
}

public static function vatRateProvider(): array
{
    return [
        'standard rate' => [100_00, 0.20, 20_00],
        'reduced rate'  => [100_00, 0.05, 5_00],
    ];
}
```

---

## Pest 3.x

Pest compiles `test()` / `it()` closures into anonymous `TestCase` subclasses on PHPUnit's runner. All PHPUnit tooling
works.

### Basic Syntax

```php
it('returns the full name', function () {
    expect((new User('Jane', 'Doe'))->fullName())->toBe('Jane Doe');
});

test('fullName concatenates first and last', function () {
    expect((new User('Jane', 'Doe'))->fullName())->toBe('Jane Doe');
});
```

Use `it()` when description completes "it ___". Use `test()` for imperative descriptions.

### `describe()` and Lifecycle

```php
describe('User', function () {
    beforeEach(fn () => $this->user = new User('Jane', 'Doe'));

    it('has a full name', function () {
        expect($this->user->fullName())->toBe('Jane Doe');
    });
});
```

Hooks: `beforeEach` = `setUp()`, `afterEach` = `tearDown()`, `beforeAll` = `setUpBeforeClass()`.

### `uses()` Configuration

```php
// tests/Pest.php
uses(TestCase::class, LazilyRefreshDatabase::class)->in('Feature');
uses(TestCase::class)->in('Unit');
```

### Expectations API (Key Methods)

```php
expect($value)->toBe('expected');         // strict ===
expect($value)->not->toBe('unexpected');  // negation
expect($value)->toBeInstanceOf(User::class);
expect($items)->toContain('banana')->toHaveCount(3);
expect($data)->toHaveKey('name')->toMatchArray(['role' => 'admin']);
expect('hello')->toStartWith('hel');
expect(fn () => risky())->toThrow(RuntimeException::class, 'message');
```

Chaining: `->and($other)->toBe(...)`. Iterate: `->each->toBeInt()`. See references/pest.md for full API.

### Custom Expectations

```php
expect()->extend('toBeValidEmail', function () {
    expect($this->value)->toMatch('/^[^@\s]+@[^@\s]+\.[^@\s]+$/');
    return $this;
});
```

### Datasets

```php
// Inline named
it('rejects invalid emails', function (string $email) {
    expect(isValidEmail($email))->toBeFalse();
})->with([
    'missing @' => 'notanemail',
    'double @'  => 'user@@example.com',
]);

// Shared (in Pest.php)
dataset('valid emails', ['a@b.com', 'user+tag@example.org']);
it('accepts emails', fn (string $e) => expect(isValidEmail($e))->toBeTrue())->with('valid emails');

// Cartesian product
it('formats', fn (string $l, string $c) => ...)->with(['en_US', 'de_DE'], ['USD', 'EUR']);
```

### Architecture Testing

Built into Pest 3 core. Enforces structural invariants in CI:

```php
arch('strict types')->expect('App')->toUseStrictTypes();
arch('no debug')->expect('App')->not->toUse(['dd', 'dump', 'var_dump']);
arch('models extend Eloquent')
    ->expect('App\Models')->toExtend('Illuminate\Database\Eloquent\Model');
arch('controllers are final')->expect('App\Http\Controllers')->toBeFinal();
arch('value objects readonly')->expect('App\Domain\ValueObjects')->toBeReadonly();

// Presets
arch()->preset()->laravel();
arch()->preset()->security();
```

Key rules: `toExtend()`, `toImplement()`, `toUseStrictTypes()`, `not->toUse()`, `toBeReadonly()`, `toBeFinal()`,
`toHaveSuffix()`, `toOnlyBeUsedIn()`, `toBeInterface()`, `toBeEnum()`.

### Test Modifiers

`->todo()`, `->skip(condition, 'reason')`, `->fails()`, `->group('name')`, `->only()`, `->repeat(n)`.

---

## Mocking Strategy

### Test Doubles Taxonomy

| Double    | PHPUnit API               | Purpose                                 |
|-----------|---------------------------|-----------------------------------------|
| **Stub**  | `createStub()`            | Returns canned value; no call assertion |
| **Mock**  | `createMock()`            | Asserts method IS called                |
| **Spy**   | Hand-written class        | Records calls for later assertion       |
| **Fake**  | Hand-written class        | Real implementation for testing only    |
| **Dummy** | `createStub()` (no setup) | Satisfies type; never called            |

### When to Mock

Mock across **architectural boundaries** (domain <-> external service, app <-> persistence, cross-module). Do NOT mock
same-layer collaborators, third-party libraries directly, or the thing being integration-tested.

```php
// ❌ Bad — mocking within the domain layer
$money = $this->createMock(Money::class);

// ✅ Good — mock the port, not the adapter
$gateway = $this->createStub(PaymentGatewayInterface::class);
$gateway->method('charge')->willReturn(ChargeResult::success());
```

### Over-Mocking Signs

More mock setup than assertions, mocking within same layer, testing call order when order isn't the behavior, mocking
cheap-to-instantiate concrete classes.

```php
// ❌ Bad — over-mocked
$item = $this->createMock(OrderItem::class);
$item->method('getPrice')->willReturn(10_00);
$order = $this->createMock(Order::class);
$order->method('getItems')->willReturn([$item]);

// ✅ Good — use real objects
$order = new Order([new OrderItem(price: 10_00, quantity: 2)]);
```

> **Rule:** Mock types you own at architectural boundaries. Use real objects or hand-written fakes everywhere else.

---

## Integration Testing

### Database Isolation

Wrap each test in a transaction, roll back in `tearDown()`. In Laravel: `RefreshDatabase` or `DatabaseTransactions`.

### Test Data Patterns

**Object Mother** — factory methods: `UserMother::active()`, `UserMother::withEmail('a@b.com')`.

**Test Builder** — fluent immutable API: `(new OrderBuilder())->withProduct(42)->build()`.

**Hand-written Fakes** — `InMemoryUserRepository` implementing the interface with an array store.

---

## Mutation Testing with Infection

Measures test **effectiveness**, not just coverage. Mutations are small deliberate code changes; surviving mutations =
test gaps.

### Setup

```bash
composer require --dev infection/infection
```

Key config: `"testFrameworkOptions": "--testsuite=unit"`, `"minMsi": 75`, `"minCoveredMsi": 85`, `"threads": "max"`.

### Running

```bash
vendor/bin/infection --min-msi=75 --min-covered-msi=85
# Incremental CI: only changed files
vendor/bin/infection --git-diff-filter=AM --git-diff-base=origin/main
```

### High-Value Mutators

- **ConditionalBoundary** (`>` -> `>=`): catches off-by-one
- **Logical** (`&&` -> `||`): catches wrong conditionals
- **Return** (returns null): catches untested returns
- **ArithmeticOperator** (`+` -> `-`): catches missing math assertions

### Thresholds

| Maturity    | minMsi | minCoveredMsi |
|-------------|--------|---------------|
| Greenfield  | 80%    | 90%           |
| Established | 70%    | 80%           |
| Legacy      | 50%    | 65%           |

---

## Anti-Patterns Summary

- Testing implementation details instead of behavior
- Testing getters/setters with no logic
- Magic numbers without context (`7200` vs `2 * 60 * 60`)
- Database state leaking between tests
- Integration tests replacing unit tests
- Over-mocking (more setup than assertions)
- Running Infection over integration tests (too slow)
- Targeting 100% MSI (some mutations are semantically equivalent)

---

## CI Pipeline

```yaml
- run: vendor/bin/phpunit --testsuite=unit          # every push
- run: vendor/bin/phpunit --testsuite=integration   # every PR
- run: vendor/bin/infection --git-diff-filter=AM --threads=max  # PR (incremental)
- run: vendor/bin/phpunit --testsuite=feature       # merge to main
```
