# Filament Forms & Tables Reference

## Table of Contents

- [Field Types](#field-types)
- [Validation Shorthands](#validation-shorthands)
- [Closure Injection](#closure-injection)
- [Layout Components](#layout-components)
- [File Uploads](#file-uploads)
- [Column Types](#column-types)
- [Filter Types](#filter-types)
- [Table Features](#table-features)

## Field Types

| Field          | Class            | Key Options                                                                    |
| -------------- | ---------------- | ------------------------------------------------------------------------------ |
| Text           | `TextInput`      | `email()`, `numeric()`, `password()`, `prefix()`, `suffix()`, `mask()`         |
| Textarea       | `Textarea`       | `rows()`, `cols()`, `autosize()`                                               |
| Select         | `Select`         | `options()`, `relationship()`, `searchable()`, `multiple()`, `preload()`       |
| Toggle         | `Toggle`         | `onIcon()`, `offIcon()`, `onColor()`, `offColor()`, `inline()`                 |
| Checkbox       | `Checkbox`       | `inline()`                                                                     |
| CheckboxList   | `CheckboxList`   | `options()`, `relationship()`, `searchable()`, `columns()`, `bulkToggleable()` |
| Radio          | `Radio`          | `options()`, `inline()`, `descriptions()`                                      |
| DatePicker     | `DatePicker`     | `displayFormat()`, `format()`, `minDate()`, `maxDate()`                        |
| DateTimePicker | `DateTimePicker` | All DatePicker options + `hoursStep()`, `minutesStep()`                        |
| TimePicker     | `TimePicker`     | `hoursStep()`, `minutesStep()`, `secondsStep()`                                |
| FileUpload     | `FileUpload`     | `disk()`, `directory()`, `image()`, `multiple()`, `maxSize()`                  |
| RichEditor     | `RichEditor`     | `toolbarButtons()`, `disableToolbarButtons()`, `fileAttachmentsDisk()`         |
| MarkdownEditor | `MarkdownEditor` | `toolbarButtons()`, `fileAttachmentsDisk()`                                    |
| ColorPicker    | `ColorPicker`    | `rgba()`, `hsl()`, `hsv()`                                                     |
| TagsInput      | `TagsInput`      | `separator()`, `suggestions()`, `splitKeys()`                                  |
| KeyValue       | `KeyValue`       | `keyLabel()`, `valueLabel()`, `reorderable()`, `editableKeys()`                |
| Repeater       | `Repeater`       | `schema()`, `minItems()`, `maxItems()`, `reorderable()`, `collapsed()`         |
| Builder        | `Builder`        | `blocks()`, `minItems()`, `maxItems()`, `collapsible()`                        |
| Hidden         | `Hidden`         | --                                                                             |
| ViewField      | `ViewField`      | `view()`, `viewData()`                                                         |

## Validation Shorthands

```php
TextInput::make('email')->email()->unique(ignoreRecord: true)->required(),
TextInput::make('price')->numeric()->minValue(0)->maxValue(99999.99)->step(0.01),
TextInput::make('username')->alpha()->minLength(3)->maxLength(20)
    ->rules(['regex:/^[a-z0-9_]+$/'])
    ->validationMessages(['regex' => 'Only lowercase letters, numbers, underscores.']),
```

> `ignoreRecord: true` on `unique()` excludes the current record during edits.

## Closure Injection

| Parameter    | Type                  | Description                     |
| ------------ | --------------------- | ------------------------------- |
| `Get $get`   | `\Filament\Forms\Get` | Read another field's value      |
| `Set $set`   | `\Filament\Forms\Set` | Write to another field          |
| `$record`    | `?Model`              | Current record (null on create) |
| `$livewire`  | `LivewireComponent`   | Parent Livewire component       |
| `$state`     | `mixed`               | Current field value             |
| `$operation` | `string`              | `'create'` or `'edit'`          |

### Reactive Pattern

```php
Select::make('category_id')->options(Category::pluck('name', 'id'))->live()
    ->afterStateUpdated(fn (Set $set) => $set('subcategory_id', null)),

Select::make('subcategory_id')
    ->options(fn (Get $get) => $get('category_id')
        ? Subcategory::where('category_id', $get('category_id'))->pluck('name', 'id')->toArray()
        : [])
    ->searchable()->preload(),
```

## Layout Components

| Component  | Usage                                                                   |
| ---------- | ----------------------------------------------------------------------- |
| `Section`  | `Section::make('Title')->description('...')->collapsible()->schema([])` |
| `Grid`     | `Grid::make(3)->schema([...])` — fields use `->columnSpan()`            |
| `Fieldset` | `Fieldset::make('Address')->columns(2)->schema([...])`                  |
| `Tabs`     | `Tabs::make('Label')->tabs([Tab::make('Name')->schema([...])])`         |
| `Wizard`   | `Wizard::make([Step::make('Name')->schema([...])])->submitAction(...)`  |

Default columns inside Section: 2. Override with `->columns(1)` or `->columns(['md' => 2, 'lg' => 3])`.

## File Uploads

```php
FileUpload::make('thumbnail')
    ->image()->disk('s3')->directory('thumbnails')
    ->visibility('public')->maxSize(2048)  // KB
    ->imageResizeMode('cover')
    ->imageCropAspectRatio('16:9')
    ->imageResizeTargetWidth('1920')
    ->storeFileNamesIn('thumbnail_filename'),

FileUpload::make('attachments')
    ->multiple()->disk('s3')->directory('attachments')
    ->acceptedFileTypes(['application/pdf', 'image/*'])
    ->maxFiles(10)->maxSize(10240)
    ->reorderable()->appendFiles(),
```

## Column Types

| Column    | Class             | Key Options                                                                                 |
| --------- | ----------------- | ------------------------------------------------------------------------------------------- |
| Text      | `TextColumn`      | `limit()`, `wrap()`, `copyable()`, `money()`, `dateTime()`, `since()`, `badge()`, `color()` |
| Icon      | `IconColumn`      | `boolean()`, `trueIcon()`, `falseIcon()`, `trueColor()`, `falseColor()`                     |
| Image     | `ImageColumn`     | `circular()`, `size()`, `stacked()`, `limit()`                                              |
| Color     | `ColorColumn`     | `copyable()`                                                                                |
| Toggle    | `ToggleColumn`    | `onIcon()`, `offIcon()`                                                                     |
| Select    | `SelectColumn`    | `options()`                                                                                 |
| TextInput | `TextInputColumn` | `type()`, `rules()`                                                                         |
| Checkbox  | `CheckboxColumn`  | --                                                                                          |
| View      | `ViewColumn`      | `view()`, `viewData()`                                                                      |

### Column Patterns

```php
TextColumn::make('price')->money('usd')->sortable(),
TextColumn::make('body')->limit(50)->tooltip(fn ($col) => strlen($col->getState()) > 50 ? $col->getState() : null),
TextColumn::make('tags')->badge()->separator(','),
TextColumn::make('published_at')->dateTime('M j, Y')->since()->sortable(),
TextColumn::make('author.name')->searchable(query: fn (Builder $q, string $s) =>
    $q->whereHas('author', fn ($q) => $q->where('name', 'like', "%{$s}%"))),

IconColumn::make('is_featured')->boolean()->trueIcon('heroicon-o-star')->trueColor('warning'),
ImageColumn::make('avatar')->circular()->defaultImageUrl(url('/images/placeholder.png')),
```

## Filter Types

| Filter  | Class           | Key Options                                              |
| ------- | --------------- | -------------------------------------------------------- |
| Select  | `SelectFilter`  | `options()`, `relationship()`, `multiple()`, `preload()` |
| Ternary | `TernaryFilter` | `nullable()`, `trueLabel()`, `falseLabel()`, `queries()` |
| Trashed | `TrashedFilter` | For soft-deleted models                                  |
| Custom  | `Filter`        | `form()`, `query()`, `indicateUsing()`                   |

### Custom Date Range Filter

```php
Filter::make('created_at')
    ->form([DatePicker::make('from'), DatePicker::make('until')])
    ->query(fn (Builder $query, array $data) => $query
        ->when($data['from'], fn ($q, $d) => $q->whereDate('created_at', '>=', $d))
        ->when($data['until'], fn ($q, $d) => $q->whereDate('created_at', '<=', $d)))
    ->indicateUsing(function (array $data): array {
        $indicators = [];
        if ($data['from']) $indicators['from'] = 'From ' . Carbon::parse($data['from'])->toFormattedDateString();
        if ($data['until']) $indicators['until'] = 'Until ' . Carbon::parse($data['until'])->toFormattedDateString();
        return $indicators;
    }),
```

## Table Features

### Sorting

```php
TextColumn::make('name')->sortable(),
TextColumn::make('full_name')->sortable(query: fn (Builder $q, string $dir) =>
    $q->orderBy('last_name', $dir)->orderBy('first_name', $dir)),
$table->defaultSort('created_at', 'desc'),
```

### Grouping

```php
$table->groups([
    Group::make('status')->label('Status')->collapsible(),
    Group::make('category.name')->label('Category'),
])->defaultGroup('status'),
```

### Pagination

```php
$table->paginated([10, 25, 50, 100])->defaultPaginationPageOption(25),
$table->paginated(false), // disable
```

### Soft Deletes

```php
$table->filters([TrashedFilter::make()])
    ->actions([RestoreAction::make(), ForceDeleteAction::make()])
    ->bulkActions([RestoreBulkAction::make(), ForceDeleteBulkAction::make()]),
```

### Empty State

```php
$table->emptyStateIcon('heroicon-o-bookmark')
    ->emptyStateHeading('No posts yet')
    ->emptyStateDescription('Create your first post.')
    ->emptyStateActions([Action::make('create')->label('Create post')->url($createUrl)->button()]),
```

### Deferred Loading

```php
$table->deferLoading(), // loads table after page renders
```
