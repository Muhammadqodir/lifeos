# Currency System - Quick Reference

## 🎯 What Changed?

Currencies now support **SYSTEM** (templates) + **USER-OWNED** (per-user instances).

---

## 📊 Database Schema

### `currencies` table
```
NEW: user_id (nullable FK to users) - NULL = system currency
NEW: is_active (boolean) - for user currencies
CHANGED: UNIQUE constraint - now (user_id, code) instead of just (code)
```

### `user_finance_settings` table (NEW)
```
user_id (unique FK to users) - one-to-one
base_currency_id (FK to currencies) - user's default currency
```

---

## 🔄 Auto-Setup on Registration

**When a user registers:**
1. ✅ All system currencies are cloned for the user
2. ✅ `UserFinanceSettings` created with first currency as base
3. ✅ Wrapped in DB transaction (atomic)
4. ✅ Idempotent (won't duplicate if called twice)

**Event:** `Illuminate\Auth\Events\Registered`  
**Listener:** `App\Listeners\SetupUserFinanceData`

---

## 📝 Model Updates

### `Currency` Model
```php
// New fillable
'user_id', 'is_active'

// New relationship
public function user(): BelongsTo

// New helper methods
$currency->isSystem(); // true if user_id is NULL
Currency::system()->get(); // get system currencies only
Currency::userOwned($userId)->get(); // get user-owned currencies
```

### `User` Model
```php
// New relationships
$user->currencies; // user-owned currencies (HasMany)
$user->financeSettings; // finance settings (HasOne)
```

### `UserFinanceSettings` Model (NEW)
```php
$settings->user; // belongs to User
$settings->baseCurrency; // belongs to Currency
```

---

## 💻 Common Queries

### Get System Currencies
```php
Currency::system()->get();
// or
Currency::whereNull('user_id')->get();
```

### Get User's Currencies
```php
$user->currencies; // via relationship
// or
Currency::userOwned($user->id)->get();
```

### Get User's Base Currency
```php
$user->financeSettings->baseCurrency;
```

### Update Base Currency
```php
$user->financeSettings->update([
    'base_currency_id' => $newCurrencyId,
]);
```

---

## 🧪 Seeding

### System Currencies (CurrencySeeder)
```php
Currency::create([
    'user_id' => null, // SYSTEM
    'code' => 'USD',
    'name' => 'US Dollar',
    'color' => '#06B6D4',
    'icon' => '$',
    'is_active' => true,
]);
```

### Users (UserSeeder)
```php
use App\Listeners\SetupUserFinanceData;
use Illuminate\Auth\Events\Registered;

$user = User::create([...]);

// Manually trigger finance setup
$listener = new SetupUserFinanceData();
$listener->handle(new Registered($user));
```

---

## 📁 Files Created/Modified

### Created
- `database/migrations/2025_12_24_202119_add_user_ownership_to_currencies_table.php`
- `database/migrations/2025_12_24_202208_create_user_finance_settings_table.php`
- `app/Models/UserFinanceSettings.php`
- `app/Listeners/SetupUserFinanceData.php`
- `CURRENCY_SYSTEM.md` (full documentation)
- `IMPLEMENTATION_SUMMARY.md` (detailed changes)

### Modified
- `app/Models/Currency.php` - added user_id, is_active, scopes
- `app/Models/User.php` - added currencies, financeSettings relationships
- `app/Providers/AppServiceProvider.php` - registered event listener
- `database/seeders/CurrencySeeder.php` - mark as system currencies
- `database/seeders/UserSeeder.php` - trigger finance setup

---

## ✅ Testing

### Verify Setup
```bash
php artisan tinker
```

```php
$user = User::first();

// Check finance settings
$user->financeSettings; // should exist
$user->financeSettings->baseCurrency->code; // e.g., "UZS"

// Check currencies
$user->currencies->count(); // should equal system currencies count
$user->currencies->pluck('code'); // should match system codes

// Check system currencies
Currency::system()->count(); // seeded system currencies
```

### Run Comprehensive Test
```bash
php artisan migrate:fresh --seed
```

Expected output:
- System currencies: 4 (UZS, USD, RUB, EUR)
- Each user has 4 cloned currencies
- Each user has finance settings with base currency set

---

## 🚨 Important Notes

1. **Never delete system currencies** - they're templates for new users
2. **Always use transactions** when cloning currencies
3. **Check user ownership** before allowing currency modifications via API
4. **Listener is automatic** - just fire the `Registered` event
5. **Idempotent by design** - safe to call multiple times

---

## 🔗 See Also

- `CURRENCY_SYSTEM.md` - Full documentation
- `IMPLEMENTATION_SUMMARY.md` - Detailed changes list
- `api_docs/FINANCE_API.md` - API documentation
