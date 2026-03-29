---
name: php-data-apis
description:
  "Use this skill when writing PDO queries, designing database migrations,
  choosing between Active Record and Data Mapper, implementing the Repository
  pattern, building REST APIs, versioning endpoints, serializing responses with
  DTOs, or adding rate limiting. Covers prepared statements, transactions,
  zero-downtime DDL, RFC 7807 errors, cursor pagination, and PSR-15 middleware."
---

# PHP Database & API Design

## PDO Fundamentals

### Connection Setup

```php
// ❌ Bad — silent errors, emulated prepares, no charset
$pdo = new PDO('mysql:host=localhost;dbname=app', $user, $pass);

// ✅ Good — exceptions, native prepares, utf8mb4
$pdo = new PDO('mysql:host=127.0.0.1;dbname=app;charset=utf8mb4', $user, $pass, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
    PDO::ATTR_PERSISTENT         => false,
]);
```

Mandatory: `ERRMODE_EXCEPTION`, `EMULATE_PREPARES => false`, `charset=utf8mb4`
in DSN (never `SET NAMES`).

### Parameterized Queries

```php
// ❌ Bad — SQL injection (OWASP A03:2021)
$rows = $pdo->query("SELECT * FROM users WHERE id = $id")->fetchAll();

// ✅ Good — positional or named parameters
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$id]);

$stmt = $pdo->prepare("UPDATE users SET email = :email WHERE id = :id");
$stmt->execute([':email' => $email, ':id' => $id]);
```

### Type Binding and Dynamic Queries

```php
// ❌ Bad — bindParam in loop (reference bug: all rows get last value)
foreach ($ids as $id) { $stmt->bindParam(':id', $id); $stmt->execute(); }

// ✅ Good — bindValue copies immediately
foreach ($ids as $id) { $stmt->bindValue(':id', $id, PDO::PARAM_INT); $stmt->execute(); }

// ❌ Bad — IN clause via implode (injection)
$pdo->query("SELECT * FROM products WHERE id IN (" . implode(',', $ids) . ")");

// ✅ Good — generated placeholders
$ph = implode(',', array_fill(0, count($ids), '?'));
$stmt = $pdo->prepare("SELECT * FROM products WHERE id IN ($ph)");
$stmt->execute($ids);

// ✅ Good — allowlist for dynamic identifiers (columns/tables)
$allowed = ['name', 'email', 'created_at'];
$col = in_array($_GET['sort'], $allowed, true) ? $_GET['sort'] : 'created_at';
```

Use `PDO::PARAM_INT` for LIMIT/OFFSET when emulated prepares are off.

### Fetch Strategies

```php
$row  = $stmt->fetch();                              // single row (FETCH_ASSOC default)
$rows = $stmt->fetchAll(PDO::FETCH_CLASS, Dto::class); // hydrate into class
$val  = $stmt->fetchColumn();                        // single column value
$map  = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);        // [key => value] map
```

### Query Builders

For complex queries, prefer a builder over manual string construction:
`doctrine/dbal` (mature, type-safe, schema introspection), `cakephp/database`
(lightweight, standalone), `latitude/latitude` (purely functional, immutable).

## Transactions

```php
// ✅ Good — proper transaction with rollback
$pdo->beginTransaction();
try {
    $pdo->prepare("INSERT INTO orders ...")->execute([$userId, $total]);
    $pdo->prepare("UPDATE inventory ...")->execute([$qty, $productId]);
    $pdo->commit();
} catch (\Throwable $e) {
    $pdo->rollBack();
    throw $e;
}
```

Rules: keep short (locks), no I/O inside transactions, always rollback on
exception, don't read replicas during writes. Use savepoints for nested
transaction simulation.

## Connection Management

```php
// ❌ Bad — persistent connections (state leakage, exhausts max_connections)
PDO::ATTR_PERSISTENT => true

// ✅ Good — use external pools: ProxySQL (MySQL), PgBouncer transaction-mode (PostgreSQL)
PDO::ATTR_PERSISTENT => false
```

**Read replicas:** route writes to primary, reads to replica. After a write the
user must see, read from primary ( replica lag).

**Connection health:** detect MySQL errors 2006 (server gone away) and 2013
(lost connection); use a factory to recreate connections on failure rather than
trying to reconnect an existing PDO object.

## Migrations

**Cardinal rule:** never edit a deployed migration. Write a new one to reverse
it.

```php
// ✅ Good — anonymous class with up/down
return new class {
    public function up(PDO $pdo): void {
        $pdo->exec("ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL");
    }
    public function down(PDO $pdo): void {
        $pdo->exec("ALTER TABLE users DROP COLUMN phone");
    }
};
```

### Zero-Downtime Patterns

**Adding NOT NULL column:** (1) add nullable, (2) backfill in batches, (3) add
NOT NULL constraint.

**Renaming a column:** (1) add new + write both, (2) backfill + switch reads,
(3) drop old.

**Adding indexes:** MySQL `ALGORITHM=INPLACE, LOCK=NONE`; PostgreSQL
`CREATE INDEX CONCURRENTLY` (outside transaction).

**Migration testing:** (1) structural — apply `up()`, verify schema, apply
`down()`, verify revert; (2) data integrity — seed data, run migration, assert
correctness; (3) test against target DB engine in CI, not just SQLite.

**Checklist:** timestamp-prefixed name, has `down()`, tested on target DB, large
tables use zero-downtime, destructive changes approved.

## ORM Patterns

### Active Record vs Data Mapper

```php
// Active Record (Eloquent) — object IS the row, good for CRUD/prototyping
$user = User::find(42);
$user->name = 'Alice';
$user->save();

// Data Mapper (Doctrine) — object has no DB knowledge, good for rich domains
$user = $mapper->findById(42);
$user->rename('Alice'); // pure domain logic, testable without DB
$mapper->save($user);
```

