# Deployment Reference

## Table of Contents

- [CI/CD Pipeline Structure](#cicd-pipeline-structure)
- [Docker Multi-Stage Build](#docker-multi-stage-build)
- [PHP-FPM Configuration](#php-fpm-configuration)
- [Environment Configuration](#environment-configuration)
- [Zero-Downtime Strategies](#zero-downtime-strategies)
- [Database Migration Patterns](#database-migration-patterns)
- [Deployer](#deployer)

## CI/CD Pipeline Structure

Stage order: `lint -> static-analysis -> test -> build -> deploy`. Fail fast.

### GitHub Actions Key Steps

```yaml
jobs:
  lint:
    steps:
      - uses: shivammathur/setup-php@v2
        with: { php-version: "8.4", tools: php-cs-fixer }
      - uses: actions/cache@v4
        with: { path: ~/.composer/cache, key: "composer-${{ hashFiles('composer.lock') }}" }
      - run: composer install --no-interaction --prefer-dist
      - run: php-cs-fixer fix --dry-run --diff
  analyze:
    needs: lint
    steps:
      - run: vendor/bin/phpstan analyse --no-progress --memory-limit=512M
  test:
    needs: lint
    strategy: { matrix: { php: ["8.3", "8.4"] } }
    services:
      mysql: { image: "mysql:8.0", env: { MYSQL_ROOT_PASSWORD: secret, MYSQL_DATABASE: testing } }
    steps:
      - run: vendor/bin/phpunit --coverage-clover coverage.xml
  build:
    needs: [analyze, test]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: docker/build-push-action@v5
        with: { push: true, tags: "ghcr.io/${{ github.repository }}:${{ github.sha }}", cache-from: "type=gha" }
```

Cache `~/.composer/cache` keyed on `composer.lock` hash. Pin actions to full SHA. Use GitHub Environments with required
reviewers for production.

## Docker Multi-Stage Build

```dockerfile
# Stage 1: Composer
FROM composer:2.8 AS composer-deps
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --optimize-autoloader --classmap-authoritative

# Stage 2: Production
FROM php:8.4-fpm-alpine AS production
RUN apk add --no-cache nginx supervisor \
    && docker-php-ext-install pdo_mysql opcache pcntl \
    && pecl install redis && docker-php-ext-enable redis

RUN addgroup -g 1001 -S appgroup && adduser -u 1001 -S appuser -G appgroup
WORKDIR /var/www/html
COPY --chown=appuser:appgroup . .
COPY --from=composer-deps --chown=appuser:appgroup /app/vendor ./vendor
USER appuser
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost/up || exit 1
```

### Base Image Comparison

| Factor      | Alpine             | Debian Slim   |
| ----------- | ------------------ | ------------- |
| Size        | ~80-120 MB         | ~180-300 MB   |
| Complexity  | Higher (musl libc) | Lower (glibc) |
| CVE surface | Smaller            | Larger        |

Start Alpine; switch to Debian only if extensions fail to compile. Tag images with Git SHA for immutable deploys.

## PHP-FPM Configuration

```ini
pm = dynamic
pm.max_children = 10            ; floor(available_memory / avg_worker_memory)
pm.start_servers = 3            ; ~25% of max
pm.min_spare_servers = 2
pm.max_spare_servers = 5
pm.max_requests = 500           ; Recycle to prevent memory leaks
request_slowlog_timeout = 5s
```

Typical Laravel worker: 30-60 MB. Measure: `ps -o rss= -p $(pgrep -d, php-fpm)`

```ini
; Production php.ini
opcache.enable=1
opcache.validate_timestamps=0   ; Container images are immutable
opcache.save_comments=1         ; Required by Laravel
expose_php=Off
memory_limit=256M
max_execution_time=30
```

## Environment Configuration

- Commit `.env.example` (empty values); never commit `.env` with credentials
- After `config:cache`, `.env` is not read; use `config()` not `env()` in app code
- Use secrets managers (Vault, AWS SSM) in production
- Validate required env vars at boot before accepting traffic

```php
$missing = array_filter(['APP_KEY', 'DB_HOST', 'DB_PASSWORD'], fn($k) => empty(env($k)));
if ($missing) throw new \RuntimeException('Missing: ' . implode(', ', $missing));
```

### Kubernetes Security Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
```

## Zero-Downtime Strategies

| Strategy   | Infra Overhead | Rollback Speed | Mixed Versions? |
| ---------- | -------------- | -------------- | --------------- |
| Blue-green | Double         | Seconds        | No              |
| Rolling    | Minimal        | Minutes        | Yes             |
| Canary     | Minimal        | Seconds        | Yes             |

### Kubernetes Rolling Update

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate: { maxUnavailable: 0, maxSurge: 1 }
```

### Probes

```yaml
livenessProbe:
  httpGet: { path: /health/live, port: 8080 }
  initialDelaySeconds: 10
  periodSeconds: 15
readinessProbe:
  httpGet: { path: /health/ready, port: 8080 }
  initialDelaySeconds: 5
  periodSeconds: 10
```

## Database Migration Patterns

### Expand-Contract (Safe)

1. Add nullable column (old code ignores it)
2. Deploy new code writing to both columns
3. Backfill data
4. Drop old column after all old code is gone

### Dangerous Operations

| Operation           | Risk             | Safe Alternative              |
| ------------------- | ---------------- | ----------------------------- |
| Rename column       | Old code breaks  | Add new, backfill, drop old   |
| Add NOT NULL column | Old inserts fail | Add nullable, backfill, alter |
| Drop column         | Old reads fail   | Remove code first, then drop  |
| `migrate:fresh`     | Truncates tables | Never in production           |

Run migrations **before** deploying new application code.

## Deployer

```php
namespace Deployer;
require 'recipe/laravel.php';
set('repository', 'git@github.com:org/myapp.git');
set('keep_releases', 5);
add('shared_files', ['.env']);
add('shared_dirs', ['storage', 'bootstrap/cache']);

host('production')
    ->setHostname('example.com')
    ->setRemoteUser('deploy')
    ->setDeployPath('/var/www/myapp');
```

```bash
dep deploy production     # Atomic symlink deploy
dep rollback production   # Instant rollback
```

Image scanning in CI:

```yaml
- uses: aquasecurity/trivy-action@master
  with: { image-ref: "ghcr.io/${{ github.repository }}:${{ github.sha }}", severity: "CRITICAL,HIGH", exit-code: 1 }
```
