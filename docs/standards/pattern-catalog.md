# Code Pattern Catalog

Approved patterns and banned anti-patterns for all agent-produced code. Agents reference by ID. Pattern selection
happens at architecture; enforcement happens at review.

## Agents: How to Reference

- **Architect**: Select patterns during design; justify in architecture-design.md
- **Engineer**: Implement approved patterns; flag if task requires unlisted pattern
- **Gremlin (Standards Auditor)**: Flag anti-patterns; verify approved pattern usage

---

## Approved Patterns

### Structural

| ID     | Pattern        | Description                                       |
| ------ | -------------- | ------------------------------------------------- |
| PAT-01 | Repository     | Data access abstraction behind interface          |
| PAT-02 | Service Layer  | Business logic coordination across repositories   |
| PAT-03 | DTO            | Boundary data shaping between layers              |
| PAT-04 | Value Object   | Immutable domain primitive with equality by value |
| PAT-05 | Aggregate Root | Consistency boundary for related entities         |

**PAT-01 Repository** Use when: decoupling domain logic from storage implementation.

```
interface UserRepository {
  find(id): User
  save(user): void
}
class DbUserRepository implements UserRepository {
  find(id): User { return db.query("...where id=?", id) }
  save(user): void { db.upsert("users", user.toRow()) }
}
```

**PAT-02 Service Layer** Use when: operation spans multiple repositories or triggers side effects.

```
class OrderService {
  constructor(orders, inventory, events)
  place(dto): Order {
    inventory.reserve(dto.items)
    order = orders.create(dto)
    events.dispatch(OrderPlaced(order))
    return order
  }
}
```

**PAT-03 DTO** Use when: crossing boundary (API response, service input, queue payload).

```
class CreateUserDTO {
  readonly name: string
  readonly email: string
  static fromRequest(req): CreateUserDTO {
    return new CreateUserDTO(req.name, req.email)
  }
}
```

**PAT-04 Value Object** Use when: concept has no identity, only value (money, email, coordinates).

```
class Money {
  constructor(readonly amount: int, readonly currency: string)
  equals(other): bool { return amount == other.amount && currency == other.currency }
  add(other): Money {
    assert(currency == other.currency)
    return new Money(amount + other.amount, currency)
  }
}
```

**PAT-05 Aggregate Root** Use when: group of entities must change together atomically.

```
class Order {  // Aggregate Root
  private items: OrderItem[]
  addItem(product, qty): void {
    this.items.push(new OrderItem(product, qty))
    this.updatedAt = now()
  }
  // All changes to OrderItem go through Order
}
```

### Behavioral

| ID     | Pattern         | Description                                  |
| ------ | --------------- | -------------------------------------------- |
| PAT-06 | Strategy        | Swappable algorithms behind common interface |
| PAT-07 | Observer/Event  | Decoupled notifications on state change      |
| PAT-08 | Command/Handler | Encapsulated operation with single handler   |
| PAT-09 | Pipeline/Chain  | Sequential transformations on input          |
| PAT-10 | Specification   | Composable business rules as objects         |

**PAT-06 Strategy** Use when: algorithm varies by context (pricing, sorting, auth).

```
interface PricingStrategy { calculate(order): Money }
class StandardPricing implements PricingStrategy { ... }
class BulkPricing implements PricingStrategy { ... }
service.checkout(order, strategy)
```

**PAT-07 Observer/Event** Use when: action triggers side effects that shouldn't couple to the caller.

```
events.listen(OrderPlaced, SendConfirmationEmail)
events.listen(OrderPlaced, UpdateInventory)
events.listen(OrderPlaced, NotifyWarehouse)
// OrderService dispatches OrderPlaced; knows nothing about listeners
```

**PAT-08 Command/Handler** Use when: operations need queuing, logging, or undo.

```
class CreateUser { name: string; email: string }
class CreateUserHandler {
  handle(cmd: CreateUser): User {
    user = User.create(cmd.name, cmd.email)
    repo.save(user)
    return user
  }
}
bus.dispatch(new CreateUser("Alice", "a@b.com"))
```

