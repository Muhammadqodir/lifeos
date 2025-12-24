# Configuration & Token Management

## Environment Configuration

The app now uses centralized configuration via `lib/core/config/app_config.dart`.

### API Base URL

You can override the API base URL using Dart defines:

```bash
# Development (default)
flutter run

# Production
flutter run --dart-define=API_BASE_URL=https://api.production.com

# Staging
flutter run --dart-define=API_BASE_URL=https://api.staging.com
```

### Configuration Constants

All configuration is centralized in `AppConfig`:

- `apiBaseUrl` - Backend API URL (default: http://127.0.0.1:8000)
- `connectTimeoutSeconds` - Connection timeout (default: 30s)
- `receiveTimeoutSeconds` - Receive timeout (default: 30s)
- `sendTimeoutSeconds` - Send timeout (default: 30s)
- `authTokenKey` - Storage key for auth token
- `refreshTokenKey` - Storage key for refresh token

## Automatic Token Management

The app now includes automatic token refresh via `AuthInterceptor`:

### Features

1. **Automatic Token Injection**
   - Auth token automatically added to all requests
   - Headers automatically set (Content-Type, Accept)

2. **Automatic Token Refresh**
   - Detects 401 Unauthorized responses
   - Automatically attempts to refresh the token
   - Retries the original request with new token
   - Falls back to logout if refresh fails

3. **Token Storage**
   - Tokens stored in SharedPreferences
   - Automatically cleared on failed refresh
   - Persists across app restarts

### How It Works

```
User makes request → Token expired (401)
     ↓
AuthInterceptor detects 401
     ↓
Calls /api/auth/refresh with refresh_token
     ↓
Success: Save new tokens & retry original request
Failure: Clear tokens & propagate error
```

### Backend Requirements

For token refresh to work, your backend needs to implement:

**Endpoint:** `POST /api/auth/refresh`

**Request:**
```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response (200):**
```json
{
  "token": "new_access_token",
  "refresh_token": "new_refresh_token",
  "user": {
    "id": 1,
    "email": "user@example.com",
    ...
  }
}
```

**Laravel Implementation Example:**

```php
// routes/api.php
Route::post('/auth/refresh', [AuthController::class, 'refresh']);

// app/Http/Controllers/Auth/AuthController.php
public function refresh(Request $request): JsonResponse
{
    $refreshToken = $request->refresh_token;
    
    // Validate refresh token
    $token = PersonalAccessToken::findToken($refreshToken);
    if (!$token || $token->expires_at < now()) {
        throw ValidationException::withMessages([
            'refresh_token' => ['Invalid or expired refresh token'],
        ]);
    }
    
    // Get user and create new tokens
    $user = $token->tokenable;
    $token->delete(); // Invalidate old token
    
    $newToken = $user->createToken('auth_token')->plainTextToken;
    $newRefreshToken = $user->createToken('refresh_token', ['refresh'])->plainTextToken;
    
    return response()->json([
        'user' => new UserResource($user),
        'token' => $newToken,
        'refresh_token' => $newRefreshToken,
    ]);
}
```

## Testing

### Test Token Refresh

1. Login to get initial tokens
2. Wait for token to expire (or manually invalidate it)
3. Make an authenticated request
4. Interceptor should automatically refresh and retry

### Debugging

Enable Dio logging to see interceptor in action:

```dart
// In injection.dart, add:
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

## Security Notes

- Refresh tokens should have longer expiry than access tokens
- Consider implementing token rotation (new refresh token on each refresh)
- Store tokens securely (current: SharedPreferences, consider: flutter_secure_storage for production)
- Implement refresh token revocation on logout
