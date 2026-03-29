# Documentation Reference

## Table of Contents

- [PHPDoc Decision Tree](#phpdoc-decision-tree)
- [When PHPDoc Adds Value](#when-phpdoc-adds-value)
- [When to Skip PHPDoc](#when-to-skip-phpdoc)
- [PHPDoc Tag Reference](#phpdoc-tag-reference)
- [Generics in PHPDoc](#generics-in-phpdoc)
- [Array Shapes](#array-shapes)
- [Callable Shapes](#callable-shapes)
- [Advanced: Conditional Return Types](#advanced-conditional-return-types)
- [PHPDoc Anti-Patterns](#phpdoc-anti-patterns)
- [PHPDoc Enforcement via PHPStan](#phpdoc-enforcement-via-phpstan)
- [API Documentation with Scribe](#api-documentation-with-scribe)
- [Scribe Annotations](#scribe-annotations)
- [FormRequest Integration](#formrequest-integration)
- [API Resource Integration](#api-resource-integration)
- [OpenAPI CI Enforcement](#openapi-ci-enforcement)
- [Alternative: PHP Attributes for OpenAPI](#alternative-php-attributes-for-openapi)
- [Architecture Decision Records](#architecture-decision-records)
- [ADR Format](#adr-format)
- [ADR Status Lifecycle](#adr-status-lifecycle)
- [ADR Storage Conventions](#adr-storage-conventions)
- [ADR Anti-Patterns](#adr-anti-patterns)

## PHPDoc Decision Tree

```
Does the method have native type declarations for all params and return?
├── Yes → Does it also need @template, @throws, or array shapes?
│         ├── Yes → Add PHPDoc for those tags only
│         └── No  → Skip PHPDoc entirely
└── No  → Add native types first, then apply the above
```

## When PHPDoc Adds Value

1. **Generics** — `@template`, `@extends`, `@implements` (no native syntax)
2. **Array shapes** — `array{id: int, name: string}` (native `array` loses structure)
3. **`@throws`** — PHP has no checked exceptions
4. **Callable shapes** — `callable(User, int): bool`
5. **`@deprecated`** — signal migration path with version
6. **`@var` for complex shapes** — inline type narrowing
7. **Union complexity** — when native type is `mixed` but real shape is richer

## When to Skip PHPDoc

Skip when PHPDoc just repeats native type declarations:

```php
// ❌ Bad — duplicates native types
/**
 * @param string $name
 * @param int $age
 * @return User
 */
public function create(string $name, int $age): User {}

// ✅ Good — native types are sufficient
public function create(string $name, int $age): User {}
```

## PHPDoc Tag Reference

| Tag                     | Purpose                                  | Example                                |
| ----------------------- | ---------------------------------------- | -------------------------------------- |
| `@template T`           | Generic type parameter                   | `@template T of Model`                 |
| `@template-covariant T` | Covariant generic (read-only containers) | `@template-covariant T`                |
| `@extends`              | Specialize generic parent                | `@extends Collection<User>`            |
| `@implements`           | Specialize generic interface             | `@implements Iterator<int, User>`      |
| `@param`                | Parameter type (when adds over native)   | `@param array<string, mixed> $data`    |
| `@return`               | Return type (when adds over native)      | `@return array{id: int, name: string}` |
| `@throws`               | Documented exception                     | `@throws RuntimeException`             |
| `@var`                  | Variable/property type                   | `@var list<User>`                      |
| `@deprecated`           | Deprecation with version + alternative   | `@deprecated 3.0 Use newMethod()`      |
| `@internal`             | Not for external use                     | `@internal`                            |
| `@api`                  | Explicitly public API surface            | `@api`                                 |
| `@psalm-pure`           | Pure function (no side effects)          | `@psalm-pure`                          |
| `@phpstan-ignore`       | Suppress specific PHPStan error          | `@phpstan-ignore-next-line`            |

## Generics in PHPDoc

### Basic @template

```php
/**
 * @template T of Model
 * @param class-string<T> $modelClass
 * @return T
 */
public function find(string $modelClass, int $id): Model
{
    return $modelClass::findOrFail($id);
}
```

### @extends and @implements

```php
/**
 * @template T of Entity
 * @implements RepositoryInterface<T>
 */
abstract class EloquentRepository implements RepositoryInterface {}

/** @extends EloquentRepository<User> */
class UserRepository extends EloquentRepository {}
```

## Array Shapes

```php
/**
 * @var array{
 *     id: int,
 *     name: string,
 *     email: string,
 *     roles: list<string>
 * } $userData
 */
$userData = $request->validated();

/**
 * @param array<string, int|float> $metrics
 * @return array{min: float, max: float, avg: float}
 */
public function summarize(array $metrics): array {}
```

## Callable Shapes

```php
/**
 * @param callable(User, int): bool $callback
 * @return list<User>
 */
public function filterUsers(callable $callback): array {}
```

## Advanced: Conditional Return Types

```php
/**
 * @template T
 * @param T $value
 * @param callable(T): bool $predicate
 * @return ($predicate is pure-Closure ? T : T|null)
 */
public function filter(mixed $value, callable $predicate): mixed {}
```

## PHPDoc Anti-Patterns

- **Outdated `@param` descriptions** that describe a different type than the actual parameter
- **`@return void`** when the method already has `: void` native type
- **Copious `{@inheritDoc}`** — prefer explicit docs over inheritance chasing
- **`@param` as substitute for native types** — add the type hint, not a docblock

## PHPDoc Enforcement via PHPStan

```neon
parameters:
    level: 8
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: true
```

## API Documentation with Scribe

Scribe generates OpenAPI specs from Laravel routes, FormRequests, and docblocks.

```bash
composer require --dev knuckleswtf/scribe
php artisan vendor:publish --tag=scribe-config
php artisan scribe:generate
```

## Scribe Annotations

```php
/**
 * Get a paginated list of users.
 *
 * @authenticated
 * @queryParam page int Page number. Example: 2
 * @queryParam per_page int Results per page. Max 100. Example: 20
 *
 * @response 200 {"data": [{"id": 1, "name": "Alice"}], "meta": {"total": 42}}
 * @response 401 {"message": "Unauthenticated."}
 */
public function index(Request $request): JsonResponse {}
```

## FormRequest Integration

Scribe reads validation rules and auto-documents request parameters:

```php
class CreateUserRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name'     => ['required', 'string', 'max:255'],
            'email'    => ['required', 'email', 'unique:users'],
            'password' => ['required', 'min:8', 'confirmed'],
            'role'     => ['required', Rule::in(['admin', 'editor', 'viewer'])],
        ];
    }
}
```

## API Resource Integration

```php
/**
 * @apiResource App\Http\Resources\UserResource
 * @apiResourceModel App\Models\User
 */
public function show(User $user): UserResource {}
```

## OpenAPI CI Enforcement

```yaml
- name: Generate API docs
  run: php artisan scribe:generate
- name: Check for spec drift
  run: |
    git diff --exit-code storage/app/scribe/openapi.yaml || \
      (echo "OpenAPI spec is out of date" && exit 1)
```

Commit `openapi.yaml` to version control for diff-reviewable API change history.

Use `@hideFromAPIDocumentation` on internal-only routes.

## Alternative: PHP Attributes for OpenAPI

For framework-agnostic OpenAPI, use `zircote/swagger-php` with PHP 8 attributes:

```php
use OpenApi\Attributes as OA;

#[OA\Get(
    path: '/api/users/{id}',
    summary: 'Get a user',
    responses: [
        new OA\Response(response: 200, description: 'User found'),
        new OA\Response(response: 404, description: 'Not found'),
    ]
)]
public function show(User $user): UserResource {}
```

Use Scribe for Laravel projects (less boilerplate). Use swagger-php for framework-agnostic needs.

## Architecture Decision Records

ADRs capture significant architectural decisions: what was decided, why, and what consequences follow.

### When to Write an ADR

- Hard to reverse — technology selections, data models, API contracts
- Significant trade-offs — chose A over B for non-obvious reasons
- Will confuse future maintainers — "why didn't they just use X?"
- Affects multiple teams
- Was contentious

Do NOT write ADRs for routine implementation choices or easily reversed changes.

## ADR Format

```markdown
# ADR-{number}: {Title}

**Date:** YYYY-MM-DD **Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN

## Context

What situation drives this decision? What constraints exist?

## Considered Options

1. **Option A**: Description
2. **Option B**: Description

## Decision

We will **{Option X}**. Rationale in 2-4 sentences.

## Consequences

**Positive:** Benefits **Negative:** Trade-offs **Risks:** Risks and mitigations
```

## ADR Status Lifecycle

```
Proposed -> Accepted -> (Deprecated | Superseded by ADR-NNN)
```

Never delete old ADRs. Update the Status field when superseded.

## ADR Storage Conventions

- Store in `docs/decisions/` with zero-padded numbers: `0001-use-postgresql.md`
- Filenames are permanent — do not rename
- Commit convention: `docs(adr): ADR-NNNN short title`
- In monorepos, use service-scoped ADR directories

## ADR Anti-Patterns

- **ADRs for micro-decisions** — style choices belong in style guides
- **Missing "Considered Options"** — always list at least two alternatives
- **Editing accepted ADRs** — write a new superseding ADR instead
- **Storing outside the codebase** — ADRs in Confluence/Notion get orphaned
