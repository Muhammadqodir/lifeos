# Currency System Documentation

## Overview

The LifeOS Finance module supports both **SYSTEM** and **USER-OWNED** currencies. This allows users to have their own customizable currency list while maintaining a set of standard system currencies.

---

## Architecture

### System vs User Currencies

**SYSTEM Currencies:**
- Created by administrators/seeders
- Have `user_id = NULL`
- Serve as templates for user-owned currencies
- Cannot be deleted by users
- Example: USD, EUR, RUB, UZS (seeded by `CurrencySeeder`)

**USER-OWNED Currencies:**
- Automatically cloned from system currencies when a user registers
- Have `user_id` set to the owner's ID
- Users can customize (edit, activate/deactivate)
- Each user has their own independent copy
- Allows per-user currency preferences

---

## Database Schema

### `currencies` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT (nullable, FK) | `NULL` = system currency, `<id>` = user-owned currency |
| `code` | VARCHAR | 3-letter currency code (USD, EUR, etc.) |
| `name` | VARCHAR | Full currency name |
| `color` | VARCHAR | Hex color code for UI |
| `icon` | VARCHAR | Currency symbol or icon identifier |
| `is_active` | BOOLEAN | Whether currency is active (for user-owned currencies) |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

**Indexes:**
- `UNIQUE (user_id, code)` - Allows same code for different users/system
  - System USD: `(NULL, 'USD')`
  - User 1 USD: `(1, 'USD')`
  - User 2 USD: `(2, 'USD')`

**Foreign Keys:**
- `user_id` → `users.id` (ON DELETE CASCADE)

### `user_finance_settings` Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | BIGINT | Primary key |
| `user_id` | BIGINT (UNIQUE, FK) | One-to-one with users |
| `base_currency_id` | BIGINT (FK) | User's default currency for calculations |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

**Foreign Keys:**
- `user_id` → `users.id` (ON DELETE CASCADE)
- `base_currency_id` → `currencies.id` (ON DELETE RESTRICT)

---

## Models

