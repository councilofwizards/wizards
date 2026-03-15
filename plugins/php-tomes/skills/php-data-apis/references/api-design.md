# API Design Reference

## Table of Contents

- [Resource Naming](#resource-naming)
- [HTTP Verbs](#http-verbs)
- [Status Codes](#status-codes)
- [RFC 7807 Problem Details](#rfc-7807-problem-details)
- [PSR-7 Essentials](#psr-7-essentials)
- [Content Negotiation](#content-negotiation)
- [Response Envelopes](#response-envelopes)
- [DTO and Transformer Patterns](#dto-and-transformer-patterns)
- [Pagination](#pagination)
- [Versioning](#versioning)
- [Deprecation](#deprecation)
- [Rate Limiting](#rate-limiting)

## Resource Naming

Plural nouns, lowercase, hyphens for multi-word. Max one sub-resource level. Query params for filtering/sorting. No
verbs in paths.

## HTTP Verbs

| Verb    | Semantics               | Idempotent | Safe | Typical Status     |
|---------|-------------------------|------------|------|--------------------|
| GET     | Retrieve                | Yes        | Yes  | 200, 304, 404      |
| POST    | Create / trigger action | No         | No   | 201, 202, 400, 422 |
| PUT     | Replace entirely        | Yes        | No   | 200, 204, 404      |
| PATCH   | Partial update          | No         | No   | 200, 204, 422      |
| DELETE  | Remove                  | Yes        | No   | 204, 404           |
| HEAD    | Headers only            | Yes        | Yes  | 200, 404           |
| OPTIONS | Allowed methods (CORS)  | Yes        | Yes  | 200, 204           |

## Status Codes

**2xx:** 200 OK, 201 Created (+Location), 202 Accepted (+status URL), 204 No Content.

**4xx:** 400 Bad Request (malformed), 401 Unauthorized (no/bad auth), 403 Forbidden (no permission), 404 Not Found, 405
Method Not Allowed (+Allow header), 409 Conflict (duplicate/version), 410 Gone (permanent delete), 422 Unprocessable (
validation), 429 Too Many Requests (+Retry-After).

**5xx:** 500 Internal (never leak traces), 502 Bad Gateway, 503 Service Unavailable (+Retry-After), 504 Gateway Timeout.

## RFC 7807 Problem Details

```php
final class ProblemDetailsFactory
{
    public function create(int $status, string $title, string $type, string $detail = '', array $ext = []): ResponseInterface
    {
        $body = array_filter(['type' => $type, 'title' => $title, 'status' => $status, 'detail' => $detail] + $ext);
        $response = $this->responseFactory->createResponse($status);
        $response->getBody()->write(json_encode($body, JSON_THROW_ON_ERROR));
        return $response->withHeader('Content-Type', 'application/problem+json');
    }
}
```

## PSR-7 Essentials

```php
$body   = $request->getParsedBody();          // parsed POST/PATCH body
$page   = (int) ($request->getQueryParams()['page'] ?? 1);
$id     = (int) $request->getAttribute('id'); // router attribute
$accept = $request->getHeaderLine('Accept');
// Immutable: $response = $response->withStatus(200)->withHeader('Content-Type', 'application/json');
```

## Content Negotiation

```php
function negotiateContentType(ServerRequestInterface $request): string
{
    $accept = $request->getHeaderLine('Accept');
    return match (true) {
        str_contains($accept, 'application/vnd.api+json') => 'application/vnd.api+json',
        str_contains($accept, 'application/json')         => 'application/json',
        default                                            => 'application/json',
    };
}
```

Return `406 Not Acceptable` when no match. HATEOAS: include `self` on every resource, `next`/`prev`/`first`/`last` on
collections. Show contextual action links (e.g., `publish` only on drafts).

## Response Envelopes

Single: `{"data": {...}, "links": {"self": "..."}}`. Collection:
`{"data": [...], "meta": {"total", "per_page", "current_page", "last_page"}, "links": {"self", "first", "prev", "next", "last"}}`.

```php
final class JsonResponseFactory
{
    public function resource(mixed $data, array $links = [], int $status = 200): ResponseInterface
    { return $this->json(['data' => $data, 'links' => $links], $status); }

    public function collection(array $data, PaginationMeta $meta, array $links = []): ResponseInterface
    { return $this->json(['data' => $data, 'meta' => $meta->toArray(), 'links' => $links]); }
}
```

## DTO and Transformer Patterns

```php
// DTO — explicit API contract
final readonly class ArticleResource {
    public function __construct(public int $id, public string $title, public string $status, public DateTimeImmutable $createdAt) {}
    public function toArray(): array {
        return ['id' => $this->id, 'type' => 'article', 'title' => $this->title,
                'status' => $this->status, 'created_at' => $this->createdAt->format(DateTimeImmutable::ATOM)];
    }
}

// Fractal transformer — league/fractal
final class ArticleTransformer extends TransformerAbstract {
    protected array $availableIncludes = ['author', 'comments'];
    protected array $defaultIncludes = ['author'];
    public function transform(Article $article): array {
        return ['id' => $article->getId(), 'title' => $article->getTitle(),
                'created_at' => $article->getCreatedAt()->format(DateTimeImmutable::ATOM)];
    }
    public function includeAuthor(Article $article): Item {
        return $this->item($article->getAuthor(), new UserTransformer());
    }
}
```

**JSON:API:** `id` always string, `type` plural, related in `included` (sideloading),
`Content-Type: application/vnd.api+json`. Higher structure overhead — best for relationship-heavy APIs with generic
client tooling.

## Pagination

**Offset/limit** (`?page=3&per_page=20`): simple, O(n) at large offsets.

```php
final readonly class PaginationMeta {
    public function __construct(public int $total, public int $perPage, public int $currentPage) {}
    public function lastPage(): int { return (int) ceil($this->total / $this->perPage); }
}
```

**Cursor** (`?after=eyJpZCI6NDJ9&limit=20`): stable, O(1), preferred for large datasets.

```php
function encodeCursor(array $pos): string { return base64_encode(json_encode($pos, JSON_THROW_ON_ERROR)); }
function decodeCursor(string $c): array {
    $d = base64_decode($c, strict: true);
    if ($d === false) throw new \InvalidArgumentException('Invalid cursor');
    return json_decode($d, true, flags: JSON_THROW_ON_ERROR);
}
```

## Versioning

**URL** (public): `/api/v1/...` — obvious, cacheable, ~70% industry adoption.

**Header** (internal): `Api-Version: 2` or `Accept: application/vnd.myapi.v2+json`. Set `Vary: Api-Version, Accept`.

```php
function resolveApiVersion(ServerRequestInterface $request): string {
    if ($request->hasHeader('Api-Version')) return $request->getHeaderLine('Api-Version');
    if (preg_match('/application\/vnd\.myapi\.v(\d+)\+json/', $request->getHeaderLine('Accept'), $m)) return $m[1];
    return '1';
}
```

**Non-breaking:** add optional fields/params/endpoints, relax validation. **Breaking:** remove/rename fields, change
types/status codes/auth, make optional required.

## Deprecation

RFC 8594 Sunset header. Windows: internal 4-8 weeks, public 6-12 months.

```php
final class DeprecationHeaderMiddleware implements MiddlewareInterface {
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface {
        return $handler->handle($request)
            ->withHeader('Deprecation', 'true')
            ->withHeader('Sunset', $this->sunsetDate)
            ->withHeader('Link', "<{$this->migrationUrl}>; rel=\"successor-version\"");
    }
}
```

Log deprecated endpoint requests. At sunset: return `410 Gone`.

## Rate Limiting

| Algorithm      | Burst | Memory | Boundary | Best For             |
|----------------|-------|--------|----------|----------------------|
| Fixed Window   | No    | O(1)   | 2x burst | Simple internal APIs |
| Sliding Window | No    | O(n)   | None     | Consumer-facing      |
| Token Bucket   | Yes   | O(1)   | None     | Burst-tolerant       |

Headers (always): `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`. On 429: `Retry-After` + RFC 7807
body.

Keys: `rate_limit:user:{id}`, `rate_limit:ip:{ip}`, `rate_limit:tier:{tier}:{id}`. Tiers: unauth 30/min, free 100/min,
paid 1000/min.

PSR-15 middleware with `RateLimiterInterface` and `KeyResolverInterface`. Use Redis atomic ops (pipeline/Lua).

```php
final readonly class RateLimitResult {
    public function __construct(public bool $allowed, public int $limit, public int $remaining, public int $resetAt) {}
}
interface RateLimiterInterface { public function check(string $key): RateLimitResult; }
interface KeyResolverInterface { public function resolve(ServerRequestInterface $request): string; }
```
