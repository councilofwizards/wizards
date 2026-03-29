# Laravel Stack Hints

These hints are automatically prepended to agent spawn prompts when a Laravel
project is detected (via `composer.json` containing `laravel/framework`).

## General Principles

- Follow the "Laravel Way" — prefer Eloquent, Blade, built-in helpers, and
  conventions over custom solutions.
- Use `artisan` commands for scaffolding (`make:model`, `make:controller`,
  `make:request`, etc.).

## Backend Engineer Hints

- **Models**: Use Eloquent models with relationships, scopes, accessors, and
  mutators.
- **Validation**: Use Form Request classes for validation. Controllers don't
  validate.
- **Serialization**: Use API Resources for response shaping. Controllers return
  Resources.
- **Authorization**: Use Policies and Gates for authorization logic.
- **Background work**: Use Jobs, Events, Notifications, and Listeners for async
  processing.
- **Facades**: Avoid static facade calls in business logic — use dependency
  injection instead.
- **Testing**: Use Laravel's built-in testing helpers. Feature tests for
  auth/authorization flows, complex query scopes, migration verification.

## DBA Hints

- Follow Laravel migration conventions (`Schema::create`,
  `$table->timestamps()`, etc.).
- Use Eloquent relationships to define the data model in code.
- Soft deletes via `SoftDeletes` trait where audit trails are needed.

## Architect Hints

- Prefer Laravel's built-in service container, middleware, and event system.
- Use service providers for binding interfaces to implementations.
- Follow the standard Laravel directory structure unless there's a compelling
  reason to deviate.
- Relentlessly maintain lightweight models and controllers. Business logic
  belongs in Services, queries belong in Repositories.
- Use events/listeners/observers with attributes where possible.