**PAT-09 Pipeline/Chain** Use when: input passes through ordered transformation steps.

```
result = pipeline(rawInput)
  .pipe(validate)
  .pipe(normalize)
  .pipe(enrich)
  .pipe(persist)
  .execute()
```

**PAT-10 Specification** Use when: business rules compose (filter, validate, query).

```
class ActiveUser implements Spec { isSatisfiedBy(u): bool { return u.active } }
class PremiumUser implements Spec { isSatisfiedBy(u): bool { return u.tier == "premium" } }
activePremium = ActiveUser().and(PremiumUser())
users.filter(u => activePremium.isSatisfiedBy(u))
```

### Resilience

| ID     | Pattern            | Description                          |
| ------ | ------------------ | ------------------------------------ |
| PAT-11 | Circuit Breaker    | Fail-fast on degraded dependency     |
| PAT-12 | Retry with Backoff | Transient failure recovery           |
| PAT-13 | Bulkhead           | Resource isolation between consumers |
| PAT-14 | Timeout            | Bounded wait on external calls       |
| PAT-15 | Fallback           | Degraded-mode response on failure    |

**PAT-11 Circuit Breaker** Use when: dependency fails repeatedly; continuing wastes resources.

```
breaker = CircuitBreaker(threshold=5, resetTimeout=30s)
result = breaker.call(() => externalApi.fetch(id))
// CLOSED -> calls pass through
// OPEN (after 5 failures) -> immediate error, no call
// HALF-OPEN (after 30s) -> one probe call to test recovery
```

**PAT-12 Retry with Backoff** Use when: transient failures (network blips, rate limits, locks).

```
retry(maxAttempts=3, backoff=exponential(base=100ms, max=5s)) {
  return httpClient.post(url, payload)
}
// Attempt 1: immediate
// Attempt 2: wait 100ms
// Attempt 3: wait 200ms
```

**PAT-13 Bulkhead** Use when: one consumer must not exhaust shared resources.

```
pool_critical = ConnectionPool(max=20)  // payment processing
pool_reports  = ConnectionPool(max=5)   // background reports
// Reports spike cannot starve payment processing
```

**PAT-14 Timeout** Use when: any external call (API, DB, file, queue).

```
result = withTimeout(3000ms) {
  externalService.query(params)
}
// Throws TimeoutError after 3s — never hang indefinitely
```

**PAT-15 Fallback** Use when: degraded response is better than error.

```
function getPrice(productId): Money {
  try { return pricingService.fetch(productId) }
  catch { return cache.get("price:" + productId) ?? defaultPrice }
}
```

### Data

| ID     | Pattern           | Description                                         |
| ------ | ----------------- | --------------------------------------------------- |
| PAT-16 | Unit of Work      | Atomic multi-step persistence                       |
| PAT-17 | Cursor Pagination | Efficient large dataset traversal                   |
| PAT-18 | Idempotency Key   | Safe retry for mutations                            |
| PAT-19 | Soft Delete       | Reversible record removal                           |
| PAT-20 | Event Sourcing    | State as event log (only when audit trail required) |

**PAT-16 Unit of Work** Use when: multiple writes must succeed or fail together.

```
uow = UnitOfWork.begin()
uow.register(order)
uow.register(payment)
uow.register(inventoryUpdate)
uow.commit()  // single transaction
```

**PAT-17 Cursor Pagination** Use when: paginating large or frequently-changing datasets.

```
// Request:  GET /items?after=cursor_abc&limit=20
// Response: { data: [...], next_cursor: "cursor_def" }
// Never use OFFSET for user-facing pagination on large tables
```

**PAT-18 Idempotency Key** Use when: client may retry a mutation (payments, order creation).

```
// Client sends: X-Idempotency-Key: uuid-123
function create(key, payload):
  existing = idempotencyStore.get(key)
  if existing: return existing.response
  result = process(payload)
  idempotencyStore.set(key, result, ttl=24h)
  return result
```

**PAT-19 Soft Delete** Use when: data must be recoverable or has referential dependents.

