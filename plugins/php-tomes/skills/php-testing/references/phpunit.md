# PHPUnit 11+ Reference

## Table of Contents

- [Test Class Structure](#test-class-structure)
- [Attributes](#attributes)
- [Assertions](#assertions)
- [Test Doubles](#test-doubles)
- [Data Providers](#data-providers)
- [Lifecycle Methods](#lifecycle-methods)
- [Exception Testing](#exception-testing)
- [Configuration (phpunit.xml)](#configuration)

---

## Test Class Structure

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

Rules:

- Extend `TestCase` for unit tests
- `final` on test classes
- `declare(strict_types=1)` always
- Namespace mirrors source: `Tests\Unit\{SourceNamespace}`
- Class name: `{SubjectUnderTest}Test`

---

## Attributes

PHPUnit 11 removed docblock annotations. Use PHP 8 attributes:

| Attribute                          | Purpose                                        |
|------------------------------------|------------------------------------------------|
| `#[Test]`                          | Marks method as a test                         |
| `#[DataProvider('methodName')]`    | Parameterized test                             |
| `#[Depends('testName')]`           | Test dependency                                |
| `#[Group('name')]`                 | Test grouping                                  |
| `#[Before]`                        | Runs before each test (alternative to setUp)   |
| `#[After]`                         | Runs after each test (alternative to tearDown) |
| `#[BeforeClass]`                   | Runs once before all tests in class            |
| `#[AfterClass]`                    | Runs once after all tests in class             |
| `#[CoversClass(ClassName::class)]` | Coverage attribution                           |
| `#[UsesClass(ClassName::class)]`   | Declares used classes for coverage             |
| `#[RunInSeparateProcess]`          | Process isolation                              |
| `#[RequiresPhp('>=8.2')]`          | PHP version requirement                        |
| `#[RequiresPhpExtension('intl')]`  | Extension requirement                          |

---

## Assertions

### Strict vs Loose

```php
self::assertSame(42, $result);           // strict: type + value (preferred)
self::assertEquals(42, $result);          // loose: only value (avoid)
```

### Common Assertions

```php
// Value
self::assertSame($expected, $actual);
self::assertNotSame($unexpected, $actual);
self::assertTrue($condition);
self::assertFalse($condition);
self::assertNull($value);
self::assertNotNull($value);

// Type
self::assertInstanceOf(Order::class, $order);
self::assertIsArray($value);
self::assertIsString($value);
self::assertIsInt($value);
self::assertIsBool($value);

// String
self::assertStringContainsString('error', $message);
self::assertStringStartsWith('http', $url);
self::assertStringEndsWith('.php', $file);
self::assertMatchesRegularExpression('/^\d{4}$/', $code);

// Array
self::assertCount(3, $items);
self::assertArrayHasKey('id', $data);
self::assertContains('value', $array);
self::assertEmpty($collection);
self::assertNotEmpty($collection);

// Numeric
self::assertGreaterThan(0, $count);
self::assertGreaterThanOrEqual(1, $count);
self::assertLessThan(100, $percentage);

// JSON
self::assertJson($string);
self::assertJsonStringEqualsJsonString($expected, $actual);
```

---

## Test Doubles

### Stub — returns canned value, no call assertion

```php
$mailer = $this->createStub(MailerInterface::class);
$mailer->method('send')->willReturn(true);
```

### Mock — asserts method IS called

```php
$mailer = $this->createMock(MailerInterface::class);
$mailer->expects(self::once())
    ->method('send')
    ->with(self::isInstanceOf(WelcomeEmail::class));
```

### Partial mock — mock only specific methods

```php
$service = $this->getMockBuilder(NotificationService::class)
    ->onlyMethods(['sendEmail'])
    ->getMock();
```

### Expectation counts

```php
self::once()           // exactly 1 call
self::exactly(3)       // exactly 3 calls
self::atLeastOnce()    // 1 or more
self::never()          // 0 calls
self::any()            // any number (default)
```

### Argument matchers

```php
self::equalTo($value)
self::isInstanceOf(ClassName::class)
self::stringContains('substring')
self::callback(fn ($arg) => $arg > 0)
self::anything()
```

### Return configuration

```php
->willReturn($value)
->willReturnSelf()
->willReturnArgument(0)       // return first argument
->willReturnMap([[arg, return], ...])
->willThrowException(new \RuntimeException())
->willReturnCallback(fn ($arg) => $arg * 2)
```

---

## Data Providers

```php
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\Attributes\Test;

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
        'zero rate'     => [100_00, 0.00, 0],
    ];
}
```

Rules:

- Provider must be `public static`
- Named keys appear in failure output
- Return `array` or `Generator`

---

## Lifecycle Methods

```php
protected function setUp(): void          // before each test
protected function tearDown(): void       // after each test
public static function setUpBeforeClass(): void   // once before all tests
public static function tearDownAfterClass(): void // once after all tests
```

Or use attributes:

```php
#[Before]
protected function initDatabase(): void { ... }

#[After]
protected function cleanUp(): void { ... }
```

---

## Exception Testing

```php
#[Test]
public function it_throws_on_invalid_input(): void
{
    $this->expectException(InvalidArgumentException::class);
    $this->expectExceptionMessage('must be positive');
    $this->expectExceptionCode(422);

    $this->service->process(-1);
}
```

---

## Configuration

```xml
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php">
    <testsuites>
        <testsuite name="unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="integration">
            <directory>tests/Integration</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>src</directory>
        </include>
    </source>
    <php>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
    </php>
</phpunit>
```

### Running

```bash
vendor/bin/phpunit                         # all tests
vendor/bin/phpunit --testsuite=unit        # only unit suite
vendor/bin/phpunit --filter=TaxCalculator  # filter by name
vendor/bin/phpunit --group=slow            # filter by group
vendor/bin/phpunit --coverage-html=reports # coverage report
```
