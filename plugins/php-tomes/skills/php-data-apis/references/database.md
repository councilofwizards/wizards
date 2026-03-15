# Database Reference

## Table of Contents

- [PDO Options](#pdo-options)
- [Fetch Strategies](#fetch-strategies)
- [Parameter Types](#parameter-types)
- [Transaction Patterns](#transaction-patterns)
- [Connection Patterns](#connection-patterns)
- [Migration Patterns](#migration-patterns)
- [ORM Comparison](#orm-comparison)
- [Repository Templates](#repository-templates)
- [MySQL vs PostgreSQL](#mysql-vs-postgresql)

## PDO Options

| Option                    | Recommended                | Reason                                  |
|---------------------------|----------------------------|-----------------------------------------|
| `ATTR_ERRMODE`            | `ERRMODE_EXCEPTION`        | Silent failures never acceptable        |
| `ATTR_DEFAULT_FETCH_MODE` | `FETCH_ASSOC`              | Simpler than stdClass                   |
| `ATTR_EMULATE_PREPARES`   | `false`                    | Native types, no charset injection      |
| `ATTR_PERSISTENT`         | `false`                    | Avoid state leakage                     |
| `MYSQL_ATTR_FOUND_ROWS`   | `true` (MySQL)             | rowCount() returns matched, not changed |
| `MYSQL_ATTR_INIT_COMMAND` | `"SET time_zone='+00:00'"` | Consistent timezone                     |

## Fetch Strategies

```php
$user = $stmt->fetch();                              // single row (default mode)
$user = $stmt->fetch(PDO::FETCH_OBJ);               // as stdClass
$rows = $stmt->fetchAll();                           // all rows
$rows = $stmt->fetchAll(PDO::FETCH_CLASS, Dto::class); // hydrate into class
$val  = $stmt->fetchColumn();                        // single column
$map  = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);        // [key => value]
```

## Parameter Types

```php
$stmt->bindValue(':active', true,   PDO::PARAM_BOOL);
$stmt->bindValue(':id',     $id,    PDO::PARAM_INT);
$stmt->bindValue(':name',   $name,  PDO::PARAM_STR);
$stmt->bindValue(':blob',   $data,  PDO::PARAM_LOB);
```

`bindParam()` binds by reference (read at execute). Use `bindValue()` in loops.

## Transaction Patterns

```php
// Basic
$pdo->beginTransaction();
try {
    $pdo->prepare("INSERT ...")->execute([...]);
    $pdo->prepare("UPDATE ...")->execute([...]);
    $pdo->commit();
} catch (\Throwable $e) { $pdo->rollBack(); throw $e; }

// Savepoint-based nesting
class TransactionManager {
    private int $depth = 0;
    public function __construct(private readonly PDO $pdo) {}
    public function begin(): void {
        $this->depth === 0 ? $this->pdo->beginTransaction() : $this->pdo->exec("SAVEPOINT sp{$this->depth}");
        $this->depth++;
    }
    public function commit(): void {
        $this->depth--;
        $this->depth === 0 ? $this->pdo->commit() : $this->pdo->exec("RELEASE SAVEPOINT sp{$this->depth}");
    }
    public function rollback(): void {
        $this->depth--;
        $this->depth === 0 ? $this->pdo->rollBack() : $this->pdo->exec("ROLLBACK TO SAVEPOINT sp{$this->depth}");
    }
}
```

## Connection Patterns

### Pool (long-running processes: Swoole/ReactPHP/FrankenPHP)

```php
final class ConnectionPool {
    private \SplQueue $available;
    private int $active = 0;
    public function __construct(private readonly \Closure $factory, private readonly int $max = 10) {
        $this->available = new \SplQueue();
    }
    public function acquire(): PDO {
        if (!$this->available->isEmpty()) return $this->available->dequeue();
        if ($this->active >= $this->max) throw new \RuntimeException('Pool exhausted');
        $this->active++;
        return ($this->factory)();
    }
    public function release(PDO $pdo): void { $this->available->enqueue($pdo); }
}
```

PHP-FPM: use external pools — ProxySQL/RDS Proxy (MySQL), PgBouncer transaction-mode (PostgreSQL).

### Read Replicas

```php
final class ReplicaAwarePdo {
    public function __construct(private readonly PDO $writer, private readonly PDO $reader) {}
    public function writer(): PDO { return $this->writer; }
    public function reader(): PDO { return $this->reader; }
}
```

Read-your-writes: after a write, read from writer to avoid replica lag.

## Migration Patterns

### Runner

```php
class MigrationRunner {
    public function __construct(private readonly PDO $pdo) {}
    public function run(string $dir): void {
        $this->ensureTable();
        $applied = $this->pdo->query("SELECT version FROM migrations")->fetchAll(PDO::FETCH_COLUMN);
        foreach (glob($dir . '/*.php') as $file) {
            $version = basename($file, '.php');
            if (in_array($version, $applied, true)) continue;
            (require $file)->up($this->pdo);
            $this->pdo->prepare("INSERT INTO migrations (version) VALUES (?)")->execute([$version]);
        }
    }
    private function ensureTable(): void {
        $this->pdo->exec("CREATE TABLE IF NOT EXISTS migrations (
            version VARCHAR(255) PRIMARY KEY, applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
    }
}
```

### Reversibility

| Operation         | Reversible? | down action  |
|-------------------|-------------|--------------|
| ADD COLUMN        | Yes         | DROP COLUMN  |
| CREATE TABLE      | Yes         | DROP TABLE   |
| CREATE INDEX      | Yes         | DROP INDEX   |
| DROP COLUMN/TABLE | **No**      | Data is gone |

### Zero-Downtime DDL

MySQL 8.0+: instant DDL for ADD COLUMN DEFAULT. Older: `pt-online-schema-change` or `gh-ost`.
PostgreSQL 11+: ADD COLUMN DEFAULT instant. Pre-11: add nullable -> backfill -> set NOT NULL.

```sql
-- MySQL index
CREATE INDEX idx_email ON users (email) ALGORITHM=INPLACE, LOCK=NONE;
-- PostgreSQL index (outside transaction)
CREATE INDEX CONCURRENTLY idx_email ON users (email);
```

### Batched Backfill

```php
function backfill(PDO $pdo, int $batch = 500): void {
    do {
        $pdo->beginTransaction();
        $stmt = $pdo->prepare("UPDATE users SET col = val WHERE col IS NULL LIMIT :b");
        $stmt->bindValue(':b', $batch, PDO::PARAM_INT);
        $stmt->execute();
        $n = $stmt->rowCount();
        $pdo->commit();
    } while ($n > 0);
}
```

### Query Builder Libraries

| Library             | Notes                                   |
|---------------------|-----------------------------------------|
| `doctrine/dbal`     | Mature, type-safe, schema introspection |
| `cakephp/database`  | Lightweight, standalone                 |
| `latitude/latitude` | Purely functional, immutable            |

## ORM Comparison

| Aspect      | Active Record (Eloquent)    | Data Mapper (Doctrine)        |
|-------------|-----------------------------|-------------------------------|
| Boilerplate | Low                         | Higher                        |
| Testability | Needs DB or complex mocking | Pure PHP, no DB needed        |
| SRP         | Violates                    | Respects separation           |
| Best for    | CRUD, rapid prototyping     | Rich domain, large teams, DDD |
| Framework   | Laravel                     | Symfony                       |

## Repository Templates

```php
// Interface — domain-language methods only
interface UserRepository {
    public function findById(int $id): ?User;
    public function findByEmail(string $email): ?User;
    public function save(User $user): void;
    public function delete(User $user): void;
}

// In-memory test stub
class InMemoryUserRepository implements UserRepository {
    private array $users = [];
    public function findById(int $id): ?User { return $this->users[$id] ?? null; }
    public function findByEmail(string $email): ?User {
        foreach ($this->users as $u) { if ($u->email === $email) return $u; }
        return null;
    }
    public function save(User $user): void { $this->users[$user->id] = $user; }
    public function delete(User $user): void { unset($this->users[$user->id]); }
}
```

## MySQL vs PostgreSQL

### MySQL

- `max_connections`: 151 default
- `charset=utf8mb4` in DSN (never `SET NAMES`)
- `wait_timeout`: 8h default (idle connections killed)
- LIMIT with native prepares: `PDO::PARAM_INT`
- `MYSQL_ATTR_FOUND_ROWS => true` for predictable rowCount()
- Online DDL: `ALGORITHM=INPLACE, LOCK=NONE`

### PostgreSQL

- `max_connections`: 100 default
- PgBouncer transaction-mode for PHP-FPM
- `idle_in_transaction_session_timeout` (9.6+) kills leaked txns
- ADD COLUMN DEFAULT instant on 11+
- DSN: `pgsql:host=127.0.0.1;port=5432;dbname=myapp`
- Native prepared statements are default
