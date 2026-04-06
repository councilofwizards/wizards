# API & Interface Contract Style Guide

Canonical rules for all HTTP APIs, webhooks, and internal service contracts produced by agent pipelines.
Language-agnostic. Agents design, implement, and audit against this document.

## Agents: How to Reference

- **Architect**: Design contracts against this guide
- **Engineer**: Implement to spec
- **Gremlin**: Audit compliance

---

## 1. URL Structure

- **API-01** Plural nouns for resources. `/users`, not `/user`.
- **API-02** Nested resources for ownership. `/users/{id}/orders`.
- **API-03** Max 2 levels of nesting. Beyond that, promote to top-level with filter params.
- **API-04** Kebab-case for multi-word resources. `/order-items`, not `/orderItems`.
- **API-05** No verbs in URLs. Use HTTP methods or action sub-resources (`POST /orders/{id}/cancel`).
- **API-06** Query params for filtering, sorting, pagination. `?status=active&sort=-created_at&cursor=abc`.
- **API-07** Cursor-based pagination preferred. Offset-based acceptable for admin/backoffice.

## 2. HTTP Methods

| Method | Semantics        | Idempotent | Request Body | Success Code | Error Codes   |
| ------ | ---------------- | ---------- | ------------ | ------------ | ------------- |
| GET    | Read resource(s) | Yes        | None         | 200          | 404           |
| POST   | Create resource  | No         | Required     | 201          | 400, 409, 422 |
| PUT    | Full replace     | Yes        | Required     | 200          | 400, 404, 422 |
| PATCH  | Partial update   | No         | Required     | 200          | 400, 404, 422 |
| DELETE | Remove resource  | Yes        | None         | 204          | 404           |

- **API-08** POST returns the created resource with `Location` header.
- **API-09** PUT replaces the entire resource. Omitted fields reset to defaults.
- **API-10** DELETE on already-deleted resource returns 204, not 404.

## 3. Request/Response Conventions

- **API-11** Content type: `application/json` for all requests and responses.
- **API-12** Field names: `snake_case`. No exceptions.
- **API-13** Response envelope:

```json
{
  "data": {},
  "meta": {},
  "error": {}
}
```

`error` uses the schema from `error-standards.md`. Present only on error responses; omit on success.

- **API-14** Collection responses wrap array in `data`. Single resources also use `data`.
- **API-15** Cursor pagination meta:

```json
{ "meta": { "cursor": "abc123", "has_more": true, "per_page": 25 } }
```

- **API-16** Offset pagination meta (when used):

```json
{ "meta": { "page": 2, "per_page": 25, "total": 142 } }
```

- **API-17** PATCH semantics: absent field = unchanged. `null` = clear the value.
- **API-18** Dates/times: ISO 8601, UTC always. `2026-04-05T14:30:00Z`. No offsets.
- **API-19** Money: integer cents + ISO 4217 currency code. `{ "amount": 1999, "currency": "USD" }`. Never floats.
- **API-20** Boolean fields prefixed with `is_`, `has_`, or `can_`.
- **API-21** Empty collections return `[]`, not `null`.

## 4. Error Format

See `error-standards.md` for the canonical error taxonomy and response schema. Summary:

- **API-22** Error envelope (from error-standards.md):

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "One or more fields are invalid.",
    "details": [{ "field": "email", "code": "INVALID_FORMAT", "message": "Must be a valid email address." }],
    "request_id": "req_abc123"
  }
}
```

- **API-23** Machine-readable `code` on every error. SCREAMING_SNAKE_CASE. No reliance on HTTP status alone.
- **API-24** Validation errors (ET-01) return 400 with `details` array of per-field entries.
- **API-25** 500 errors: generic message to client, full context to server logs. Never leak stack traces.

## 5. Authentication & Authorization

- **API-26** Bearer token via `Authorization: Bearer <token>` header.
- **API-27** API key via `X-Api-Key` header for machine-to-machine.
- **API-28** 401: missing or invalid credentials. 403: valid credentials, insufficient permissions.
- **API-29** Rate limit headers on every response:

| Header                  | Value                                |
| ----------------------- | ------------------------------------ |
| `X-RateLimit-Limit`     | Max requests per window              |
| `X-RateLimit-Remaining` | Requests left in window              |
| `X-RateLimit-Reset`     | UTC epoch seconds when window resets |

- **API-30** 429 when rate limit exceeded. Include `Retry-After` header (seconds).

## 6. Versioning

- **API-31** URL path versioning: `/v1/users`. No header-based versioning.
- **API-32** Breaking changes (require version bump):
  - Removing or renaming a field
  - Changing a field's type
  - Removing an endpoint
  - Changing response structure
- **API-33** Non-breaking changes (no version bump):
  - Adding optional fields
  - Adding new endpoints
  - Adding new enum values (if clients handle unknown values)
- **API-34** Deprecation lifecycle: announce with `Sunset` header and docs update, dual-support minimum 6 months, then
  remove.

## 7. Event / Webhook Contracts

- **API-35** Event envelope:

```json
{
  "id": "evt_abc123",
  "type": "order.completed",
  "created_at": "2026-04-05T14:30:00Z",
  "data": {}
}
```

- **API-36** Delivery guarantee: at-least-once. Consumers must be idempotent. Deduplicate on `id`.
- **API-37** Retry policy: exponential backoff. 1s, 5s, 30s, 5m, 30m, 2h, 12h. Stop after 72h.
- **API-38** Signature verification: HMAC-SHA256 in `X-Webhook-Signature` header. Receivers verify before processing.
- **API-39** Webhook endpoints return 2xx within 10s. Anything else triggers retry.

## 8. Internal Service Contracts

- **API-40** Same conventions as external APIs. No "internal-only" shortcuts.
- **API-41** Service discovery via environment config. No hardcoded hostnames or ports.
- **API-42** Circuit breaker on all outbound calls. Open after 5 consecutive failures. Half-open retry after 30s.
- **API-43** Default timeouts: read 5s, connect 2s. Override per-endpoint if justified and documented.
- **API-44** Propagate correlation ID (`X-Request-Id`) across all internal calls.
- **API-45** Internal errors: log full context, return generic 502/503 to upstream callers.
