# Guardrails

All code must pass the following automated checks before it is considered mergeable. These checks run in CI and, where
noted, as local pre-commit hooks. A failing check blocks merge — no exceptions without a documented, time-boxed
exemption approved by a lead.

---

## PHP

### Static Analysis

- **Larastan** (PHPStan for Laravel) passes at the project's configured level (minimum level 6 for new projects;
  existing projects must ratchet upward over time and never regress).
- **Rector** dry-run passes with zero suggested changes. The active rule sets enforce the project's minimum PHP version
  patterns and prevent introduction of deprecated or legacy constructs.
- **Psalm** taint analysis passes on all routes handling user input (where adopted). No new taint violations may be
  introduced.

### Formatting

- **Pint** reports zero formatting differences. Code must conform to the project's configured preset. This is enforced
  as a pre-commit hook; CI acts as a backstop.

### Testing

- **Pest** (or PHPUnit) test suite passes with zero failures.
- **Pest Architectural Tests** pass, confirming that project structure rules (dependency boundaries, inheritance
  contracts, namespace conventions) are satisfied.
- Code coverage does not drop below the per-module thresholds defined in the project's coverage configuration.

### Dependency Health

- `composer audit` reports zero known vulnerabilities at or above the project's severity threshold.
- `composer licenses` confirms no newly added dependency introduces a license incompatible with the project's license
  policy.

---

## JavaScript / TypeScript

### Static Analysis & Linting

- **TypeScript (`tsc --noEmit`)** passes with zero errors. `strict` mode is enabled. The `noExplicitAny` flag (or the
  ESLint equivalent `@typescript-eslint/no-explicit-any`) is set to error — no untyped escape hatches.
- **ESLint** passes with zero errors at the project's configured rule set. At minimum, the following categories of rules
  are active:
  - Correctness (e.g., `no-floating-promises`, `no-misused-promises`)
  - Security (e.g., `eslint-plugin-security` or equivalent)
  - Import hygiene (e.g., `no-cycle`, `no-unused-modules` via `eslint-plugin-import`)
- **Knip** reports zero unused dependencies, unused exports, or dead files (where adopted).

### Formatting

- **Prettier** exits cleanly with `--check` mode. Zero formatting differences. Enforced as a pre-commit hook; CI acts as
  a backstop.

### Testing

- **Vitest** (or Jest) test suite passes with zero failures.
- Per-module coverage thresholds are met. Thresholds are defined in the test configuration and may only be raised, never
  lowered, without documented approval.

### Dependency Health

- `npm audit` (or equivalent for the package manager in use) reports zero known vulnerabilities at or above the
  project's severity threshold.
- License check tooling (e.g., `license-checker`) confirms no newly added dependency introduces an incompatible license.

---

## Python

### Static Analysis & Linting

- **Ruff** passes with zero errors at the project's configured rule set. Rule selection should include, at minimum:
  - Pyflakes (`F`) and pycodestyle (`E`, `W`) base rules
  - isort-compatible import sorting (`I`)
  - Bugbear (`B`) for common pitfalls
  - Bandit-derived security rules (`S`) for hardcoded secrets, unsafe deserialization, `eval()` usage, etc.
  - Complexity limits (`C90`) at the project's configured threshold
- **Pyright** (or mypy) passes in strict mode with zero errors. All function signatures must carry type annotations.
  `Any` usage requires a justifying comment or is banned outright via configuration.

### Formatting

- **Black** reports zero formatting differences. Enforced as a pre-commit hook; CI acts as a backstop.

### Testing

- **pytest** test suite passes with zero failures.
- Per-module coverage thresholds (enforced via `pytest-cov` or equivalent) are met. Thresholds may only be raised, never
  lowered, without documented approval.

### Dependency Health

- `pip-audit` reports zero known vulnerabilities at or above the project's severity threshold.
- License check tooling (e.g., `pip-licenses`) confirms no newly added dependency introduces an incompatible license.

---

## Cross-Cutting (All Runtimes)

### Secret Detection

- **Gitleaks** (or TruffleHog) scan passes against the full diff with zero findings. This runs both as a pre-commit hook
  and in CI. A finding of any severity blocks merge — there is no acceptable threshold for leaked secrets.

### Security Scanning (SAST)

- **Semgrep** (or equivalent SAST tool) passes with zero findings at or above the project's configured severity.
  Community and custom rule sets covering OWASP Top 10 patterns are active and updated regularly.

### Container & Infrastructure (where applicable)

- **Hadolint** reports zero errors on any modified Dockerfiles.
- **Trivy** image scan reports zero critical or high vulnerabilities on any built container images.
- **Checkov** or **tfsec** passes on all modified infrastructure-as-code files (Terraform, CloudFormation, etc.) with
  zero failures at the project's configured severity.

### Database Migrations (where applicable)

- **Squawk** (Postgres) or equivalent migration linter passes on all new migration files. Dangerous operations (e.g.,
  exclusive locks on large tables, non-backwards-compatible column drops, missing concurrent index creation) are flagged
  and must be resolved or explicitly exempted with a documented rollout plan.

### Commit & PR Hygiene

- All commit messages conform to the project's **Commitlint** configuration (e.g., Conventional Commits format).
- Branch protection rules require all of the above status checks to pass before merge. Force-pushes to protected
  branches are disabled.

### Dependency Automation

- **Dependabot** or **Renovate** is configured and active. Dependency update PRs are treated as part of the regular work
  queue, not ignored. Security-patch PRs are prioritized and merged within the project's defined SLA.

---

## Guiding Principles

1. **Layer by speed.** Formatting and fast linting run locally via pre-commit hooks (seconds). Static analysis and type
   checking run in CI (under two minutes). Full test suites, coverage enforcement, and security scans run as the final
   CI gate.
2. **Ratchet, don't leap.** New projects adopt the strictest feasible settings from day one. Existing projects set
   thresholds at current levels and increase them incrementally. Thresholds may never regress.
3. **Every failure is actionable.** If a check fails, the output must tell the developer exactly what to fix.
   Auto-fixable issues should be auto-fixed in hooks so they never reach CI.
4. **Exemptions are temporary and visible.** Any inline suppression (`@phpstan-ignore`, `// eslint-disable`, `# noqa`,
   etc.) requires a justifying comment. Broad file-level or rule-level suppressions require lead approval and a tracked
   ticket for removal.
5. **The pipeline is code.** CI configuration is reviewed with the same rigor as application code. Changes that weaken
   or disable checks require the same approval as exemptions.