Decision: rich domain -> Data Mapper + Repository. CRUD -> Active Record.
Laravel -> Eloquent. Symfony -> Doctrine.

### Repository Pattern

```php
// ✅ Good — domain-language interface
interface UserRepository {
    public function findById(int $id): ?User;
    public function findByEmail(string $email): ?User;
    public function save(User $user): void;
}

// ❌ Bad — leaky abstraction
interface UserRepository {
    public function findWhere(string $sql, array $params): array;
}

// ❌ Bad — fat repository (business logic in repo)
// ✅ Good — domain logic in service, repository just persists
```

### Unit of Work

Doctrine EntityManager: tracks dirty objects, flushes as one transaction. Avoid
for simple CRUD and long-lived processes (memory leak).

## REST API Design

### Resource Naming

```
// ✅ Good — plural nouns, lowercase, hyphens
GET  /api/v1/articles
GET  /api/v1/articles/42/comments
GET  /api/v1/user-profiles

// ❌ Bad — verbs in path, mixed case
GET  /api/getArticle?id=42
POST /api/articles/createComment
```

Rules: plural nouns, max one nesting level, query params for filtering/sorting.

### HTTP Verbs and Status Codes

| Verb    | Semantics        | Idempotent | Safe | Key Codes     |
| ------- | ---------------- | ---------- | ---- | ------------- |
| GET     | Retrieve         | Yes        | Yes  | 200, 304, 404 |
| POST    | Create/trigger   | No         | No   | 201, 400, 422 |
| PUT     | Replace entirely | Yes        | No   | 200, 204, 404 |
| PATCH   | Partial update   | No         | No   | 200, 422      |
| DELETE  | Remove           | Yes        | No   | 204, 404      |
| HEAD    | Headers only     | Yes        | Yes  | 200, 404      |
| OPTIONS | Allowed methods  | Yes        | Yes  | 200, 204      |

Never return `200` with `{"success": false}`. Use `422` for business validation
failures, `400` for malformed requests. `201` must include `Location` header.
`429` must include `Retry-After`.

### Error Responses — RFC 7807

All errors: `Content-Type: application/problem+json` with `type`, `title`,
`status`, `detail` fields.

### HATEOAS

Include `links` on every resource (`self` at minimum). Collections get
`next`/`prev`/`first`/`last`. Contextual action links (e.g., `publish`) appear
only when valid. Level 3 Richardson Maturity Model.

### Content Negotiation

Use `Accept`/`Content-Type` headers. Return `406` when requested type can't be
produced. PSR-7 responses are immutable.

## API Versioning

**URL versioning** (public APIs): `/api/v1/articles`. Obvious, cacheable. Used
by Stripe, GitHub, Twilio (~70%).

**Header versioning** (internal APIs): `Api-Version: 2` or
`Accept: application/vnd.myapi.v2+json`. Needs `Vary` header.

**Non-breaking:** adding optional fields/params/endpoints. **Breaking:**
removing/renaming fields, changing types/status codes/auth.

**Deprecation (RFC 8594):** `Deprecation: true` + `Sunset` header + `Link` to
migration guide. Windows: internal 4-8 weeks, public 6-12 months. Log every
request to deprecated endpoints (path, method, user-agent, IP) to identify
consumers who have not migrated. At sunset: `410 Gone`.

## Serialization

```php
// ❌ Bad — expose Eloquent model directly
return response()->json($model);

// ✅ Good — explicit DTO transformation
final readonly class ArticleResource {
    public function __construct(
        public int $id, public string $title, public string $status,
        public AuthorResource $author, public DateTimeImmutable $createdAt,
    ) {}
    public function toArray(): array { /* explicit field mapping */ }
}
```

### Response Envelopes

Single: `{"data": {...}, "links": {"self": "..."}}`. Collection: add
`"meta": {"total", "per_page", "current_page", "last_page"}` and
`"links": {"first", "prev", "next", "last"}`.

### Pagination

**Offset/limit** (`?page=3&per_page=20`): simple, poor at large offsets (O(n)).
**Cursor** (`?after=<opaque>&limit=20`): stable, O(1) seek, preferred for large
datasets. Cursors: base64-encoded JSON, opaque to client.

## Rate Limiting

| Algorithm      | Burst | Memory | Boundary Issue | Best For             |
| -------------- | ----- | ------ | -------------- | -------------------- |
| Fixed Window   | None  | O(1)   | 2x at boundary | Simple internal APIs |
| Sliding Window | None  | O(n)   | No             | Consumer-facing APIs |
| Token Bucket   | Yes   | O(1)   | No             | Burst-tolerant APIs  |

Always include headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`,
`X-RateLimit-Reset`. On 429: add `Retry-After` + RFC 7807 body.

Scope keys: per-user, per-IP (unauth), per-tier. Tiers: unauth 30/min, free
100/min, paid 1000/min. Implement as PSR-15 middleware. Use Redis atomic
operations (pipelines/Lua) to avoid race conditions. For multiple simultaneous
limits ( per-second burst + per-day quota), use a composite limiter that fails
fast on first exceeded limit.

## Database-Specific Notes

**MySQL:** `charset=utf8mb4` in DSN, `PARAM_INT` for LIMIT, `max_connections`
151, ProxySQL at scale, `ALGORITHM=INPLACE, LOCK=NONE` for DDL.

**PostgreSQL:** native prepares default, PgBouncer transaction-mode,
`ADD COLUMN DEFAULT` instant on 11+, `CREATE INDEX CONCURRENTLY` outside
transactions, `max_connections` 100.
