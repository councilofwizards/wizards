# Definition of Done

> _Done = works, safe, tested, observable, documented, deployable, adversarially reviewed._

Baseline quality gates for all agent-produced code. Language- and framework-agnostic. Every item is mandatory unless
marked SHOULD. Complements `pattern-catalog.md`, `error-standards.md`, and `api-style-guide.md` in this directory.

## Agents: How to Reference

- **Architect**: Sections 4, 8, 9, 11 — design for compliance
- **Engineer**: All sections — implement to spec
- **Test Smith**: Sections 3, 6, 10 — verify via tests
- **Security Auditor**: Section 2 primary; 7, 8, 9 supporting
- **Gremlin**: All sections — audit as MET / PARTIAL / UNMET with evidence

---

## 1. Code Quality

- **CQ-01** Zero linter/formatter errors and warnings.
- **CQ-02** Descriptive, unambiguous names following project conventions.
- **CQ-03** Cyclomatic complexity <= 15. Evaluate decomposition at 10.
- **CQ-04** No magic numbers or strings. Use constants, enums, or config.
- **CQ-05** No dead code: unreachable branches, commented-out blocks, unused imports/vars/functions.
- **CQ-06** Logic duplicated 3+ times extracted to shared function. 2x duplication may remain if extraction harms
  clarity.
- **CQ-07** Single responsibility per function. Evaluate decomposition at 40 lines.
- **CQ-08** Every TODO/FIXME/HACK references a tracked issue number.
- **CQ-09** Explicit return types and signatures in typed languages. No implicit `any`.
- **CQ-10** No hardcoded environment values (URLs, ports, hosts, paths, creds). Externalize to config/env.
- **CQ-11** No boolean params for behavior branching. Use separate functions, enums, or option objects.
- **CQ-12** Max 3 levels of conditional nesting. Use early returns, guards, or extraction.

## 2. Security

- **SC-01** Validate, sanitize, parameterize all user input before queries, commands, paths, or output.
- **SC-02** Secrets never in source, commits, logs, errors, or agent context. Load from secrets manager or env. _(Iron
  Law 13)_
- **SC-03** Rate limiting and lockout/progressive delay on all auth endpoints.
- **SC-04** Authorization at resource level, not just route level.
- **SC-05** Security headers on all responses: CSP, X-Content-Type-Options, HSTS, X-Frame-Options.
- **SC-06** Vetted crypto libraries only. No hand-rolled crypto.
- **SC-07** File uploads: server-side MIME validation, size limits, sanitized filenames, non-executable storage.
- **SC-08** Regenerate session tokens on auth state changes (login, logout, escalation).
- **SC-09** AES-256+ at rest. TLS 1.2+ in transit.
- **SC-10** CVE scan all deps before merge. Critical/high blocks merge.
- **SC-11** Redact sensitive values in logs and errors. No PII, tokens, passwords, or full bodies in production logs.
- **SC-12** Mass assignment protection enabled. Explicit field whitelisting only.

## 3. Testing

- **TS-01** Unit tests for all new public functions: happy path, error path, boundary conditions.
- **TS-02** Integration tests for component interactions: API-to-DB, service-to-service, event-to-handler.
- **TS-03** Coverage meets project threshold. Default: 80% line coverage on new code.
- **TS-04** Explicit edge case tests: empty, null, boundary, max size, unicode, concurrency, external failures.
- **TS-05** Regression test for every bug fix, merged alongside the fix.
- **TS-06** Deterministic tests. No wall-clock, external services, execution order, or unseeded randomness.
- **TS-07** CI runs tests on every PR. Failing test blocks merge. No exceptions.
- **TS-08** Test names describe scenario and expected outcome.
- **TS-09** Mocks don't mask behavior under test. Prefer fakes. Mock boundaries, not implementations.
- **TS-10** Maintain test pyramid: unit > feature > integration > E2E. _(Iron Law 10)_

## 4. Performance

- **PF-01** No queries in loops. Eager load, batch fetch, join, or subquery.
- **PF-02** Every allocation (cache, buffer, listener, handle, connection) has a cleanup path.
- **PF-03** Document algorithmic complexity for non-trivial algorithms. Justify or replace O(n^2)+ on user-controlled
  input.
- **PF-04** Bounded API responses. Paginate, cursor, or stream collections. No unbounded SELECT or full-collection
  returns.
- **PF-05** Indexed columns for WHERE, JOIN, ORDER BY. Verify via EXPLAIN on large tables.
- **PF-06** Long-running ops (email, PDF, external APIs, bulk processing) offloaded to background jobs.
- **PF-07** SHOULD cache expensive/stable data with explicit TTL and invalidation.
- **PF-08** Minimal transaction duration. No external calls, file I/O, or blocking ops inside transactions.

## 5. Documentation

- **DC-01** Inline comments for non-obvious logic, workarounds, and "why" decisions. Never restate what code does.
- **DC-02** Public API endpoints documented: schemas, status codes, auth, examples.
- **DC-03** Breaking changes include changelog entry with migration instructions.
- **DC-04** Deprecated items annotated with version and replacement path.
- **DC-05** README updated when setup, env vars, services, or deps change.
- **DC-06** Plain-language explanation for complex regex, bitwise ops, and non-obvious algorithms.

## 6. Error Handling

