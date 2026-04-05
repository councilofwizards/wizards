---
feature: persona-authority-dry
agent: security-auditor
status: complete
started: 2026-04-05
completed: 2026-04-05
---

# Security Audit: Persona File Authority DRY Refactor (P3-32)

**Auditor**: Shade Valkyr, Shadow Warden **Scope**: Shell script validator, validate.sh registration, migrated SKILL.md
files, persona files **Verdict**: CLEAN — No actionable security findings

---

## Files Audited

| File                                       | Risk Level | Result |
| ------------------------------------------ | ---------- | ------ |
| `scripts/validators/persona-references.sh` | High       | Clean  |
| `scripts/validate.sh` (registration line)  | Low        | Clean  |
| 21+ migrated SKILL.md files (persona refs) | Low        | Clean  |
| 80+ persona files in `shared/personas/`    | Low        | Clean  |

---

## Detailed Analysis

### 1. persona-references.sh — Command Injection

**Checked**: All variable expansions for unquoted usage that could enable injection.

**Finding**: All variables are properly double-quoted throughout the script:

- `"$REPO_ROOT"` (line 7, 23, 58, 89)
- `"$filepath"` (lines 27, 60)
- `"$persona_path"` (lines 51, 58)
- `"$persona_file"` (lines 122, 125, 140, 148)

**No `eval`, no backtick command substitution, no unquoted expansions.** All command substitutions use `$()` form. Safe.

### 2. persona-references.sh — Path Traversal

**Checked**: Whether attacker-controlled content in SKILL.md spawn prompts could cause the validator to read or disclose
files outside the repo.

**Finding**: The extracted `persona_path` (line 48) is used only in a file-existence check:

```bash
if [ ! -f "$REPO_ROOT/$persona_path" ]; then
```

This is a boolean test — no file content is read, echoed, or disclosed. Even a crafted path like `../../etc/passwd`
would only produce a PASS/FAIL line. The validator is read-only and non-destructive.

Additionally, `REPO_ROOT` is set via `$(cd "$SCRIPT_DIR/.." && pwd)` in `validate.sh`, producing a canonicalized
absolute path — no symlink ambiguity.

### 3. persona-references.sh — String Handling

**Checked**: The `printf '%s\n' "$line" | grep` pattern used for line matching.

**Finding**: Using `printf '%s` is the correct safe idiom — it treats the variable as a literal string, preventing
`-e`/`-n` flag injection that can occur with `echo`. This pattern is used consistently (lines 35, 46, 51, 114, 153).

### 4. persona-references.sh — Glob Injection

**Checked**: Whether unquoted variable expansion could trigger filesystem globbing.

**Finding**: All variable references are double-quoted. No unquoted `$persona_path` or `$filepath` usage. Glob expansion
cannot occur.

### 5. persona-references.sh — TOCTOU (Race Conditions)

**Checked**: Whether file existence checks at line 58 could be exploited via time-of-check-time-of-use races.

**Finding**: The validator is read-only — it checks existence and reports. No subsequent action (copy, execute, source)
depends on the check result. TOCTOU is not exploitable here.

### 6. persona-references.sh — Frontmatter Parsing (P2)

**Checked**: Whether malicious YAML frontmatter in persona files could inject commands during parsing.

**Finding**: Frontmatter is parsed using `sed`, `grep`, and `awk` — no YAML library, no `eval`. The `archetype` value
extracted at line 162 is used only in a `case` statement (line 186) and `echo` output. The `case` statement safely
handles unknown values with a default branch. No injection vector.

### 7. validate.sh — Registration

**Checked**: The new `run_validator "persona-references.sh"` line.

**Finding**: Follows the identical pattern as all other validator registrations. The script path is hardcoded. Safe.

### 8. SKILL.md Persona File Paths

**Checked**: All `First, read` directives in migrated SKILL.md files for path traversal or absolute paths.

**Finding**: All 100+ references use the pattern:

```
First, read plugins/conclave/shared/personas/{name}.md for your complete role definition
```

- All paths are relative, rooted under `plugins/conclave/shared/personas/`
- No `../` path traversal in any reference
- No absolute paths
- One template placeholder (`{role-slug}.md` in create-conclave-team) is correctly skipped by the validator's
  space-detection guard (line 51)

### 9. Persona Files — Embedded Commands

**Checked**: All 80+ persona files for embedded shell commands, script injection, or dangerous patterns.

**Finding**: Grep for `eval`, `exec`, backtick substitutions, `$()`, `rm -rf`, `curl`, `wget` returned only markdown
template placeholders (e.g., `{scope}`, `{pr}`) inside code fences or path examples. No executable shell content. These
are static markdown consumed by Claude Code as prompt text.

### 10. Information Leakage

**Checked**: Whether error messages disclose sensitive information.

**Finding**: Error output includes file paths relative to the repo and frontmatter field names. No environment
variables, credentials, or system paths are disclosed. Appropriate for a development-only CI validator.

---

## Summary

The implementation is security-clean. Key defensive patterns observed:

1. **Consistent quoting** — every variable expansion is double-quoted
2. **Safe string handling** — `printf '%s'` instead of `echo` for untrusted data
3. **Read-only operations** — validator never writes, executes, or sources based on extracted values
4. **Hardcoded scope** — `find` is constrained to `$REPO_ROOT/plugins/conclave` and `$PERSONAS_DIR`
5. **Template skip guard** — paths containing spaces are skipped, preventing false positives on `{role-slug}`
   placeholders
6. **No dangerous constructs** — no `eval`, no backticks, no `source`, no unquoted expansions

No remediation required.