### `Currency` Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Currency extends Model
{
    protected $fillable = [
        'user_id',
        'code',
        'name',
        'color',
        'icon',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    // Relationships
    public function user(): BelongsTo;
    public function wallets(): HasMany;
    public function transactionEntries(): HasMany;

    // Helper Methods
    public function isSystem(): bool; // Returns true if user_id is NULL
    public function scopeSystem($query); // Query only system currencies
    public function scopeUserOwned($query, ?int $userId = null); // Query user-owned currencies
}
```

### `UserFinanceSettings` Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserFinanceSettings extends Model
{
    protected $fillable = [
        'user_id',
        'base_currency_id',
    ];

    // Relationships
    public function user(): BelongsTo;
    public function baseCurrency(): BelongsTo; // Points to Currency model
}
```

### `User` Model Updates

```php
// New relationships added:
public function currencies(): HasMany; // User-owned currencies
public function financeSettings(): HasOne; // Finance settings
```

---

## User Registration Flow

### Automatic Setup on Registration

When a new user registers, the `SetupUserFinanceData` listener automatically:

1. **Checks if setup already exists** (idempotent - won't duplicate)
2. **Clones all system currencies** for the user
3. **Creates finance settings** with the first currency as base

**Event:** `Illuminate\Auth\Events\Registered`

**Listener:** `App\Listeners\SetupUserFinanceData`

**Process:**
```php
DB::transaction(function () use ($user) {
    // 1. Get all system currencies
    $systemCurrencies = Currency::system()->get();
    
    // 2. Clone each for the user
    foreach ($systemCurrencies as $systemCurrency) {
        Currency::create([
            'user_id' => $user->id,
            'code' => $systemCurrency->code,
            'name' => $systemCurrency->name,
            'color' => $systemCurrency->color,
            'icon' => $systemCurrency->icon,
            'is_active' => true,
        ]);
    }
    
    // 3. Create finance settings with first currency as base
    UserFinanceSettings::create([
        'user_id' => $user->id,
        'base_currency_id' => $userCurrencies[0]->id,
    ]);
});
```

---

## Migrations

### 1. `add_user_ownership_to_currencies_table`

**Timestamp:** `2025_12_24_202119`

**Changes:**
- Drops old `UNIQUE(code)` constraint
- Adds `user_id` (nullable FK to users)
- Adds `is_active` boolean column
- Adds `UNIQUE(user_id, code)` constraint

### 2. `create_user_finance_settings_table`

**Timestamp:** `2025_12_24_202208`

**Creates:**
- `user_finance_settings` table
- `UNIQUE(user_id)` constraint (one-to-one)
- Foreign keys to users and currencies

---

## Usage Examples

### Query System Currencies

```php
// Get all system currencies
$systemCurrencies = Currency::system()->get();

// Check if a currency is system
if ($currency->isSystem()) {
    // This is a system currency
}
```

### Query User Currencies

```php
// Get current user's currencies
$userCurrencies = Currency::userOwned(auth()->id())->get();

// Or via relationship
$userCurrencies = auth()->user()->currencies;

// Get only active user currencies
$activeCurrencies = auth()->user()->currencies()->where('is_active', true)->get();
```

### Access User Finance Settings

```php
$user = auth()->user();

// Get base currency
$baseCurrency = $user->financeSettings->baseCurrency;
echo $baseCurrency->code; // "USD"

// Update base currency
$user->financeSettings->update([
    'base_currency_id' => $newCurrencyId,
]);
```

### Seeding Test Users

When seeding users, manually trigger the finance setup:

```php
use App\Listeners\SetupUserFinanceData;
use Illuminate\Auth\Events\Registered;

$user = User::create([...]);

// Manually trigger finance setup
$listener = new SetupUserFinanceData();
$listener->handle(new Registered($user));
```

---

## Testing

### Verify User Setup

```php
$user = User::first();

// Check finance settings exist
if ($user->financeSettings) {
    echo "Finance Settings: ✓\n";
    echo "Base Currency: " . $user->financeSettings->baseCurrency->code . "\n";
}

// Check user currencies
echo "User Currencies: " . $user->currencies->pluck('code')->join(', ') . "\n";
```

### Check System vs User Currencies

```php
echo "System Currencies: " . Currency::system()->count() . "\n";
echo "User-Owned Currencies: " . Currency::whereNotNull('user_id')->count() . "\n";
echo "Total Currencies: " . Currency::count() . "\n";
```

### Idempotent Test

```php
$user = User::first();
$beforeCount = $user->currencies()->count();

// Try to run setup again
$listener = new SetupUserFinanceData();
$listener->handle(new Registered($user));

$afterCount = $user->currencies()->count();
assert($beforeCount === $afterCount); // Should be equal (no duplicates)
```

---

## API Considerations

When building API endpoints for currencies:

### Currency List Endpoint

**For authenticated users:**
```php
// Return user's currencies (not system currencies)
$currencies = auth()->user()->currencies;
```

**For unauthenticated/system admin:**
```php
// Return system currencies
$currencies = Currency::system()->get();
```

### Currency CRUD

**Create/Update/Delete:**
- Only allow operations on user-owned currencies
- Validate `user_id` matches authenticated user
- Prevent modification of system currencies

**Example:**
```php
public function update(Request $request, Currency $currency)
{
    // Ensure user owns this currency
    if ($currency->user_id !== auth()->id()) {
        abort(403, 'You can only modify your own currencies');
    }
    
    // Don't allow changing code (breaks unique constraint)
    $currency->update($request->only(['name', 'color', 'icon', 'is_active']));
    
    return new CurrencyResource($currency);
}
```

---

## Best Practices

1. **Never delete system currencies** - They're templates for new users
2. **Always use transactions** when cloning currencies + creating settings
3. **Validate user ownership** before allowing currency modifications
4. **Check idempotency** - Don't duplicate setup if it exists
5. **Restrict base_currency_id** - Can only be set to user-owned currencies
6. **Log finance setup** - Use Laravel logging for debugging registration issues
7. **Handle missing system currencies** - Warn if no system currencies exist during registration

---

## Migration Commands

```bash
# Run migrations
php artisan migrate

# Fresh database with seeded system currencies
php artisan migrate:fresh --seed

# Rollback user ownership changes
php artisan migrate:rollback --step=2
```

---

## Seeded System Currencies

Default system currencies (from `CurrencySeeder`):

| Code | Name | Color | Icon |
|------|------|-------|------|
| UZS | Uzbek Sum | #3B82F6 | uzs |
| USD | US Dollar | #06B6D4 | $ |
| RUB | Russian Ruble | #F59E0B | ₽ |
| EUR | Euro | #8B5CF6 | € |

---

## Troubleshooting

**Issue:** User has no currencies after registration

**Solution:** Check that:
- `CurrencySeeder` ran successfully (system currencies exist)
- `SetupUserFinanceData` listener is registered in `AppServiceProvider`
- `Registered` event is being fired during user creation

**Issue:** Duplicate currency error

**Solution:** 
- Ensure `UNIQUE(user_id, code)` constraint exists
- Old `UNIQUE(code)` constraint was dropped in migration

**Issue:** Finance settings not created

**Solution:**
- Check logs for errors in `SetupUserFinanceData` listener
- Verify system currencies exist before user registration
- Ensure database transaction didn't fail
