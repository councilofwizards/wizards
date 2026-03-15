# Livewire Reference

## Table of Contents

- [Component Lifecycle](#component-lifecycle)
- [Wire Directives](#wire-directives)
- [Properties and Attributes](#properties-and-attributes)
- [Form Objects](#form-objects)
- [Computed Properties](#computed-properties)
- [Component API](#component-api)
- [Alpine.js Integration](#alpinejs-integration)
- [Volt API](#volt-api)
- [Performance Checklist](#performance-checklist)
- [Security](#security)

---

## Component Lifecycle

### Initial Render

`boot()` → `mount($params)` → `render()`

### Subsequent Updates

`boot()` → `hydrate()` → `hydrate{Prop}()` → `updating($name, $val)` → `updating{Prop}($val)` → `updated($name, $val)` →
`updated{Prop}($val)` → `rendering()` → `render()` → `rendered($view)` → `dehydrate()` → `dehydrate{Prop}()`

| Hook                   | When                  | Use Case                         |
|------------------------|-----------------------|----------------------------------|
| `boot()`               | Every request         | Initialize non-serializable deps |
| `mount(...$params)`    | Initial only          | Set state from route/parent      |
| `hydrate()`            | After deserialization | Restore non-serializable state   |
| `updating{Prop}($val)` | Before property set   | Intercept/modify incoming data   |
| `updated{Prop}($val)`  | After property set    | Side effects on change           |
| `dehydrate()`          | Before serialization  | Prepare state for browser        |

## Wire Directives

### Data Binding

| Directive                        | Behavior                     |
|----------------------------------|------------------------------|
| `wire:model="prop"`              | Sync on form submit (lazy)   |
| `wire:model.live="prop"`         | Sync on every input event    |
| `wire:model.live.debounce.300ms` | Live with debounce           |
| `wire:model.blur="prop"`         | Sync on focus loss           |
| `wire:model.number="prop"`       | Cast to number               |
| `wire:model="form.field"`        | Bind to Form Object property |

### Actions

| Directive                     | Behavior                      |
|-------------------------------|-------------------------------|
| `wire:click="method"`         | Call on click                 |
| `wire:click="method('arg')"`  | Call with argument            |
| `wire:submit="method"`        | Call on form submit           |
| `wire:change="method"`        | Call on change                |
| `wire:keydown.enter="method"` | Call on Enter key             |
| `wire:confirm="msg"`          | Browser confirm before action |

### UI State

| Directive                         | Behavior                             |
|-----------------------------------|--------------------------------------|
| `wire:loading`                    | Show element while request in flight |
| `wire:loading.class="opacity-50"` | Add class while loading              |
| `wire:loading.attr="disabled"`    | Set attribute while loading          |
| `wire:target="method"`            | Scope loading to specific action     |
| `wire:offline`                    | Show when browser is offline         |
| `wire:dirty`                      | Show when form has unsaved changes   |

### Other

| Directive                       | Behavior                         |
|---------------------------------|----------------------------------|
| `wire:poll`                     | Re-render every 2s               |
| `wire:poll.5s`                  | Re-render every 5s               |
| `wire:poll.visible`             | Poll only when visible           |
| `wire:poll.keep-alive="method"` | Call action instead of re-render |
| `wire:init="method"`            | Call after first DOM insertion   |
| `wire:navigate`                 | SPA-style navigation             |
| `wire:navigate.hover`           | Prefetch on hover                |
| `wire:ignore`                   | Exclude subtree from morphing    |
| `wire:ignore.self`              | Exclude element only             |
| `wire:key="unique"`             | Stable identity for morphing     |
| `wire:stream`                   | Receive streamed content         |

## Properties and Attributes

```php
use Livewire\Attributes\Validate;
use Livewire\Attributes\Locked;
use Livewire\Attributes\Computed;
use Livewire\Attributes\On;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Lazy;
use Livewire\Attributes\Persist;

#[Validate('required|string|max:255')]
public string $title = '';

#[Locked]           // browser cannot modify
public int $userId;

#[Computed]          // memoized per request
public function posts() { return Post::paginate(15); }

#[On('event-name')] // listen for Livewire event
public function refresh() { /* ... */ }

#[Layout('layouts.app')]  // full-page component layout
#[Lazy]                    // defer initial render
#[Persist]                 // survive wire:navigate
```

## Form Objects

```php
use Livewire\Form;
use Livewire\Attributes\Validate;

class PostForm extends Form
{
    #[Validate('required|string|min:3')]
    public string $title = '';

    #[Validate('required|string|min:10')]
    public string $body = '';

    public function fill(Post $post): void
    {
        $this->title = $post->title;
        $this->body = $post->body;
    }
}
```

Usage: `public PostForm $form;` — bind with `wire:model="form.title"`.

## Computed Properties

```php
#[Computed]
public function posts(): LengthAwarePaginator
{
    return Post::paginate(15);
}

// With persistent cache
#[Computed(cache: true, key: 'stats')]
public function stats(): array { /* ... */ }
```

Access in Blade: `$this->posts` (not `$posts`). Not serialized into snapshot.

## Component API

| Method                                 | Description                           |
|----------------------------------------|---------------------------------------|
| `$this->validate()`                    | Validate all `#[Validate]` properties |
| `$this->validateOnly('prop')`          | Validate single property              |
| `$this->reset('prop')`                 | Reset to default                      |
| `$this->reset()`                       | Reset all public properties           |
| `$this->fill([...])`                   | Mass-assign properties                |
| `$this->dispatch('event', data)`       | Dispatch Livewire event               |
| `$this->dispatch('event')->to('name')` | To specific component                 |
| `$this->dispatch('event')->up()`       | To parent                             |
| `$this->redirect('/url')`              | Redirect browser                      |
| `$this->redirectRoute('name')`         | Redirect to named route               |
| `$this->js('code')`                    | Execute JS after response             |
| `$this->skipRender()`                  | Skip re-render                        |
| `$this->authorize('ability', $model)`  | Authorization check                   |
| `$this->resetPage()`                   | Reset pagination                      |
| `$this->resetErrorBag()`               | Clear validation errors               |
| `$this->addError('field', 'msg')`      | Add manual error                      |

## Alpine.js Integration

### $wire Proxy

| API                              | Description                   |
|----------------------------------|-------------------------------|
| `$wire.prop`                     | Read Livewire property        |
| `$wire.prop = val`               | Write (queued sync)           |
| `$wire.$set('prop', val)`        | Write + immediate roundtrip   |
| `$wire.method()`                 | Call action (returns Promise) |
| `$wire.$call('method', ...args)` | Call by string name           |
| `$wire.$refresh()`               | Force re-render               |
| `$wire.$commit()`                | Flush queued updates          |
| `$wire.$watch('prop', fn)`       | Watch for changes             |
| `$wire.$entangle('prop')`        | Entangle Alpine variable      |
| `$wire.$dispatch('event', data)` | Dispatch browser event        |
| `$wire.$on('event', fn)`         | Listen for event              |

### @entangle

```blade
{{-- Lazy (default): sync on next Livewire request --}}
<div x-data="{ open: $wire.entangle('showModal') }">

{{-- Live: immediate roundtrip on change --}}
<div x-data="{ tab: $wire.entangle('activeTab').live }">
```

### Alpine Plugins (Included)

| Plugin    | Directive     | Purpose                      |
|-----------|---------------|------------------------------|
| Focus     | `x-trap`      | Trap keyboard focus (modals) |
| Intersect | `x-intersect` | Viewport enter/leave         |
| Persist   | `x-persist`   | localStorage persistence     |
| Collapse  | `x-collapse`  | Animate height               |
| Anchor    | `x-anchor`    | Position relative to element |

## Volt API

| Function               | Purpose                  |
|------------------------|--------------------------|
| `state([...])`         | Declare properties       |
| `state(...)->locked()` | Prevent browser mutation |
| `computed(fn)`         | Computed property        |
| `action(fn)`           | Callable action          |
| `mount(fn)`            | Mount hook               |
| `on(['event' => fn])`  | Event listeners          |
| `rules([...])`         | Validation rules         |
| `layout('name')`       | Full-page layout         |
| `uses([Trait::class])` | Mix in traits            |

## Performance Checklist

- [ ] Store IDs in properties, query in `#[Computed]`
- [ ] Use `wire:model` (lazy) for forms, not `wire:model.live`
- [ ] Add `.debounce.300ms` to live search inputs
- [ ] Paginate with `WithPagination` — never load all records
- [ ] Add `wire:key` on loop items
- [ ] Eager load relationships (`->with(['author'])`)
- [ ] Enable `preventLazyLoading()` in development
- [ ] Use `#[Lazy]` for expensive dashboard widgets
- [ ] Keep UI-only state in Alpine, not Livewire
- [ ] Split large components into smaller children
- [ ] Use `wire:ignore` for third-party JS library DOM
- [ ] Prefer `wire:navigate` for multi-page apps

## Security

- Snapshots are HMAC-signed; tampering throws `CorruptComponentPayloadException`
- Public properties are visible in snapshots — never store passwords/tokens
- `#[Locked]` prevents browser modification of a property
- Action arguments can be tampered — validate and authorize inside every action
- Livewire performs implicit model binding on action params — authorization still required
