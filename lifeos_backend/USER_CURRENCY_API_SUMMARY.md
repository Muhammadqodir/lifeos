# User Currency & Finance Settings API - Implementation Summary

## Overview

Added API endpoints for users to manage their owned currencies and finance settings (base/favorite currency).

---

## New API Endpoints

### 1. Get User's Owned Currencies
```
GET /api/v1/user/currencies
```
- Returns only the authenticated user's currencies (not system currencies)
- Sorted alphabetically by currency code
- Requires authentication

### 2. Get User Finance Settings
```
GET /api/v1/user/finance-settings
```
- Returns the user's finance settings
- Includes base currency details (eager loaded)
- Requires authentication

### 3. Update Base Currency
```
PATCH /api/v1/user/finance-settings
```
- Updates the user's base (favorite) currency
- Validates that the currency belongs to the user
- Requires authentication

---

## Files Created

### Controllers
1. **`app/Http/Controllers/Api/V1/UserCurrencyController.php`**
   - `index()` - Returns user's owned currencies

2. **`app/Http/Controllers/Api/V1/UserFinanceSettingsController.php`**
   - `show()` - Returns user's finance settings
   - `update()` - Updates base currency

### Resources
3. **`app/Http/Resources/UserFinanceSettingsResource.php`**
   - Transforms finance settings to JSON
   - Includes base currency relationship

### Validation
4. **`app/Http/Requests/UpdateFinanceSettingsRequest.php`**
   - Validates `base_currency_id`
   - Ensures currency belongs to authenticated user
   - Custom error message

---

## Files Modified

### Routes
**`routes/api.php`**
- Added imports for new controllers
- Added `/user` prefix group with 3 routes:
  - `GET /user/currencies`
  - `GET /user/finance-settings`
  - `PATCH /user/finance-settings`

### Documentation
**`api_docs/FINANCE_API.md`**
- Added "User Settings" section
- Documented all 3 new endpoints with examples
- Included request/response formats
- Added validation rules and error responses

---

## Request/Response Examples

### Get User Currencies
**Request:**
```bash
GET /api/v1/user/currencies
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": [
    {
      "id": 5,
      "user_id": 1,
      "code": "EUR",
      "name": "Euro",
      "color": "#8B5CF6",
      "icon": "€",
      "is_active": true,
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    },
    // ... more currencies
  ]
}
```

### Get Finance Settings
**Request:**
```bash
GET /api/v1/user/finance-settings
Authorization: Bearer {token}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "base_currency_id": 8,
    "base_currency": {
      "id": 8,
      "user_id": 1,
      "code": "UZS",
      "name": "Uzbek Sum",
      "color": "#3B82F6",
      "icon": "uzs",
      "is_active": true,
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    },
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:00:00.000000Z"
  }
}
```

### Update Base Currency
**Request:**
```bash
PATCH /api/v1/user/finance-settings
Authorization: Bearer {token}
Content-Type: application/json

{
  "base_currency_id": 7
}
```

**Response:**
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "base_currency_id": 7,
    "base_currency": {
      "id": 7,
      "user_id": 1,
      "code": "USD",
      "name": "US Dollar",
      "color": "#06B6D4",
      "icon": "$",
      "is_active": true,
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    },
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:05:30.000000Z"
  }
}
```

---

## Validation Rules

### Update Finance Settings
- `base_currency_id`:
  - Required
  - Must be an integer
  - Must exist in `currencies` table
  - **Must belong to the authenticated user** (validated via `Rule::exists()` with `where('user_id', auth()->id())`)

**Error Response (422):**
```json
{
  "message": "The selected base currency must be one of your own currencies.",
  "errors": {
    "base_currency_id": [
      "The selected base currency must be one of your own currencies."
    ]
  }
}
```

---

## Security Considerations

1. **User Isolation**
   - All endpoints scope queries to `auth()->user()`
   - Cannot access other users' currencies or settings

2. **Validation**
   - Base currency must belong to the authenticated user
   - Cannot set system currency as base currency
   - Cannot set another user's currency as base currency

3. **Authentication**
   - All endpoints require `auth:sanctum` middleware
   - Must provide valid bearer token

---

## Testing

### Verify Routes
```bash
php artisan route:list --path=api/v1/user
```

**Output:**
```
GET|HEAD    api/v1/user/currencies
GET|HEAD    api/v1/user/finance-settings
PATCH       api/v1/user/finance-settings
```

### Manual API Test
```bash
# Get user currencies
curl -H "Authorization: Bearer {token}" \
  http://localhost:8000/api/v1/user/currencies

# Get finance settings
curl -H "Authorization: Bearer {token}" \
  http://localhost:8000/api/v1/user/finance-settings

# Update base currency
curl -X PATCH \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"base_currency_id": 7}' \
  http://localhost:8000/api/v1/user/finance-settings
```

---

## Integration Notes for Flutter Client

### Get User's Currencies
Use this endpoint instead of `/api/v1/currencies` when you need to:
- Display the user's currency list in settings
- Show available currencies for wallet creation
- List currencies for transaction categorization

**Difference from `/currencies`:**
- `/currencies` - Returns system currencies (template list)
- `/user/currencies` - Returns user's owned currencies (can be customized)

### Get Base Currency
Use this to:
- Display the user's preferred currency in UI
- Convert transaction totals to base currency
- Show "Total" in Finances page in favorite currency

### Update Base Currency
Use this when:
- User changes their preferred currency in settings
- User selects a favorite currency during onboarding
- Currency settings screen in the app

---

## Next Steps (Out of Scope)

Potential future enhancements:
- [ ] Add endpoint to activate/deactivate user currencies
- [ ] Add endpoint to update user currency properties (name, color, icon)
- [ ] Add endpoint to create custom currencies (not just clones)
- [ ] Add currency usage statistics
- [ ] Add bulk update for multiple currencies
- [ ] Add currency sorting/ordering preferences