```
// Column: deleted_at TIMESTAMP NULL
function delete(id): void {
  record.deleted_at = now()
  record.save()
}
// Global scope excludes deleted_at IS NOT NULL by default
```

**PAT-20 Event Sourcing** Use when: audit trail, temporal queries, or undo required. Do NOT use by default.

```
// Store events, not state
ledger.append(AccountOpened { id, owner, timestamp })
ledger.append(MoneyDeposited { id, amount, timestamp })
ledger.append(MoneyWithdrawn { id, amount, timestamp })
// Current state = replay(events)
```

### Concurrency

| ID     | Pattern                     | Description                        |
| ------ | --------------------------- | ---------------------------------- |
| PAT-21 | Optimistic Locking          | Version-based conflict detection   |
| PAT-22 | Queue Worker                | Async processing with backpressure |
| PAT-23 | Rate Limiter (Token Bucket) | Throughput control                 |

**PAT-21 Optimistic Locking** Use when: concurrent edits possible but conflicts rare.

```
function update(id, changes):
  record = db.find(id)  // version=3
  record.apply(changes)
  rows = db.updateWhere(id, version=3, set={...changes, version=4})
  if rows == 0: throw ConflictError("stale version")
```

**PAT-22 Queue Worker** Use when: work can be deferred; throughput must be controlled.

```
// Producer
queue.push(SendWelcomeEmail { userId: 42 })
// Consumer
worker = Worker(queue, concurrency=5, retries=3)
worker.process(job => emailService.send(job.userId))
// Backpressure: concurrency cap + queue depth limits
```

**PAT-23 Rate Limiter (Token Bucket)** Use when: protecting endpoints or external API calls from overuse.

```
limiter = TokenBucket(capacity=100, refillRate=10/sec)
function handleRequest(req):
  if !limiter.tryConsume(1): return 429 Too Many Requests
  return process(req)
```

---

## Anti-Patterns

| ID      | Anti-Pattern                    | Why Banned                                                            | Use Instead                                                 |
| ------- | ------------------------------- | --------------------------------------------------------------------- | ----------------------------------------------------------- |
| ANTI-01 | God Object/Class                | Does everything, knows everything. Untestable, unchangeable.          | PAT-02 Service Layer + single-responsibility classes        |
| ANTI-02 | Service Locator                 | Hidden dependencies. Tests break, refactors surprise.                 | Constructor injection                                       |
| ANTI-03 | Anemic Domain Model             | Logic lives outside the model. Domain objects become data bags.       | PAT-04/PAT-05 — push logic into domain objects              |
| ANTI-04 | Stringly-Typed Interface        | Strings where enums/types belong. Typos become runtime bugs.          | Enums, typed constants, value objects (PAT-04)              |
| ANTI-05 | Premature Abstraction           | Abstraction for one use case. Adds indirection without payoff.        | Inline first. Extract at 2nd or 3rd use.                    |
| ANTI-06 | N+1 Query                       | Queries in loops. O(n) round trips for one logical fetch.             | Eager load, join, batch query                               |
| ANTI-07 | Catch-All Exception Handler     | Swallows everything. Masks bugs, blocks recovery.                     | Catch specific types. Let unknown errors propagate.         |
| ANTI-08 | Boolean Parameter               | Hidden function modes. Caller intent invisible at call site.          | Separate functions, enum, or options object                 |
| ANTI-09 | Deep Inheritance                | >2 levels. Fragile base class problem. Changes cascade unpredictably. | Composition, interfaces, mixins/traits                      |
| ANTI-10 | Singleton Abuse                 | Global mutable state disguised as a pattern. Couples everything.      | Dependency injection with scoped lifetime                   |
| ANTI-11 | Magic String Configuration      | Config keys as scattered string literals. Rename = silent breakage.   | Typed config objects, constants, env validation at boot     |
| ANTI-12 | Train Wreck (Demeter Violation) | `a.b.c.d.e()` chains. Couples caller to deep structure.               | Encapsulate traversal behind a method on the nearest object |
