# Blade Templates Reference

## Table of Contents

- [Component Types](#component-types)
- [Props and Attributes](#props-and-attributes)
- [Slots](#slots)
- [Layouts](#layouts)
- [Asset Injection](#asset-injection)
- [Dynamic Components](#dynamic-components)
- [Security Directives](#security-directives)
- [Conditional Directives](#conditional-directives)
- [Anti-Patterns](#anti-patterns)

---

## Component Types

### Anonymous Components

Location: `resources/views/components/`. No PHP class needed.

```blade
{{-- resources/views/components/alert.blade.php --}}
@props(['type' => 'info', 'dismissible' => false])
<div {{ $attributes->merge(['class' => 'alert alert-' . $type]) }}>
    {{ $slot }}
</div>
```

Subdirectory naming: `components/form/input.blade.php` → `<x-form.input />`.

### Class-Based Components

Location: `app/View/Components/`. Use when PHP logic needed.

```php
class UserAvatar extends Component
{
    public function __construct(
        public readonly User $user,
        public readonly string $size = 'md',
    ) {}

    public function render(): View
    {
        return view('components.user-avatar');
    }
}
```

Public properties and methods on the class are auto-available in the template.

### Inline Components

```php
public function render(): string
{
    return <<<'blade'
    <span {{ $attributes->merge(['class' => 'badge']) }}>{{ $slot }}</span>
    blade;
}
```

## Props and Attributes

### @props Directive

```blade
@props([
    'variant' => 'primary',   {{-- with default --}}
    'disabled' => false,
    'label',                   {{-- required (no default) --}}
])
```

Declared props are extracted from `$attributes`. Undeclared values remain in
`$attributes`.

### $attributes Methods

```blade
{{-- Merge with defaults (additive for class, override for others) --}}
{{ $attributes->merge(['class' => 'btn btn-primary', 'type' => 'button']) }}

{{-- Conditional classes --}}
{{ $attributes->class(['card', 'elevated' => $elevated]) }}

{{-- Filter/reject specific attributes --}}
{{ $attributes->only(['id', 'class']) }}
{{ $attributes->except(['class']) }}

{{-- Check existence --}}
{{ $attributes->has('disabled') }}
{{ $attributes->get('id', 'default') }}

{{-- Pipe through prepend/append --}}
{{ $attributes->prepend('class', 'base-class ') }}
```

## Slots

### Default Slot

Content between tags: `{{ $slot }}`.

### Named Slots

```blade
{{-- Definition --}}
@if ($header->isNotEmpty())
    <div class="header">{{ $header }}</div>
@endif
<div class="body">{{ $slot }}</div>

{{-- Usage --}}
<x-card>
    <x-slot:header><h5>Title</h5></x-slot:header>
    Body content here.
</x-card>
```

Named slots expose `->isNotEmpty()` and `->attributes`.

## Layouts

### Component-Based (Recommended)

```blade
{{-- resources/views/components/layouts/app.blade.php --}}
<!DOCTYPE html>
<html>
<head>
    <title>{{ $title ?? config('app.name') }}</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <main>{{ $slot }}</main>
    @stack('scripts')
</body>
</html>
```

```blade
<x-layouts.app>
    <x-slot:title>Dashboard</x-slot:title>
    <h1>Welcome</h1>
</x-layouts.app>
```

### Template Inheritance

```blade
{{-- Layout --}}
<title>@yield('title', config('app.name'))</title>
@yield('content')

{{-- Page --}}
@extends('layouts.app')
@section('title', 'Users')
@section('content') ... @endsection
```

## Asset Injection

```blade
{{-- Push from component --}}
@push('scripts')
    <script src="{{ asset('js/chart.js') }}"></script>
@endpush

{{-- Render in layout --}}
@stack('scripts')

{{-- Prevent duplicates when component used multiple times --}}
@once
    @push('scripts')
        <script src="{{ asset('js/lib.js') }}"></script>
    @endpush
@endonce

{{-- Prepend to stack --}}
@prepend('scripts')
    <script>window.config = {};</script>
@endprepend
```

## Dynamic Components

```blade
<x-dynamic-component :component="$componentName" :data="$data" />
```

> **Security:** Never pass unsanitized user input as the component name.
> Whitelist allowed values.

## Security Directives

### Output Escaping

| Syntax         | Behavior                                | Use For                     |
| -------------- | --------------------------------------- | --------------------------- |
| `{{ $var }}`   | `htmlspecialchars()` with `ENT_QUOTES`  | All untrusted data          |
| `{!! $var !!}` | Raw, unescaped                          | Only sanitized HTML         |
| `@js($var)`    | `json_encode()` with `JSON_HEX_*` flags | Embedding PHP in `<script>` |

### @js Directive

```blade
<script>
    const config = @js(['userId' => $user->id, 'token' => csrf_token()]);
    const name = @js($user->name);
</script>
```

### CSP Nonce

```blade
<script nonce="{{ app('csp-nonce') }}">...</script>
<script @nonce>...</script>  {{-- Laravel 10.46+ with Vite --}}
```

### URL Validation

`{{ }}` does NOT prevent `javascript:` URIs. Validate scheme:

```php
abort_unless(in_array(parse_url($url, PHP_URL_SCHEME), ['http', 'https']), 422);
```

## Conditional Directives

```blade
@class(['alert', 'alert-danger' => $error, 'alert-info' => $info])

@style(['color: red' => $error, 'font-weight: bold' => $bold])

@disabled($isDisabled)
@readonly($isReadonly)
@required($isRequired)
@checked($isChecked)
@selected($isSelected)
```

## Anti-Patterns

| Anti-Pattern                                      | Fix                                        |
| ------------------------------------------------- | ------------------------------------------ |
| Querying DB in templates                          | Prepare data in controller/view model      |
| Deeply nested `@include` with implicit vars       | Use components with explicit props         |
| `{!! $userInput !!}` without sanitization         | HTMLPurifier at write time, then `{!! !!}` |
| `{{ $var }}` inside `<script>`                    | Use `@js($var)`                            |
| `@props` omitted (all attrs leak to HTML)         | Declare all expected props                 |
| `<x-dynamic-component :component="request('x')">` | Whitelist allowed component names          |
| `@push` without `@once` in reusable component     | Wrap in `@once` to prevent duplicates      |
