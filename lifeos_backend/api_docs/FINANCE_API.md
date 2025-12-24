# Finance API Documentation

Base URL: `/api/v1`

All endpoints (except auth) require authentication via Laravel Sanctum.

## Authentication

### Register
```http
POST /api/v1/auth/register
```

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "user": {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com",
      ...
    },
    "token": "1|abcd..."
  }
}
```

---

### Login
```http
POST /api/v1/auth/login
```

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "user": {
      "id": 1,
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com",
      ...
    },
    "token": "2|xyz..."
  }
}
```

---

### Get Current User
```http
GET /api/v1/auth/me
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    ...
  }
}
```

---

### Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "message": "Logged out successfully"
}
```

---

## Currencies

### List Currencies
```http
GET /api/v1/currencies
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "code": "USD",
      "name": "US Dollar",
      "color": "#6366F1",
      "icon": "$",
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    }
  ]
}
```

---

### Show Currency
```http
GET /api/v1/currencies/{currency_id}
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "code": "USD",
    "name": "US Dollar",
    "color": "#6366F1",
    "icon": "$",
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:00:00.000000Z"
  }
}
```

---

## Wallets

### List Wallets
```http
GET /api/v1/wallets
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "My Cash Wallet",
      "currency_id": 1,
      "currency": {
        "id": 1,
        "code": "USD",
        "name": "US Dollar",
        "color": "#6366F1",
        "icon": "$"
      },
      "type": "cash",
      "is_active": true,
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    }
  ]
}
```

---

### Create Wallet
```http
POST /api/v1/wallets
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "My Savings Account",
  "currency_id": 1,
  "type": "bank_account",
  "is_active": true
}
```

**Validation:**
- `name`: required, string, max:255
- `currency_id`: required, integer, exists in currencies table
- `type`: required, enum: `card`, `bank_account`, `cash`, `other`
- `is_active`: optional, boolean

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "My Savings Account",
    "currency_id": 1,
    "currency": {...},
    "type": "bank_account",
    "is_active": true,
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:00:00.000000Z"
  }
}
```

---

### Show Wallet
```http
GET /api/v1/wallets/{wallet_id}
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "My Cash Wallet",
    "currency_id": 1,
    "currency": {...},
    "type": "cash",
    "is_active": true,
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:00:00.000000Z"
  }
}
```

---

### Update Wallet
```http
PATCH /api/v1/wallets/{wallet_id}
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "Updated Wallet Name",
  "is_active": false
}
```

**Validation:** (all fields optional)
- `name`: string, max:255
- `currency_id`: integer, exists in currencies table
- `type`: enum: `card`, `bank_account`, `cash`, `other`
- `is_active`: boolean

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Updated Wallet Name",
    "is_active": false,
    ...
  }
}
```

---

### Delete Wallet
```http
DELETE /api/v1/wallets/{wallet_id}
Authorization: Bearer {token}
```

**Response:** `204 No Content`

**Note:** This sets `is_active` to `false` instead of hard delete.

---

### Get Wallet Balance
```http
GET /api/v1/wallets/{wallet_id}/balance
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": {
    "wallet_id": 1,
    "balance": "1500.250000",
    "currency_id": 1
  }
}
```

---

## Transaction Categories

### List Categories
```http
GET /api/v1/transaction-categories?type=income
Authorization: Bearer {token}
```

**Query Parameters:**
- `type` (optional): `income` or `expense`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "user_id": null,
      "title": "Salary",
      "icon": "💰",
      "color": "#10B981",
      "type": "income",
      "is_system": true,
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    },
    {
      "id": 1,
      "user_id": 1,
      "title": "My Custom Category",
      "icon": "🎯",
      "color": "#6366F1",
      "type": "income",
      "is_system": false,
      "created_at": "2025-12-24T10:00:00.000000Z",
      "updated_at": "2025-12-24T10:00:00.000000Z"
    }
  ]
}
```

**Note:** Returns both system categories (`user_id = null`) and user's custom categories.

---

### Create Category
```http
POST /api/v1/transaction-categories
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "My Custom Income",
  "icon": "🎯",
  "color": "#6366F1",
  "type": "income"
}
```

