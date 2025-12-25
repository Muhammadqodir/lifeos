# FX (Currency Exchange Rates) API Documentation

Base URL: `/api/v1`

**Note:** This endpoint is **public** and does not require authentication.

---

## Get Exchange Rates

Retrieve currency exchange rates for specified target currencies.

```http
GET /api/v1/fx/rates?origin=USD&target=UZS
GET /api/v1/fx/rates?origin=USD&target=UZS,RUB,EUR
```

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `origin` | string | Yes | Origin currency code (3-letter ISO code, e.g., "USD") |
| `target` | string | Yes | Target currency code(s). Can be a single code or comma-separated list (e.g., "EUR" or "EUR,GBP,JPY") |

### Success Response

**Status:** `200 OK`

**Single Target:**
```json
{
  "data": {
    "origin": "USD",
    "date": "2025-12-24",
    "rates": {
      "UZS": 12345.67
    }
  },
  "meta": {
    "source": "fawaz_jsdelivr"
  }
}
```

**Multiple Targets:**
```json
{
  "data": {
    "origin": "USD",
    "date": "2025-12-24",
    "rates": {
      "UZS": 12345.67,
      "RUB": 78.91,
      "EUR": 0.92
    }
  },
  "meta": {
    "source": "fawaz_jsdelivr"
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `data.origin` | string | Origin currency code (uppercase) |
| `data.date` | string | Date of the exchange rates in YYYY-MM-DD format |
| `data.rates` | object | Map of target currency codes to exchange rates |
| `meta.source` | string | Provider source identifier ("fawaz_jsdelivr") |

---

## Error Responses

### 422 Unprocessable Entity - Missing Target

**When:** No target currencies provided or empty target parameter.

```json
{
  "message": "The target field must contain at least one currency code.",
  "errors": {
    "target": [
      "The target field must contain at least one currency code."
    ]
  }
}
```

### 422 Unprocessable Entity - Invalid Currency Code Format

**When:** Currency code doesn't match the required 3-letter format.

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "origin": [
      "The origin must be a valid 3-letter currency code (e.g., USD, EUR)."
    ]
  }
}
```

### 422 Unprocessable Entity - Unavailable Target Currency

**When:** One or more requested target currencies are not available in the provider's data.

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "target": [
      "The following target currencies are not available: XYZ, ABC"
    ]
  }
}
```

### 422 Unprocessable Entity - Validation Failed

**When:** Required parameters are missing.

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "origin": [
      "The origin field is required."
    ],
    "target": [
      "The target field is required."
    ]
  }
}
```

### 500 Internal Server Error - Provider Failure

**When:** Unable to fetch rates from the external provider (network issues, timeout, invalid response).

```json
{
  "message": "Failed to fetch exchange rates.",
  "error": "Connection timeout or network error while fetching rates for USD: ..."
}
```

---

## Usage Examples

### Example 1: Get USD to UZS Rate

**Request:**
```bash
curl "https://api.example.com/api/v1/fx/rates?origin=USD&target=UZS"
```

**Response:**
```json
{
  "data": {
    "origin": "USD",
    "date": "2025-12-24",
    "rates": {
      "UZS": 12650.50
    }
  },
  "meta": {
    "source": "fawaz_jsdelivr"
  }
}
```

### Example 2: Get USD to Multiple Currencies

**Request:**
```bash
curl "https://api.example.com/api/v1/fx/rates?origin=USD&target=UZS,EUR,RUB,GBP"
```

**Response:**
```json
{
  "data": {
    "origin": "USD",
    "date": "2025-12-24",
    "rates": {
      "UZS": 12650.50,
      "EUR": 0.92,
      "RUB": 89.45,
      "GBP": 0.79
    }
  },
  "meta": {
    "source": "fawaz_jsdelivr"
  }
}
```

### Example 3: Get EUR to Other Currencies

**Request:**
```bash
curl "https://api.example.com/api/v1/fx/rates?origin=EUR&target=USD,GBP,JPY"
```

**Response:**
```json
{
  "data": {
    "origin": "EUR",
    "date": "2025-12-24",
    "rates": {
      "USD": 1.09,
      "GBP": 0.86,
      "JPY": 156.23
    }
  },
  "meta": {
    "source": "fawaz_jsdelivr"
  }
}
```

---

## Implementation Details

### Provider

The API uses the **Fawaz Ahmed's Currency API** via jsdelivr CDN:
- Base URL: `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/{origin}.json`
- This is a free, open-source currency exchange rates API
- Updated regularly with exchange rates from various sources

### Caching

**Note:** This initial implementation does NOT include caching. All requests fetch fresh data from the provider. Future iterations may add Redis or database caching for improved performance.

### Rate Limits

Since the endpoint is public and relies on an external provider:
- No built-in rate limiting currently implemented
- Consider adding rate limiting middleware in production
- The external provider (jsdelivr CDN) has its own rate limits

### Data Accuracy

- Exchange rates are provided by third-party sources
- Rates may not be real-time and should not be used for actual financial transactions without verification
- The `date` field indicates when the rates were last updated by the provider

---

## Notes

1. **Currency Codes:** All currency codes must be valid 3-letter ISO 4217 codes
2. **Case Insensitive:** Currency codes can be provided in any case (usd, USD, Usd) - they will be normalized to uppercase
3. **Whitespace:** Leading/trailing whitespace in currency codes is automatically trimmed
4. **Public Access:** This endpoint does NOT require authentication
5. **Data Source:** Exchange rates are fetched from a third-party free API (Fawaz Ahmed's Currency API via jsdelivr)
6. **No Caching:** Currently no caching is implemented; each request fetches fresh data
7. **Available Currencies:** The provider supports a wide range of currencies; unavailable currencies will return a 422 error
