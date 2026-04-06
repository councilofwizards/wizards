# Error Taxonomy & Logging Standards

Canonical error handling and observability rules for all agent-produced code. Complements `definition-of-done.md`
sections EH and OB. Every API and background process must conform.

## Agents: How to Reference

- **Architect**: Sections 1-2, 4 -- design error handling strategy and logging architecture
- **Engineer**: All sections -- implement to spec
- **Security Auditor**: Sections 2, 3 (LS-05, LS-06) -- verify no PII/secret leaks in logs or error responses
- **Gremlin**: All sections -- audit compliance as MET / PARTIAL / UNMET with evidence

---

## 1. Error Categories

### Client Errors (4xx)

| ID    | Type           | HTTP | Retryable | Notes                                       |
| ----- | -------------- | ---- | --------- | ------------------------------------------- |
| ET-01 | Validation     | 400  | No        | Return all field errors at once             |
| ET-02 | Authentication | 401  | No        | Never reveal whether user/email exists      |
| ET-03 | Authorization  | 403  | No        | Resource-level, not route-level             |
| ET-04 | Not Found      | 404  | No        | Applies to missing resources, not endpoints |
| ET-05 | Conflict       | 409  | No        | Concurrent modification, duplicate creation |
| ET-06 | Rate Limit     | 429  | Yes       | Include Retry-After header                  |

### Server Errors (5xx)

| ID    | Type               | HTTP | Retryable | Notes                                      |
| ----- | ------------------ | ---- | --------- | ------------------------------------------ |
| ET-07 | Internal           | 500  | No        | Catch-all. Log full context server-side    |
| ET-08 | Dependency Failure | 502  | Yes       | Upstream service returned invalid response |
| ET-09 | Timeout            | 504  | Yes       | Upstream or internal operation timed out   |
| ET-10 | Unavailable        | 503  | Yes       | Service overloaded or in maintenance       |

### Domain Errors

| ID    | Type                    | HTTP | Retryable | Notes                                       |
| ----- | ----------------------- | ---- | --------- | ------------------------------------------- |
| ET-11 | Business Rule Violation | 422  | No        | e.g., insufficient balance, expired offer   |
| ET-12 | State Machine Violation | 409  | No        | Invalid state transition                    |
| ET-13 | Constraint Violation    | 422  | No        | Domain invariant broken (not DB constraint) |

### Infrastructure Errors

| ID    | Type                | HTTP | Retryable | Notes                                       |
| ----- | ------------------- | ---- | --------- | ------------------------------------------- |
| ET-14 | Connection          | 503  | Yes       | DB, cache, broker, external API unreachable |
| ET-15 | Resource Exhaustion | 503  | Yes       | Memory, disk, connections, file handles     |
| ET-16 | Configuration       | 500  | No        | Missing env var, invalid config value       |

### Retry Rules

- Retryable errors: exponential backoff + jitter. Max 3 attempts. Circuit breaker after 5 consecutive failures.
- Non-retryable errors: fail immediately. Do not retry.
- Queue workers: retryable errors requeue with backoff. Non-retryable errors move to dead letter.

---

## 2. Error Response Schema

