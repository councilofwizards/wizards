# Test Architecture Reference

## Table of Contents

- [Test Pyramid](#test-pyramid)
- [Boundaries by Level](#boundaries-by-level)
- [Directory Structure](#directory-structure)
- [Mocking Decision Guide](#mocking-decision-guide)
- [Test Data Patterns](#test-data-patterns)
- [Database Isolation](#database-isolation)
- [Mutation Testing](#mutation-testing)
- [CI Pipeline](#ci-pipeline)
- [Test Smells](#test-smells)

---

## Test Pyramid

```
        /\
       / E2E \         5-10% — slow, expensive
     /----------\
    / Integration \    15-20% — medium speed
   /----------------\
  /   Unit Tests     \ 70-80% — fast, cheap, many
 /--------------------\
```

---

## Boundaries by Level

### Unit: < 1ms, no I/O, run on file save

Test: pure functions, value objects, domain logic, service classes (mocked deps), complex conditionals.

Skip: getters/setters, framework infra, config, DB schema.

### Integration: 10-500ms, run on commit/PR

Test: repositories, HTTP handlers, service coordination, event pub/sub.

### E2E: 1-30s, run pre-deploy or nightly

Test: critical user journeys, deployment smoke tests, feature acceptance.

---

## Directory Structure

```
tests/
  Unit/Domain/Order/OrderTest.php
  Integration/Infrastructure/Persistence/DoctrineOrderRepoTest.php
  Feature/Order/PlaceOrderTest.php
```

```xml
<testsuites>
    <testsuite name="unit"><directory>tests/Unit</directory></testsuite>
    <testsuite name="integration"><directory>tests/Integration</directory></testsuite>
    <testsuite name="feature"><directory>tests/Feature</directory></testsuite>
</testsuites>
```

Naming: `{Subject}Test` class, `it_{behavior}` methods.

---

## Mocking Decision Guide

| Boundary                     | Mock?  | Example                        |
| ---------------------------- | ------ | ------------------------------ |
| Domain <-> external service  | Yes    | Mailer, payment, SMS           |
| App <-> persistence          | Yes    | Repository interface           |
| Cross-module                 | Yes    | Module A -> Module B           |
| Same-layer collaborators     | **No** | Value objects, domain services |
| Third-party library directly | **No** | Mock your own interface        |
| Integration target           | **No** | Use real implementation        |

### Double Selection

| Need                                   | Use                                  |
| -------------------------------------- | ------------------------------------ |
| Return a value, don't care about calls | **Stub** (`createStub()`)            |
| Verify method IS called                | **Mock** (`createMock()`)            |
| Record calls, assert later             | **Spy** (hand-written)               |
| Real logic without I/O                 | **Fake** (hand-written)              |
| Satisfy type, never called             | **Dummy** (`createStub()`, no setup) |

---

## Test Data Patterns

### Object Mother

```php
final class UserMother
{
    public static function active(): User
    {
        return new User(id: UserId::generate(), email: 'user@example.com', status: UserStatus::Active);
    }
}
```

### Test Builder (Immutable)

```php
final class OrderBuilder
{
    private int $productId = 1;
    private ?Coupon $coupon = null;

    public function withProduct(int $id): self { $c = clone $this; $c->productId = $id; return $c; }
    public function withCoupon(Coupon $c): self { $cl = clone $this; $cl->coupon = $c; return $cl; }
    public function build(): Order { return new Order($this->productId, 1, $this->coupon); }
}
```

### Hand-Written Fake

```php
final class InMemoryUserRepository implements UserRepositoryInterface
{
    private array $users = [];
    public function save(User $u): void { $this->users[$u->id()->toString()] = $u; }
    public function findById(UserId $id): ?User { return $this->users[$id->toString()] ?? null; }
}
```

### Hand-Written Spy

```php
final class SpyEventDispatcher implements EventDispatcherInterface
{
    private array $dispatched = [];
    public function dispatch(object $e): object { $this->dispatched[] = $e; return $e; }
    public function dispatched(string $class): array {
        return array_filter($this->dispatched, fn ($e) => $e instanceof $class);
    }
}
```

---

## Database Isolation

| Strategy             | Speed  | Default?                    |
| -------------------- | ------ | --------------------------- |
| Transaction rollback | Fast   | Yes                         |
| Schema recreation    | Slow   | Only if tests modify schema |
| Separate test DB     | Medium | MySQL/Postgres integration  |

```php
protected function setUp(): void { self::$em->beginTransaction(); }
protected function tearDown(): void { self::$em->rollback(); }
```

Laravel: `RefreshDatabase`, `DatabaseTransactions`, `LazilyRefreshDatabase`.

---

## Mutation Testing

### Infection Config

```json5
{
  source: { directories: ["src"] },
  mutators: { "@default": true },
  testFrameworkOptions: "--testsuite=unit",
  minMsi: 75,
  minCoveredMsi: 85,
  threads: "max",
}
```

### Key Mutators

| Mutator                           | Catches                 |
| --------------------------------- | ----------------------- |
| ConditionalBoundary (`>` -> `>=`) | Off-by-one              |
| Logical (`&&` -> `\|\|`)          | Wrong conditionals      |
| Return (returns null)             | Untested returns        |
| ArithmeticOperator (`+` -> `-`)   | Missing math assertions |
| Void (removes call)               | Unasserted side effects |

### Thresholds

| Maturity    | minMsi | minCoveredMsi |
| ----------- | ------ | ------------- |
| Greenfield  | 80%    | 90%           |
| Established | 70%    | 80%           |
| Legacy      | 50%    | 65%           |

---

## CI Pipeline

```yaml
- run: vendor/bin/phpunit --testsuite=unit # every push
- run: vendor/bin/phpunit --testsuite=integration # every PR
- run: vendor/bin/infection --git-diff-filter=AM --git-diff-base=origin/${{ github.base_ref }} --threads=max # PR
- run: vendor/bin/phpunit --testsuite=feature # merge to main
```

---

## Test Smells

| Smell                              | Fix                            |
| ---------------------------------- | ------------------------------ |
| Unit test > 10ms                   | Remove I/O dependency          |
| Order-dependent tests              | Use setUp() for fresh state    |
| Mystery guest (invisible fixtures) | Set up data in the test        |
| Fragile mocks (break on rename)    | Mock at boundaries only        |
| Integration test = full journey    | Move to E2E                    |
| Magic numbers                      | Use expressions: `2 * 60 * 60` |
| Testing getters/setters            | Delete — no logic, no value    |
| More mock setup than assertions    | Use real objects or fakes      |