**Validation:**
- `title`: required, string, max:255
- `icon`: required, string, max:255
- `color`: required, string, max:255 (hex color)
- `type`: required, enum: `income`, `expense`

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "title": "My Custom Income",
    "icon": "🎯",
    "color": "#6366F1",
    "type": "income",
    "is_system": false,
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:00:00.000000Z"
  }
}
```

---

### Update Category
```http
PATCH /api/v1/transaction-categories/{category_id}
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "color": "#8B5CF6"
}
```

**Validation:** (all fields optional)
- `title`: string, max:255
- `icon`: string, max:255
- `color`: string, max:255
- `type`: enum: `income`, `expense`

**Response:** `200 OK`

**Note:** Can only update user's own categories (not system categories).

---

### Delete Category
```http
DELETE /api/v1/transaction-categories/{category_id}
Authorization: Bearer {token}
```

**Response:** `204 No Content`

**Note:** Can only delete user's own categories (not system categories).

---

## Transactions

### List Transactions
```http
GET /api/v1/transactions?type=income&wallet_id=1&page=1&per_page=20
Authorization: Bearer {token}
```

**Query Parameters:**
- `type` (optional): `income`, `expense`, `transfer`, `exchange`
- `wallet_id` (optional): integer - filter by wallet
- `category_id` (optional): integer - filter by category
- `date_from` (optional): Date - filter from date
- `date_to` (optional): Date - filter to date
- `q` (optional): String - search in description
- `page` (optional): Integer - page number (default: 1)
- `per_page` (optional): Integer - items per page (default: 20, max: 100)

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "client_id": "550e8400-e29b-41d4-a716-446655440000",
      "type": "income",
      "category_id": 1,
      "category": {
        "id": 1,
        "title": "Salary",
        "icon": "💰",
        "color": "#10B981",
        "type": "income",
        "is_system": true
      },
      "description": "Monthly salary",
      "occurred_at": "2025-12-24T12:00:00.000000Z",
      "entries": [
        {
          "id": 1,
          "transaction_id": 1,
          "wallet_id": 1,
          "wallet": {
            "id": 1,
            "name": "My Cash Wallet",
            "type": "cash"
          },
          "amount": "5000.000000",
          "currency_id": 1,
          "currency": {
            "code": "USD",
            "name": "US Dollar",
            "icon": "$"
          },
          "rate": null,
          "note": null,
          "created_at": "2025-12-24T12:00:00.000000Z"
        }
      ],
      "created_at": "2025-12-24T12:00:00.000000Z",
      "updated_at": "2025-12-24T12:00:00.000000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 20,
    "total": 95
  }
}
```

---

### Create Transaction
```http
POST /api/v1/transactions
Authorization: Bearer {token}
```

#### Income Example
```json
{
  "client_id": "550e8400-e29b-41d4-a716-446655440000",
  "type": "income",
  "category_id": 1,
  "description": "Freelance project payment",
  "occurred_at": "2025-12-24T12:30:00Z",
  "entries": [
    {
      "wallet_id": 1,
      "amount": "1500.000000",
      "currency_id": 1,
      "note": "Project ABC"
    }
  ]
}
```

#### Expense Example
```json
{
  "client_id": "650e8400-e29b-41d4-a716-446655440001",
  "type": "expense",
  "category_id": 1,
  "description": "Grocery shopping",
  "occurred_at": "2025-12-24T14:30:00Z",
  "entries": [
    {
      "wallet_id": 1,
      "amount": "-250.500000",
      "currency_id": 1,
      "note": "Weekly groceries"
    }
  ]
}
```

#### Transfer Example
```json
{
  "client_id": "750e8400-e29b-41d4-a716-446655440002",
  "type": "transfer",
  "category_id": null,
  "description": "Transfer to savings",
  "occurred_at": "2025-12-24T15:00:00Z",
  "entries": [
    {
      "wallet_id": 1,
      "amount": "-1000.000000",
      "currency_id": 1
    },
    {
      "wallet_id": 2,
      "amount": "1000.000000",
      "currency_id": 1
    }
  ]
}
```

#### Exchange Example
```json
{
  "client_id": "850e8400-e29b-41d4-a716-446655440003",
  "type": "exchange",
  "category_id": null,
  "description": "Currency exchange USD to EUR",
  "occurred_at": "2025-12-24T16:00:00Z",
  "entries": [
    {
      "wallet_id": 1,
      "amount": "-1000.000000",
      "currency_id": 1,
      "rate": "0.92000000"
    },
    {
      "wallet_id": 2,
      "amount": "920.000000",
      "currency_id": 2,
      "rate": "1.08695652"
    }
  ]
}
```