- **EH-01** Wrap all external calls (network, FS, DB, APIs) with contextual error handling.
- **EH-02** Actionable errors: what failed, why, what to do. No stack traces or internal paths in user-facing errors.
- **EH-03** Correct error categorization: 4xx vs 5xx; recoverable vs fatal.
- **EH-04** Failed ops leave no inconsistent state. Use transactions, compensation, or idempotent ops.
- **EH-05** No silent exception swallowing. Log, propagate, or justify with comment.
- **EH-06** Retry with exponential backoff + jitter + max count. No unbounded retries.
- **EH-07** Return all validation errors at once, not one at a time.

## 7. Observability

- **OB-01** Structured logs with correlation IDs for state transitions and business events.
- **OB-02** Correct log levels: ERROR = needs intervention, WARN = degraded, INFO = business events, DEBUG =
  diagnostics.
- **OB-03** RED metrics on all services/endpoints: Rate, Errors, Duration.
- **OB-04** Propagate trace context (OpenTelemetry or equivalent) across service boundaries.
- **OB-05** Health checks verify downstream deps (DB, cache, broker, critical APIs).
- **OB-06** Alert definitions for critical failure paths, or documented for ops to configure.

## 8. Database

- **DB-01** Versioned, forward-only migrations for all schema changes.
- **DB-02** Every migration has tested rollback or documented manual rollback. _(Iron Law 08)_
- **DB-03** New columns on existing tables: nullable or defaulted. No bare NOT NULL.
- **DB-04** Explicit ON DELETE on all foreign keys (CASCADE, SET NULL, or RESTRICT).
- **DB-05** Indexes on WHERE, JOIN, ORDER BY columns for tables >10k rows.
- **DB-06** Data migrations separate from schema migrations. Idempotent.
- **DB-07** Parameterized queries only. No string concatenation for query building.
- **DB-08** Unique and check constraints at database level, not just application code.
- **DB-09** Backward-compatible migrations. Multi-step for renames, type changes, drops: add new -> migrate -> deploy ->
  drop old.

## 9. API Design

- **AP-01** One versioning strategy (URL path, header, or query param), applied consistently.
- **AP-02** Schema-validated input at API boundary. 400 with field-level errors on invalid input.
- **AP-03** State-mutating endpoints are idempotent, or document non-idempotency explicitly.
- **AP-04** Rate limiting on all public endpoints. Document limits. 429 with Retry-After.
- **AP-05** Consistent response envelope: data, errors, pagination metadata.
- **AP-06** ISO 8601 UTC timestamps everywhere. No locale-specific formats.
- **AP-07** Bulk endpoints: max batch size, per-item success/failure results.
- **AP-08** Programmatic error codes beyond HTTP status (e.g., `INSUFFICIENT_BALANCE`).

## 10. Accessibility (Frontend)

- **AX-01** Keyboard-navigable interactive elements with visible focus indicators.
- **AX-02** Meaningful alt text on non-decorative images. `alt=""` on decorative images.
- **AX-03** Color never sole information channel. Pair with text, icons, or patterns.
- **AX-04** Contrast: 4.5:1 normal text, 3:1 large text (WCAG AA).
- **AX-05** Labels on all form inputs. Error states announced via aria-live.
- **AX-06** Functional from 320px to 2560px. No mobile horizontal scroll.
- **AX-07** Visible loading, error, and empty states. Progress indicators for ops >1s.
- **AX-08** Touch targets >= 44x44 CSS pixels.

## 11. Deployment

- **DP-01** Backward-compatible with previous deployed version. Supports rolling deploy and instant rollback.
- **DP-02** Migrations deployed and verified before dependent code.
- **DP-03** Incomplete/risky features behind feature flag, defaulting OFF in production.
- **DP-04** Rollback plan for every deployment. No new build or manual DB work required.
- **DP-05** Externalized env config. Same artifact deployable to any environment.
- **DP-06** Full test suite + security scan in pipeline before production. No bypass.

## 12. Dependencies

- **DEP-01** License-compatible with project. No license conflicts.
- **DEP-02** Pinned versions. Lockfile committed.
- **DEP-03** Transitive CVE scan. Critical/high blocks merge.
- **DEP-04** Justify necessity. Prefer stdlib for trivial functionality.
- **DEP-05** No abandoned deps (2yr no release, archived, 6mo no response) without justification + exit plan.
- **DEP-06** No vendoring unless build system requires it. Use package managers.

---

## Applicability Matrix

| Section           |     Architect     |  Engineer  |     Test Smith      | Security Auditor | Gremlin |
| ----------------- | :---------------: | :--------: | :-----------------: | :--------------: | :-----: |
| 1. Code Quality   |    Design for     |  Enforce   |       Verify        |        —         |  Audit  |
| 2. Security       |    Design for     |  Enforce   |   Verify critical   |   Enforce all    |  Audit  |
| 3. Testing        |    Testability    | Unit tests | Feature/integration |  Coverage check  |  Audit  |
| 4. Performance    |    Design for     |  Enforce   |     Benchmarks      |        —         |  Audit  |
| 5. Documentation  |     Arch docs     | Eng notes  |          —          |     Findings     |  Audit  |
| 6. Error Handling |     Patterns      |  Enforce   |     Error paths     |     No leaks     |  Audit  |
| 7. Observability  |     Strategy      | Implement  |          —          |  No PII in logs  |  Audit  |
| 8. Database       | Schema/migrations | Implement  |   Test migrations   | Parameterization |  Audit  |
| 9. API Design     |     Contracts     | Implement  |   Test contracts    | Auth/validation  |  Audit  |
| 10. Accessibility |         —         | Implement  |    Interactions     |        —         |  Audit  |
| 11. Deployment    |   Compatibility   |   Flags    |          —          |        —         |  Audit  |
| 12. Dependencies  |  Select/justify   | Implement  |          —          |     CVE scan     |  Audit  |
