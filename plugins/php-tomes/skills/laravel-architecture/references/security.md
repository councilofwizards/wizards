# Laravel Security Reference

## Table of Contents

- [Authentication Overview](#authentication-overview)
- [Sanctum](#sanctum)
- [Passport (OAuth2)](#passport-oauth2)
- [Custom Guards](#custom-guards)
- [Authorization: Gates](#authorization-gates)
- [Authorization: Policies](#authorization-policies)
- [Security Hardening](#security-hardening)
- [Anti-Patterns](#anti-patterns)

---

## Authentication Overview

| Package       | Purpose                             | When to Use                    |
|---------------|-------------------------------------|--------------------------------|
| **Sanctum**   | Cookie sessions + opaque API tokens | SPAs, mobile apps, simple APIs |
| **Passport**  | Full OAuth2 server                  | Third-party token issuance     |
| **Fortify**   | Headless auth backend (no UI)       | Custom frontend                |
| **Breeze**    | Starter kit with UI                 | New projects, simple auth      |
| **Jetstream** | Full starter (teams, 2FA, API)      | Teams/advanced features        |

### Session vs Token Auth

| Dimension    | Session (Cookie)               | Token (Bearer)       |
|--------------|--------------------------------|----------------------|
| CSRF         | Yes (mitigated by Sanctum)     | No                   |
| XSS          | HttpOnly cookie (safe)         | localStorage exposed |
| Revocation   | Immediate (delete session)     | Requires DB lookup   |
| Cross-domain | Requires SameSite=None + HTTPS | Works natively       |
| Best for     | SPAs on same domain            | Mobile, third-party  |

---

## Sanctum

### SPA Cookie Authentication

```php
// config/sanctum.php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost,localhost:3000')),

// bootstrap/app.php
->withMiddleware(fn (Middleware $mw) => $mw->statefulApi())
```

SPA flow:

1. `GET /sanctum/csrf-cookie` — sets XSRF-TOKEN cookie
2. `POST /login` — axios sends X-XSRF-TOKEN header automatically
3. Subsequent requests use session cookie + XSRF-TOKEN

SPA cookie auth requires same top-level domain. For cross-domain, use tokens.

### API Tokens

```php
// Issue token
$token = $user->createToken('mobile-app', ['read:posts', 'write:posts'], now()->addYear());
return response()->json(['token' => $token->plainTextToken]);

// Protect routes
Route::middleware('auth:sanctum')->group(fn () => ...);

// Check abilities
if (!$request->user()->tokenCan('write:posts')) { abort(403); }

// Revoke
$request->user()->currentAccessToken()->delete();  // current
$request->user()->tokens()->delete();              // all
```

Never log or expose `plainTextToken` after initial creation.

---

## Passport (OAuth2)

Use when issuing tokens to third-party applications.

| Grant                     | Use Case                            |
|---------------------------|-------------------------------------|
| Authorization Code        | Third-party web apps                |
| Authorization Code + PKCE | Mobile/SPA (replaces Implicit)      |
| Client Credentials        | Machine-to-machine                  |
| Password Grant            | **Deprecated in OAuth 2.1 — avoid** |

```php
// Protecting routes
Route::middleware('auth:api')->group(fn () => ...);
Route::middleware(['auth:api', 'scope:read-posts'])->group(fn () => ...);
```

---

## Custom Guards

```php
final class ApiKeyGuard implements Guard
{
    public function user(): ?Authenticatable
    {
        $token = $this->request->header('X-API-Key');
        return $token ? $this->provider->retrieveByCredentials(
            ['api_key' => hash('sha256', $token)]
        ) : null;
    }
}

// Register in AppServiceProvider::boot()
Auth::extend('api-key', fn ($app, $name, $config) =>
    new ApiKeyGuard(Auth::createUserProvider($config['provider']), $app->make(Request::class))
);

// config/auth.php
'guards' => ['api-key' => ['driver' => 'api-key', 'provider' => 'users']];
```

---

## Authorization: Gates

```php
// Define in AppServiceProvider::boot()
Gate::define('publish-post', fn (User $user) => in_array($user->role, ['editor', 'admin']));
Gate::define('delete-post', fn (User $user, Post $post) => $user->id === $post->author_id);

// Check
Gate::allows('publish-post');
Gate::denies('delete-post', $post);
Gate::authorize('delete-post', $post);  // throws 403
Gate::forUser($user)->allows('publish-post');
```

### Before/After Hooks

```php
// Super-admin bypass — runs BEFORE any gate
Gate::before(fn (User $user) => $user->isSuperAdmin() ? true : null);

// Audit — runs AFTER every gate
Gate::after(fn (User $user, string $ability, bool $result) =>
    AuditLog::record($user, $ability, $result)
);
```

`Gate::before()` returning `true` bypasses ALL checks. Use narrowly.

---

## Authorization: Policies

Auto-discovered at `App\Policies\{Model}Policy`. One policy per model.

```php
final class PostPolicy
{
    public function before(User $user): ?bool
    {
        return $user->isAdmin() ? true : null;
    }

    public function view(?User $user, Post $post): bool
    {
        return $post->published || $user?->id === $post->author_id;
    }

    public function update(User $user, Post $post): bool
    {
        return $user->id === $post->author_id;
    }

    public function delete(User $user, Post $post): Response
    {
        return $user->id === $post->author_id
            ? Response::allow()
            : Response::deny('You do not own this post.', 403);
    }
}
```

### Using Policies

```php
// In controller
$this->authorize('update', $post);
$this->authorize('create', Post::class);

// Auto-map all resource methods
$this->authorizeResource(Post::class, 'post');
// Maps: index→viewAny, show→view, create/store→create, edit/update→update, destroy→delete

// Inspect without throwing
$response = Gate::inspect('update', $post);
if ($response->denied()) { return response()->json(['error' => $response->message()], 403); }

// Manual registration (non-standard location)
Gate::policy(Post::class, PostPolicy::class);
```

### Blade Directives

```blade
@can('update', $post)
    <button>Edit</button>
@endcan

@can('create', App\Models\Post::class)
    <a href="{{ route('posts.create') }}">New Post</a>
@endcan
```

`@can` hides UI only. Always enforce in controller.

---

## Security Hardening

### Mass Assignment

```php
// SAFE
protected $fillable = ['name', 'email', 'password'];
User::create($request->validated());

// VULNERABLE
protected $guarded = [];
User::create($request->all());
```

### SQL Injection via Raw Queries

```php
// VULNERABLE — string interpolation
DB::table('users')->whereRaw("name = '$name'")->get();

// SAFE — parameterized bindings
DB::table('users')->whereRaw('name = ?', [$name])->get();

// Column names — whitelist (cannot bind identifiers)
$allowed = ['name', 'email', 'created_at'];
$column = in_array($request->input('sort'), $allowed, true) ? $request->input('sort') : 'name';
```

### XSS Prevention

```blade
{{-- SAFE — escaped --}}
{{ $post->title }}

{{-- VULNERABLE — raw HTML with user content --}}
{!! $user->bio !!}

{{-- Acceptable — developer-controlled, sanitized HTML --}}
{!! $sanitizedHtml !!}
```

Sanitize user HTML with HTMLPurifier before storage.

### CSRF in SPAs

```php
// Laravel 11 — stateful API routes get CSRF via statefulApi()
->withMiddleware(fn (Middleware $mw) => $mw->statefulApi())

// NEVER exclude entire api group from CSRF
```

### APP_DEBUG

```php
// SAFE — defaults to false
'debug' => (bool) env('APP_DEBUG', false),
```

### Rate Limiting

```php
RateLimiter::for('login', fn (Request $r) =>
    Limit::perMinute(5)->by($r->input('email') . '|' . $r->ip())
);

Route::post('/login', LoginController::class)->middleware('throttle:login');

// Manual rate limiting
if (RateLimiter::tooManyAttempts($key, 10)) {
    return response()->json(['retry_after' => RateLimiter::availableIn($key)], 429);
}
RateLimiter::hit($key, decay: 60);
```

### Signed URLs

```php
$url = URL::temporarySignedRoute('download', now()->addMinutes(30), ['file' => $id]);

Route::get('/download/{file}', Controller::class)->middleware('signed');

// Manual validation
if (!$request->hasValidSignature()) { abort(403); }
```

### Encryption

```php
$encrypted = Crypt::encryptString($value);
$decrypted = Crypt::decryptString($encrypted);

// Transparent model encryption
protected $casts = [
    'mfa_secret' => 'encrypted',
    'api_credentials' => 'encrypted:array',
];
```

---

## Anti-Patterns

| Anti-Pattern                          | Risk                          | Fix                               |
|---------------------------------------|-------------------------------|-----------------------------------|
| `$guarded = []`                       | Mass assignment               | Use `$fillable`                   |
| `$request->all()` in create/update    | Accepts unexpected fields     | `$request->validated()`           |
| `DB::raw($userInput)`                 | SQL injection                 | Use bindings or whitelist         |
| `{!! $user->content !!}`              | XSS                           | Escape with `{{ }}` or sanitize   |
| `env('APP_DEBUG', true)`              | Info disclosure               | Default to `false`                |
| Passport for single-SPA               | Unnecessary complexity        | Use Sanctum                       |
| Password Grant (Passport)             | Deprecated OAuth 2.1          | Auth Code + PKCE                  |
| Long-lived tokens, no scopes          | Over-privileged on compromise | Scope + expire tokens             |
| `@can` without controller auth        | UI-only protection            | Enforce in controller             |
| `Gate::before` returning true broadly | Bypasses all authorization    | Keep narrow (super-admin only)    |
| Signed URLs as auth tokens            | Shareable, not tracked        | Use proper auth                   |
| Skipping CSRF init in SPA             | 419 errors or bypass          | Call `/sanctum/csrf-cookie` first |