**Business Rules:**
- **Income**: Must have exactly 1 entry with `amount > 0`, `category_id` required
- **Expense**: Must have exactly 1 entry with `amount < 0`, `category_id` required
- **Transfer**: Must have exactly 2 entries with same currency, amounts must sum to 0, `category_id` must be null
- **Exchange**: Must have exactly 2 entries with different currencies, one positive and one negative, `rate` required for both entries, `category_id` must be null
- **Offline Sync**: For offline-created transactions, provide a client-generated UUID v4 in `client_id` to ensure idempotent creates (prevents duplicates on retry)

**Validation:**
- `client_id`: required, UUID v4 string (for idempotent offline sync)
- `type`: required, enum: `income`, `expense`, `transfer`, `exchange`
- `category_id`: nullable, integer, exists in transaction_categories
- `description`: nullable, string, max:1000
- `occurred_at`: required, date
- `entries`: required, array, min:1
- `entries.*.wallet_id`: required, integer, exists in wallets (must belong to authenticated user)
- `entries.*.amount`: required, numeric (signed decimal)
- `entries.*.currency_id`: required, integer, exists in currencies
- `entries.*.rate`: nullable, numeric, min:0
- `entries.*.note`: nullable, string, max:1000

**Idempotency:**
- If a transaction with the same `(user_id, client_id)` already exists, the API returns the existing transaction instead of creating a duplicate
- This ensures safe retry behavior for offline sync scenarios

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "client_id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "income",
    "category_id": 1,
    "category": {...},
    "description": "Freelance project payment",
    "occurred_at": "2025-12-24T12:30:00.000000Z",
    "entries": [...],
    "created_at": "2025-12-24T12:30:00.000000Z",
    "updated_at": "2025-12-24T12:30:00.000000Z"
  }
}
```

---

### Show Transaction
```http
GET /api/v1/transactions/{transaction_id}
Authorization: Bearer {token}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "client_id": "550e8400-e29b-41d4-a716-446655440000",
    "type": "income",
    "category_id": 1,
    "category": {...},
    "description": "Monthly salary",
    "occurred_at": "2025-12-24T12:00:00.000000Z",
    "entries": [...],
    "created_at": "2025-12-24T12:00:00.000000Z",
    "updated_at": "2025-12-24T12:00:00.000000Z"
  }
}
```

---

### Update Transaction
```http
PATCH /api/v1/transactions/{transaction_id}
Authorization: Bearer {token}
```

**Request Body:** (all fields optional)
```json
{
  "description": "Updated description",
  "occurred_at": "2025-12-24T13:00:00Z",
  "entries": [
    {
      "wallet_id": 1,
      "amount": "1600.000000",
      "currency_id": 1
    }
  ]
}
```

**Note:** When updating `entries`, all existing entries are deleted and replaced with new ones. The same business rules apply as in create.

**Response:** `200 OK`

---

### Delete Transaction
```http
DELETE /api/v1/transactions/{transaction_id}
Authorization: Bearer {token}
```

**Response:** `204 No Content`

**Note:** Deletes the transaction and all associated entries (cascade delete).

---

## Error Responses

### 401 Unauthorized
```json
{
  "message": "Unauthenticated."
}
```

### 403 Forbidden
```json
{
  "message": "Cannot update system categories or categories belonging to other users."
}
```

### 404 Not Found
```json
{
  "message": "No query results for model [App\\Models\\Wallet] with the given ID"
}
```

### 422 Unprocessable Entity
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "name": [
      "The name field is required."
    ],
    "entries": [
      "Income transactions must have exactly 1 entry."
    ],
    "entries.0.amount": [
      "Income amount must be positive."
    ]
  }
}
```

---

## Notes

1. All timestamps are in ISO 8601 format (UTC)
2. All monetary amounts are stored as `DECIMAL(18,6)` - 18 digits total, 6 after decimal point
3. Exchange rates are stored as `DECIMAL(18,8)` - 18 digits total, 8 after decimal point
4. BIGINT auto-increment IDs are used as primary keys for all models
5. All protected endpoints require `Authorization: Bearer {token}` header
6. Pagination uses Laravel's standard meta format
7. All queries are automatically scoped to the authenticated user's data
