# Dependency Management Reference

## Table of Contents

- [Composer Commands](#composer-commands)
- [Version Constraints](#version-constraints)
- [Autoloading](#autoloading)
- [Production Optimization](#production-optimization)
- [Private Repositories](#private-repositories)
- [composer.json Configuration](#composerjson-configuration)
- [Security](#security)

## Composer Commands

### Daily Usage

| Command                           | Purpose                                  |
| --------------------------------- | ---------------------------------------- |
| `composer install`                | Install from lock file (deterministic)   |
| `composer update`                 | Resolve constraints fresh, update lock   |
| `composer update vendor/pkg`      | Update single package within constraints |
| `composer require vendor/pkg`     | Add dependency                           |
| `composer remove vendor/pkg`      | Remove dependency                        |
| `composer dump-autoload`          | Regenerate autoloader                    |
| `composer audit`                  | Check for known security advisories      |
| `composer outdated --direct`      | Show outdated direct dependencies        |
| `composer update --dry-run`       | Preview what would change                |
| `composer why vendor/pkg`         | Show why a package is installed          |
| `composer why-not vendor/pkg 2.0` | Show what blocks a version               |

### Production Install

```bash
composer install \
  --no-dev \
  --no-interaction \
  --no-progress \
  --optimize-autoloader \
  --classmap-authoritative \
  --prefer-dist
```

| Flag                       | Purpose                                |
| -------------------------- | -------------------------------------- |
| `--no-dev`                 | Excludes `require-dev` packages        |
| `--no-interaction`         | Prevents prompts in CI                 |
| `--optimize-autoloader`    | Generates classmap for PSR-4 paths     |
| `--classmap-authoritative` | No filesystem fallback (30-40% faster) |
| `--prefer-dist`            | Downloads zips, not git clones         |

## Version Constraints

### Caret (Preferred)

```
^1.2.3  →  >=1.2.3 <2.0.0
^1.2    →  >=1.2.0 <2.0.0
^0.3    →  >=0.3.0 <0.4.0     (0.x: locks minor)
^0.0.3  →  >=0.0.3 <0.0.4     (0.0.x: locks patch)
```

### Tilde (More Restrictive)

```
~1.2.3  →  >=1.2.3 <1.3.0     (patch updates only)
~1.2    →  >=1.2.0 <2.0.0
```

Use tilde only when a package has history of breaking minor versions.

### Stability Flags

```json
{
  "minimum-stability": "stable",
  "prefer-stable": true,
  "require": {
    "some/bleeding-edge": "^2.0@beta"
  }
}
```

| Stability | Examples       | Use Case             |
| --------- | -------------- | -------------------- |
| `stable`  | `1.0.0`        | Production (default) |
| `RC`      | `2.0.0-RC1`    | Release testing      |
| `beta`    | `1.5.0-beta.2` | Early adopter        |
| `dev`     | `dev-main`     | Active development   |

### Conflict Resolution

```bash
composer why-not vendor/package 2.0       # Identify blockers
composer update vendor/pkg --with-dependencies  # Update with deps
```

Add shared dependency explicitly to force resolution:

```json
{ "require": { "shared/dependency": "^3.5" } }
```

Inline aliases for temporary forks:

```json
{
  "repositories": [{ "type": "vcs", "url": "https://github.com/fork/package" }],
  "require": { "vendor/package": "dev-fix-branch as 2.3.4" }
}
```

## Autoloading

### PSR-4

```json
{
  "autoload": {
    "psr-4": {
      "App\\": "src/",
      "Database\\Factories\\": "database/factories/"
    }
  },
  "autoload-dev": {
    "psr-4": { "Tests\\": "tests/" }
  }
}
```

Rules: namespace key must end with `\\`, directory must end with `/`.

### Classmap

```json
{ "autoload": { "classmap": ["database/", "legacy/"] } }
```

Use for legacy code not following PSR-4 naming.

### Files

```json
{ "autoload": { "files": ["src/helpers.php"] } }
```

Included on every request. Keep list short. Guard functions with `function_exists()`.

## Production Optimization

### Autoloader Modes

| Mode                       | Dev   | Production | Behavior                            |
| -------------------------- | ----- | ---------- | ----------------------------------- |
| Default PSR-4              | Best  | Avoid      | Filesystem probing on miss          |
| `--optimize-autoloader`    | Slow  | Good       | PSR-4 to classmap, still falls back |
| `--classmap-authoritative` | Avoid | Best       | Classmap only, no fallback          |
| `--apcu`                   | No    | Good       | Shared memory cache                 |

### Laravel Optimization Pipeline

```bash
php artisan config:cache      # Serialize config to single file
php artisan route:cache       # Compile route list
php artisan view:cache        # Pre-compile Blade views
php artisan event:cache       # Cache event/listener mappings
composer dump-autoload --optimize
```

After `config:cache`, `.env` is not read at runtime. All `env()` calls outside `config/*.php` return `null`.

## Private Repositories

### Satis (Self-Hosted)

```json
{
  "repositories": [{ "type": "composer", "url": "https://satis.example.com" }]
}
```

### Private Packagist

```json
{
  "repositories": [{ "type": "composer", "url": "https://repo.packagist.com/your-org/" }, { "packagist.org": false }]
}
```

### Credential Storage

```bash
# Store in auth.json (gitignored), not composer.json
composer config --global http-basic.repo.packagist.com token "$TOKEN"

# Or environment variable
COMPOSER_AUTH='{"http-basic":{"repo.packagist.com":{"username":"token","password":"'"$TOKEN"'"}}}'
```

## composer.json Configuration

```json
{
  "config": {
    "optimize-autoloader": true,
    "preferred-install": "dist",
    "sort-packages": true,
    "allow-plugins": {
      "pestphp/pest-plugin": true,
      "phpstan/extension-installer": true
    },
    "platform": { "php": "8.2.0" }
  }
}
```

- `sort-packages`: keeps diffs clean
- `allow-plugins`: whitelist only reviewed plugins (never `{"*": true}`)
- `platform.php`: forces resolution as if running specific PHP version

### What to Commit

| File            | Commit? | Notes                              |
| --------------- | ------- | ---------------------------------- |
| `composer.json` | Always  | Developer-authored constraints     |
| `composer.lock` | Always  | Exact versions for reproducibility |
| `vendor/`       | Never   | Regenerated from lock file         |
| `auth.json`     | Never   | Contains credentials               |

## Security

```bash
composer audit --no-dev              # Check for known CVEs
composer audit --format=json         # Machine-readable output
```

Use `roave/security-advisories` as a dev dependency to block installing packages with known vulnerabilities:

```bash
composer require --dev roave/security-advisories:dev-latest
```

Automate dependency updates with Dependabot or Renovate Bot.