All API error responses use this shape. No exceptions.

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "One or more fields are invalid.",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Must be a valid email address."
      }
    ],
    "request_id": "req_abc123"
  }
}
```

| Field              | Type   | Required | Notes                                                                |
| ------------------ | ------ | -------- | -------------------------------------------------------------------- |
| `error.code`       | string | Yes      | Machine-readable. SCREAMING_SNAKE_CASE.                              |
| `error.message`    | string | Yes      | Human-readable. No internal paths or traces.                         |
| `error.details`    | array  | No       | Field-level errors. Present on ET-01, ET-13.                         |
| `error.request_id` | string | Yes      | Correlation ID. Propagated from request header or generated at edge. |

Rules:

- Never expose stack traces, internal paths, SQL, or raw exception messages to clients.
- `code` values are project-global constants. Define in a single enum/class.
- `details[].field` uses dot notation for nested fields: `address.zip_code`.
- 5xx responses: generic message to client, full context in server logs.

---

## 3. Logging Standards

### Log Format (LS-01)

JSON Lines. One JSON object per log entry. No multiline exceptions in raw form -- serialize to single string.

### Required Fields (LS-02)

| Field            | Type   | Format                | Notes                         |
| ---------------- | ------ | --------------------- | ----------------------------- |
| `timestamp`      | string | ISO 8601 UTC          | `2026-04-05T14:30:00.000Z`    |
| `level`          | string | ERROR/WARN/INFO/DEBUG | Uppercase                     |
| `service`        | string |                       | Service or app name           |
| `correlation_id` | string |                       | From request header or job ID |
| `message`        | string |                       | What happened. No PII.        |

### Optional Context Fields (LS-03)

| Field         | Notes                                     |
| ------------- | ----------------------------------------- |
| `user_id`     | Authenticated user. Never email or name.  |
| `endpoint`    | HTTP method + path                        |
| `duration_ms` | Request or operation duration             |
| `error_code`  | From error taxonomy (ET-xx code string)   |
| `stack_trace` | Server-side only. Never in responses.     |
| `metadata`    | Bag of key-value pairs for domain context |

### Log Levels (LS-04)

| Level | Use when                                      | Do NOT use when                              |
| ----- | --------------------------------------------- | -------------------------------------------- |
| ERROR | Requires human intervention. Data loss risk.  | Expected failures (auth, validation).        |
| WARN  | Degraded but functional. Approaching limits.  | Normal business events.                      |
| INFO  | Business events: created, updated, completed. | Internal implementation details.             |
| DEBUG | Diagnostic detail for troubleshooting.        | Production default. Enable per-service only. |

### PII & Secrets Redaction (LS-05)

- Never log: passwords, tokens, API keys, session IDs, credit card numbers, SSNs.
- Redact before logging: email, phone, IP address, full name. Replace with hashed or truncated form.
- Request/response body logging: strip sensitive fields. Allowlist approach, not denylist.
- Log audit: Security Auditor reviews log output as part of every engineering review.

### Correlation ID Propagation (LS-06)

- Edge generates `X-Correlation-ID` if absent. UUID v4.
- Every downstream call (HTTP, queue, event) propagates the correlation ID.
- All log entries for a request share the same correlation ID.
- Queue workers: correlation ID from the job payload, not from the worker process.

### Log Rotation & Retention (LS-07)

- Rotate daily or at 100MB, whichever comes first.
- Retain: ERROR 90 days, WARN 30 days, INFO 14 days, DEBUG 3 days.
- Compressed archive after rotation. Delete after retention window.

### What to Log by Layer (LS-08)

| Layer          | Log                                                  | Level |
| -------------- | ---------------------------------------------------- | ----- |
| Controller     | Request received, response sent, validation failures | INFO  |
| Service        | Business events, state transitions, external calls   | INFO  |
| Repository     | Slow queries (>100ms), connection failures           | WARN  |
| Queue Worker   | Job start, complete, fail, retry, dead-letter        | INFO  |
| Scheduled Task | Run start, complete, skip (overlap), fail            | INFO  |

---

## 4. Alert Thresholds

Defaults. Override per-service in monitoring config.

### Error Rate

| Condition                      | Severity | Action       |
| ------------------------------ | -------- | ------------ |
| 5xx rate > 1% of requests / 5m | Warning  | Notify       |
| 5xx rate > 5% of requests / 5m | Critical | Page on-call |
| Any 5xx on health check        | Critical | Page on-call |

### Latency

| Condition              | Severity | Action       |
| ---------------------- | -------- | ------------ |
| p95 > 2x baseline / 5m | Warning  | Notify       |
| p99 > 5s / 5m          | Critical | Page on-call |

### Queue Depth

| Condition                 | Severity | Action       |
| ------------------------- | -------- | ------------ |
| Pending jobs > 1000 / 5m  | Warning  | Notify       |
| Dead letter queue > 0     | Warning  | Notify       |
| Pending jobs > 10000 / 5m | Critical | Page on-call |

### Resource Utilization

| Condition                    | Severity | Action       |
| ---------------------------- | -------- | ------------ |
| CPU > 80% sustained / 10m    | Warning  | Notify       |
| Memory > 85% / 5m            | Warning  | Notify       |
| Disk > 90%                   | Critical | Page on-call |
| DB connections > 80% of pool | Warning  | Notify       |
