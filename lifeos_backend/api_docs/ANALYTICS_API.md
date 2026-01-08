# Analytics API Documentation

## Endpoint

```
GET /api/v1/analytics
```

## Authentication

Requires Bearer token authentication via Laravel Sanctum.

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `date_from` | date | No | Start date for analytics period (format: YYYY-MM-DD) |
| `date_to` | date | No | End date for analytics period (format: YYYY-MM-DD) |
| `currency_id` | integer | No | Filter analytics by specific currency ID. If not provided, uses user's default base currency |

### Validation Rules

- `date_from` must be a valid date
- `date_to` must be a valid date and after or equal to `date_from`
- `currency_id` must be a valid integer and exist in the currencies table

## Response

```json
{
  "data": {
    "total_income": "5000.00",
    "total_expense": "1500.00",
    "net_amount": "3500.00",
    "currency_icon": "$",
    "date_from": "2024-01-01",
    "date_to": "2024-01-31",
    "income_by_category": [
      {
        "category_id": 1,
        "category_title": "Salary",
        "category_icon": "salary-icon",
        "category_color": "#00FF00",
        "total_amount": "5000.00",
        "transaction_count": 1
      }
    ],
    "expense_by_category": [
      {
        "category_id": 2,
        "category_title": "Food",
        "category_icon": "food-icon",
        "category_color": "#FF0000",
        "total_amount": "1500.00",
        "transaction_count": 2
      }
    ]
  }
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `total_income` | string | Total income amount (formatted with 2 decimal places) |
| `total_expense` | string | Total expense amount (formatted with 2 decimal places) |
| `net_amount` | string | Net amount (income - expense, formatted with 2 decimal places) |
| `currency_icon` | string | User's base currency icon (e.g., "$", "€", "£") |
| `date_from` | string\|null | Start date of the period (if provided) |
| `date_to` | string\|null | End date of the period (if provided) |
| `income_by_category` | array | Array of income category summaries |
| `expense_by_category` | array | Array of expense category summaries |

### Category Summary Object

| Field | Type | Description |
|-------|------|-------------|
| `category_id` | integer | Category ID |
| `category_title` | string | Category title |
| `category_icon` | string | Category icon identifier |
| `category_color` | string | Category color (hex format) |
| `total_amount` | string | Total amount for this category (formatted with 2 decimal places) |
| `transaction_count` | integer | Number of transactions in this category |

## Examples

### Get all analytics (no date filter)

```bash
curl -X GET "https://api.example.com/api/v1/analytics" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Get analytics for a specific date range

```bash
curl -X GET "https://api.example.com/api/v1/analytics?date_from=2024-01-01&date_to=2024-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Get analytics for a specific currency

```bash
curl -X GET "https://api.example.com/api/v1/analytics?currency_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Get analytics with both date range and currency filter

```bash
curl -X GET "https://api.example.com/api/v1/analytics?date_from=2024-01-01&date_to=2024-01-31&currency_id=2" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

## Error Responses

### 401 Unauthorized

```json
{
  "message": "Unauthenticated."
}
```

### 422 Validation Error

```json
{
  "message": "The date from field must be a valid date.",
  "errors": {
    "date_from": [
      "The date from field must be a valid date."
    ]
  }
}
```

## Implementation Notes

- All amounts are calculated by summing transaction entry amounts
- Transactions are grouped by their category
- Uncategorized transactions (category_id = null) are labeled as "Uncategorized"
- The currency icon is retrieved from the user's base currency settings
- If no date filters are provided, all transactions are included
- Date filters use the `occurred_at` field of transactions
