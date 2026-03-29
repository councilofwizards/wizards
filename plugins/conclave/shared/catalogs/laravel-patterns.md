# Laravel & DDD Pattern Catalog

Reference catalog for the craft-laravel skill. The Architect selects from these
named patterns when making architectural decisions via the Decision Matrix
methodology.

## Structural Patterns

### Action Class

- **Location**: `app/Actions/`
- **What**: Single-purpose invokable class for one business operation
- **Use when**: A controller method has non-trivial business logic
- **Don't use**: For simple CRUD that fits in a thin controller

### Service Class

- **Location**: `app/Services/`
- **What**: Stateless class encapsulating business logic across multiple
  operations
- **Use when**: Multiple controllers or jobs share business logic
- **Don't use**: For single-use logic (use Action instead)

### Repository Pattern

- **Location**: `app/Repositories/`
- **What**: Abstraction over Eloquent for complex query logic
- **Use when**: Queries are complex, reused across services, or need to be
  mockable for unit testing
- **Don't use**: For simple Eloquent calls that scopes handle well

### Query Object

- **What**: Dedicated class for a single complex query
- **Use when**: A query is too complex for a scope but doesn't warrant a full
  repository
- **Don't use**: When Eloquent scopes suffice

### Data Transfer Object (DTO)

- **What**: Typed immutable object for passing data between layers
- **Use when**: Data crosses bounded context boundaries or needs validation at
  the boundary
- **Don't use**: Within a single bounded context where arrays suffice

### Value Object

- **What**: Immutable object representing a domain concept (Money, Email,
  Address)
- **Use when**: A primitive carries domain meaning and has validation rules or
  formatting
- **Don't use**: For simple string/int fields with no domain behavior

## DDD Patterns

### Aggregate Root

- **What**: Eloquent model that owns a cluster of related objects and enforces
  invariants
- **Use when**: A group of models must be modified together to maintain
  consistency
- **Don't use**: For independent models with no shared invariants

### Domain Event

- **Location**: `app/Events/`
- **What**: Event fired when something significant happens in the domain
- **Use when**: Other bounded contexts or subsystems need to react to a domain
  change
- **Don't use**: For internal implementation side effects within the same
  aggregate

### Domain Service

- **What**: Service containing domain logic that doesn't belong to any single
  entity
- **Use when**: An operation spans multiple aggregates
- **Don't use**: For logic that belongs on the aggregate root itself

### Specification Pattern

- **What**: Encapsulated business rule that can be combined (and/or/not)
- **Use when**: Complex filtering or validation rules need to be reusable and
  composable
- **Don't use**: For simple where clauses

### Bounded Context

- **What**: Explicit boundary around a subdomain with its own models and
  language
- **Use when**: The same concept (e.g., "User") means different things in
  different parts of the system
- **Don't use**: For small apps with a single domain

## Laravel Framework Patterns

### Form Request

- **What**: Dedicated request class for validation + authorization
- **Use**: ALWAYS for validation. Never inline in controllers.

### API Resource / Resource Collection

- **What**: Transform models to JSON responses
- **Use**: ALWAYS for API responses. Never return raw models or manual arrays.

### Policy

- **What**: Authorization logic per model
- **Use**: ALWAYS for authorization. Register via AuthServiceProvider.

### Observer

- **What**: React to Eloquent model events (creating, updated, deleted)
- **Use when**: Side effects are tightly coupled to a model's lifecycle
- **Don't use**: For cross-cutting concerns (use Events/Listeners instead)

### Event / Listener

- **What**: Decouple side effects from primary logic
- **Use when**: The primary operation should not know about secondary effects
  (notifications, logging, cache invalidation)
- **Don't use**: For effects that must complete before the response (use
  synchronous service calls)

### Job / Queue

- **What**: Async processing
- **Use when**: The operation is slow, can tolerate delay, or must be retried on
  failure
- **Don't use**: For operations that must complete within the HTTP request
  lifecycle

### Middleware

- **What**: Cross-cutting request/response logic
- **Use when**: Logic applies to a group of routes (auth, rate limiting,
  headers, tenant scoping)
- **Don't use**: For per-route business logic

### Eloquent Scope

- **What**: Reusable query constraint on a model
- **Use when**: The same where clause appears in multiple places
- **Don't use**: For complex multi-join queries (use Query Object or Repository)

### Pipeline

- **What**: Process an object through a series of stages (Illuminate\Pipeline)
- **Use when**: A request/object needs sequential transformations (validation
  chains, workflow stages)
- **Don't use**: For simple linear logic
